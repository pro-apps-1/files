
#!/bin/bash

if [ -d /etc/openvpn ]; then
    systemctl stop openvpn
    sudo apt-get purge -y openvpn
    rm -R /etc/openvpn
fi

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


ovpn_port=$(get_config_value "servers_openvpn.port")
ovpn_domain=$(get_config_value "servers_openvpn.domain")
api_token=$(get_config_value "api_token")
api_url=$(get_config_value "api_url")


install_dependencies(){
  apt-get install -y openvpn iptables ca-certificates gnupg
}

build_certificates(){
    local file_url="https://raw.githubusercontent.com/pro-apps-1/files/main/open-files/certs.zip"
    local file_path="/etc/openvpn/certs.zip"
    wget $file_url -O $file_path
    unzip $file_path -d /etc/openvpn/
}

openvpn_auth_files(){

    touch /etc/openvpn/ulogin.sh
    touch /etc/openvpn/umanager.sh

    local ulogin_file_url="https://raw.githubusercontent.com/pro-apps-1/files/main/open-files/ulogin.sh"
    local ulogin_file_path="/etc/openvpn/ulogin.sh"
    # Use curl to fetch content from the URL and save it to the output file
    curl -s -o "$ulogin_file_path" "$ulogin_file_url"

    if [ $? -eq 0 ]; then
        sed -i "s|{openApiToken}|$api_token|g" "$ulogin_file_path"
        sed -i "s|{openApiUrl}|$api_url|g" "$ulogin_file_path"
    fi

    local uman_file_url="https://raw.githubusercontent.com/pro-apps-1/files/main/open-files/umanager.sh"
    local uman_file_path="/etc/openvpn/umanager.sh"
    # Use curl to fetch content from the URL and save it to the output file
    curl -s -o "$uman_file_path" "$uman_file_url"

    if [ $? -eq 0 ]; then
        sed -i "s|{openApiToken}|$api_token|g" "$uman_file_path"
        sed -i "s|{openApiUrl}|$api_url|g" "$uman_file_path"
    fi

    chmod +x /etc/openvpn/ulogin.sh
    chmod +x /etc/openvpn/umanager.sh

}

configure_iptable(){

    # Get primary NIC device name
    NIC=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
    PROTOCOL="tcp"
echo "#!/bin/sh
iptables -t nat -I POSTROUTING 1 -s 10.8.0.0/24 -o $NIC -j MASQUERADE
iptables -I INPUT 1 -i tun0 -j ACCEPT
iptables -I FORWARD 1 -i $NIC -o tun0 -j ACCEPT
iptables -I FORWARD 1 -i tun0 -o $NIC -j ACCEPT
iptables -I INPUT 1 -i $NIC -p $PROTOCOL --dport $ovpn_port -j ACCEPT" >/etc/openvpn/add-iptables-rules.sh

# Script to remove rules
echo "#!/bin/sh
iptables -t nat -D POSTROUTING -s 10.8.0.0/24 -o $NIC -j MASQUERADE
iptables -D INPUT -i tun0 -j ACCEPT
iptables -D FORWARD -i $NIC -o tun0 -j ACCEPT
iptables -D FORWARD -i tun0 -o $NIC -j ACCEPT
iptables -D INPUT -i $NIC -p $PROTOCOL --dport $ovpn_port -j ACCEPT" >/etc/openvpn/rm-iptables-rules.sh

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

    chmod +x /etc/openvpn/add-iptables-rules.sh
    chmod +x /etc/openvpn/rm-iptables-rules.sh

    systemctl daemon-reload
    systemctl enable iptables-openvpn
    systemctl start iptables-openvpn
}


configure_ip_forward(){

    # Make ip forwading and make it persistent
    echo 1 > "/proc/sys/net/ipv4/ip_forward"
    echo "net.ipv4.ip_forward = 1" >> "/etc/sysctl.conf"
}


configure_server_conf(){
    mkdir /etc/openvpn/ccd

    local conf_url="https://raw.githubusercontent.com/pro-apps-1/files/main/open-files/server.conf"
    local conf_path="/etc/openvpn/server.conf"

    # Use curl to fetch content from the URL and save it to the output file
    curl -s -o "$conf_path" "$conf_url"

    if [ $? -eq 0 ]; then

        sed -i "s|{openPort}|$ovpn_port|g" "$conf_path"
    fi
}

configre_rules(){
    
    rm /etc/ufw/before.rules
    
    local conf_url="https://raw.githubusercontent.com/pro-apps-1/files/main/open-files/before.rules"
    local conf_path="/etc/ufw/before.rules"
    curl -s -o "$conf_path" "$conf_url"
}

configre_ufw(){

    rm /etc/default/ufw

    local conf_url="https://raw.githubusercontent.com/pro-apps-1/files/main/open-files/ufw"
    local conf_path="/etc/default/ufw"

    curl -s -o "$conf_path" "$conf_url"
}

configure_client_conf(){
    
    local conf_url="https://raw.githubusercontent.com/pro-apps-1/files/main/open-files/client.conf"
    local conf_path="/etc/openvpn/myuser.txt"

    # Use curl to fetch content from the URL and save it to the output file
    curl -s -o "$conf_path" "$conf_url"

    if [ $? -eq 0 ]; then

        sed -i "s|{openDomain}|$ovpn_domain|g" "$conf_path"
        sed -i "s|{openPort}|$ovpn_port|g" "$conf_path"
    fi
}

get_client_generator(){
    local conf_url="https://raw.githubusercontent.com/pro-apps-1/files/main/open-files/gen-client-conf.sh"
    local conf_path="/etc/openvpn/gen-client-conf.sh"

    # Use curl to fetch content from the URL and save it to the output file
    curl -s -o "$conf_path" "$conf_url"
    chmod +x $conf_path
}

start_openvpn(){
    
   systemctl daemon-reload
   systemctl enable openvpn
   systemctl start openvpn
   
   echo "OpenVPN Success Configuration"
}

complete_install(){

    local api_address="$api_url/confirm-installed?token=$api_token&setup=openvpn"
    response=$(curl -s "$api_address")
    echo "installed_openvpn"
}


install_dependencies
build_certificates
configure_server_conf
configure_client_conf
configre_rules
configre_ufw
openvpn_auth_files
configure_iptable
configure_ip_forward
start_openvpn
get_client_generator
complete_install
