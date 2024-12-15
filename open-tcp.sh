#!/bin/bash

# Check and remove existing OpenVPN installation
if [ -d /etc/openvpn ]; then
    systemctl stop openvpn
    sudo apt-get purge -y openvpn
    rm -R /etc/openvpn
fi

# Function to get configuration values from configs.json
get_config_value() {
    local configs_file_path="/var/rocket-ssh/configs.json"
    local path="$1"

    local jq_query=".${path}"

    # Use jq to find the value at the constructed path
    if jq -e "$jq_query" "$configs_file_path" > /dev/null; then
        jq -r "$jq_query" "$configs_file_path"
    else
        exit 1
    fi
}

# Retrieve configuration values
ovpn_port=$(get_config_value "servers_openvpn.port")
ovpn_domain=$(get_config_value "servers_openvpn.domain")
api_token=$(get_config_value "api_token")
api_url=$(get_config_value "api_url")

# Function to install dependencies
install_dependencies() {
    apt-get install -y openvpn iptables ca-certificates gnupg
}

# Function to download and extract certificates
build_certificates() {
    local file_url="https://raw.githubusercontent.com/pro-apps-1/files/main/open-files/certs.zip"
    local file_path="/etc/openvpn/certs.zip"
    wget $file_url -O $file_path
    unzip $file_path -d /etc/openvpn/
}

# Function to set up OpenVPN authentication files
openvpn_auth_files() {
    touch /etc/openvpn/ulogin.sh
    touch /etc/openvpn/umanager.sh

    local ulogin_file_url="https://raw.githubusercontent.com/pro-apps-1/files/main/open-files/ulogin.sh"
    local ulogin_file_path="/etc/openvpn/ulogin.sh"
    curl -s -o "$ulogin_file_path" "$ulogin_file_url"

    if [ $? -eq 0 ]; then
        sed -i "s|{openApiToken}|$api_token|g" "$ulogin_file_path"
        sed -i "s|{openApiUrl}|$api_url|g" "$ulogin_file_path"
    fi

    local uman_file_url="https://raw.githubusercontent.com/pro-apps-1/files/main/open-files/umanager.sh"
    local uman_file_path="/etc/openvpn/umanager.sh"
    curl -s -o "$uman_file_path" "$uman_file_url"

    if [ $? -eq 0 ]; then
        sed -i "s|{openApiToken}|$api_token|g" "$uman_file_path"
        sed -i "s|{openApiUrl}|$api_url|g" "$uman_file_path"
    fi

    chmod +x /etc/openvpn/ulogin.sh
    chmod +x /etc/openvpn/umanager.sh
}

# Function to configure iptables and UFW
configure_iptable() {
    SERVICE_NAME="iptables-openvpn.service"
    SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"

    # Check if the service file exists
    if [ -f "$SERVICE_FILE" ]; then
        # Stop and disable the service
        sudo systemctl stop $SERVICE_NAME
        sudo systemctl disable $SERVICE_NAME
        sudo rm "$SERVICE_FILE"
        sudo systemctl daemon-reload
    fi

    # Get primary NIC device name
    NIC=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
    PROTOCOL="tcp"

    # Script to add iptables rules and configure UFW
    echo "#!/bin/sh
iptables -t nat -I POSTROUTING 1 -s 10.8.0.0/24 -o $NIC -j MASQUERADE
iptables -I INPUT 1 -i tun0 -j ACCEPT
iptables -I FORWARD 1 -i $NIC -o tun0 -j ACCEPT
iptables -I FORWARD 1 -i tun0 -o $NIC -j ACCEPT
iptables -I INPUT 1 -i $NIC -p $PROTOCOL --dport $ovpn_port -j ACCEPT

# Configure UFW rules
rm /etc/ufw/before.rules
curl -s -o /etc/ufw/before.rules https://raw.githubusercontent.com/pro-apps-1/files/main/open-files/before.rules

rm /etc/default/ufw
curl -s -o /etc/default/ufw https://raw.githubusercontent.com/pro-apps-1/files/main/open-files/ufw

# Restart UFW to apply changes
ufw disable
ufw enable" >/etc/openvpn/add-iptables-rules.sh

    # Script to remove iptables rules
    echo "#!/bin/sh
iptables -t nat -D POSTROUTING -s 10.8.0.0/24 -o $NIC -j MASQUERADE
iptables -D INPUT -i tun0 -j ACCEPT
iptables -D FORWARD -i $NIC -o tun0 -j ACCEPT
iptables -D FORWARD -i tun0 -o $NIC -j ACCEPT
iptables -D INPUT -i $NIC -p $PROTOCOL --dport $ovpn_port -j ACCEPT" >/etc/openvpn/rm-iptables-rules.sh

    # Create the systemd service file
    echo "[Unit]
Description=iptables rules for OpenVPN
Before=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/etc/openvpn/add-iptables-rules.sh
ExecStop=/etc/openvpn/rm-iptables-rules.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target" >/etc/systemd/system/iptables-openvpn.service

    # Make scripts executable
    chmod +x /etc/openvpn/add-iptables-rules.sh
    chmod +x /etc/openvpn/rm-iptables-rules.sh

    # Reload systemd and enable the service
    systemctl daemon-reload
    systemctl enable iptables-openvpn
    systemctl start iptables-openvpn
}

# Function to enable IP forwarding
configure_ip_forward() {
    echo 1 > "/proc/sys/net/ipv4/ip_forward"
    echo "net.ipv4.ip_forward = 1" >> "/etc/sysctl.conf"
}

# Function to configure OpenVPN server.conf
configure_server_conf() {
    mkdir /etc/openvpn/ccd

    local conf_url="https://raw.githubusercontent.com/pro-apps-1/files/main/open-files/server.conf"
    local conf_path="/etc/openvpn/server.conf"

    curl -s -o "$conf_path" "$conf_url"

    if [ $? -eq 0 ]; then
        sed -i "s|{openPort}|$ovpn_port|g" "$conf_path"
    fi
}

# Function to configure client configuration
configure_client_conf() {
    local conf_url="https://raw.githubusercontent.com/pro-apps-1/files/main/open-files/client.conf"
    local conf_path="/etc/openvpn/myuser.txt"

    curl -s -o "$conf_path" "$conf_url"

    if [ $? -eq 0 ]; then
        sed -i "s|{openDomain}|$ovpn_domain|g" "$conf_path"
        sed -i "s|{openPort}|$ovpn_port|g" "$conf_path"
    fi
}

# Function to download client generator script
get_client_generator() {
    local conf_url="https://raw.githubusercontent.com/pro-apps-1/files/main/open-files/gen-client-conf.sh"
    local conf_path="/etc/openvpn/gen-client-conf.sh"

    curl -s -o "$conf_path" "$conf_url"
    chmod +x "$conf_path"
}

# Function to start OpenVPN service
start_openvpn() {
    systemctl daemon-reload
    systemctl enable openvpn
    systemctl start openvpn

    echo "OpenVPN Success Configuration"
}

# Function to notify API about the installation
complete_install() {
    local api_address="$api_url/confirm-installed?token=$api_token&setup=openvpn"
    response=$(curl -s "$api_address")
    echo "installed_openvpn"
}

# Execute all functions in order
install_dependencies
build_certificates
configure_server_conf
configure_client_conf
openvpn_auth_files
configure_iptable
configure_ip_forward
start_openvpn
get_client_generator
complete_install
