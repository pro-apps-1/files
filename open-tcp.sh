#!/bin/bash


get_config(){
    local file="/var/rocket-ssh/configs.json"
    local key="$2"
    local value=$(jq -r ".$key" "$file")
    echo "$value"
}

proto="tcp"
api_token=$(get_config "api_token")
ovpn_port=$(get_config "servers_openvpn.port")
ovpn_domain=$(get_config "servers_openvpn.domain")


if [ -d /etc/openvpn ]; then
    systemctl stop openvpn
    sudo apt-get purge -y openvpn
    rm -R /etc/openvpn
fi


cp setup/server-template.conf setup/server.conf
sed -i "s/{proto}/$proto/" setup/server.conf
sed -i "s/{port}/$port/" setup/server.conf

rm setup/server.conf
sudo apt install -y openvpn


sed -i "s/{interface}/$interface/" setup/before.rules
yes | sudo cp -rf setup/before.rules /etc/ufw/before.rules
yes | sudo cp -rf setup/sysctl.conf /etc/sysctl.conf
echo -e "done\n"

echo "====== Copying OpenVPN server files ======"
sudo cp -rf setup/{ca.crt,dh.pem,server.conf,server.crt,server.key,ta.key} /etc/openvpn/
echo -e "done\n"


echo "====== Starting OpenVPN ======"
sudo systemctl start openvpn@server
sudo systemctl enable openvpn@server
sudo systemctl status openvpn@server
echo -e "done\n"


echo "====== Creating ovpn file ======"
read -p "Enter file name for this server: " filename
while [[ ${#filename} -eq 0 ]]; do
	echo "File name can not be empty!"
	read -p "Enter file name for this server: " filename
done
	
cp setup/template.ovpn "ovpn_files/$filename.ovpn"
sed -i "s/{ip}/$ip/" "ovpn_files/$filename.ovpn"
sed -i "s/{proto}/$proto/" "ovpn_files/$filename.ovpn"
sed -i "s/{port}/$port/" "ovpn_files/$filename.ovpn"
echo "Installation Complete successfully. You can find it in the ovpn_files folder. Copy or add it to your host."
read -n 1 -s -r -p "Press any key to exit"
