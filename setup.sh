#!/bin/bash

source ./util.sh # contains print_blue and print_red

bluetooth_dir=/etc/bluetooth
bluetooth_config=$bluetooth_dir/main.conf
pin_file=$bluetooth_dir/pin.conf
system_dir=/etc/systemd/system
bluez_tools_service=$system_dir/bt-agent.service
bluetooth_service=$system_dir/bluetooth.target.wants/bluetooth.service

# obtain device name and pin from user

read -p "Enter name of device: " NAME
read -p "Enter pin: " PIN
echo -e "*\t$PIN" | sudo tee $pin_file > /dev/null
sudo chmod 600 $pin_file


# install dependencies

print_blue "installing required packages for pi-speaker..."
sudo apt-get install -y pulseaudio pulseaudio-module-bluetooth bluez-tools

# create bluetooth group

print_blue "creating bluetooth group and adding current user..."
sudo groupadd -f bluetooth
sudo usermod -a -G bluetooth $USER

# add relevant configuration

##### bluetoothctl config
print_blue "adding config to $bluetooth_config..."
sudo mkdir -p $bluetooth_dir
sudo touch $bluetooth_config

sudo sed -i -f - $bluetooth_config << EOF
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

# disable avrcp so that connected device can control volume
sudo sed -i 's/\(ExecStart.*\)/\1 --noplugin=avrcp/' $bluetooth_service

##### bluez-tools config
print_blue "adding config to $bluez_tools_service..."
cat <<EOF | sudo tee $bluez_tools_service > /dev/null
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
