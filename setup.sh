#!/bin/bash

source ./util.sh # contains print_blue and print_red

bluetooth_dir=/etc/bluetooth
pin_file=$bluetooth_dir/pin.conf
bluetooth_config=$bluetooth_dir/main.conf
bluez_tools_config=/etc/systemd/system/bt-agent.service


read -p "Enter name of device: " NAME
read -p "Enter pin: " PIN
echo $PIN | sudo tee $pin_file > /dev/null 
sudo chmod 600 $pin_file



# install dependencies

print_blue "installing required packages for pi-speaker..."
sudo apt-get install -y pulseaudio pulseaudio-module-bluetooth bluez-tools

# create bluetooth group

print_blue "creating bluetooth group and adding current user..."
sudo groupadd bluetooth
sudo usermod -a -G bluetooth $USER

# add relevant configuration

##### bluetoothctl config
print_blue "adding config to $bluetooth_config..."
sudo mkdir -p $bluetooth_dir
sudo touch $bluetooth_config

sed -f - $bluetooth_config | sudo tee $bluetooth_config << EOF
s/\(\[General\]\)/\1\\
\\
# (added by pi-speaker setup script)\\
# \.\.\.\.\.\\
Class = 0x41C\\
DiscoverableTimeout = 0\\
Name = $NAME\\
# \.\.\.\.\.\\
/
EOF

##### bluez-tools config
print_blue "adding config to $bluez_tools_config..."
cat <<EOF | sudo tee $bluez_tools_config > /dev/null
[Unit]
Description=Bluetooth Auth Agent
After=bluetooth.service
PartOf=bluetooth.service

[Service]
Type=simple
ExecStart=/usr/bin/bt-agent -c NoInputNoOutput -p $pin_file
ExecStartPost=/bin/sleep 1
ExecStartPost=/bin/hciconfig hci0 sspmode 0

[Install]
WantedBy=bluetooth.target
EOF

print_blue "restarting bluetooth service and rebooting device..."
sudo systemctl restart bluetooth
sudo reboot
