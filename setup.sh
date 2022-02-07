#!/bin/bash

source ./util.sh # contains print_blue and print_red

bluetooth_dir=/etc/bluetooth
bluetooth_config=$bluetooth_dir/main.conf
bluez_tools_config=/etc/systemd/system/bt-agent.service

# install dependencies

print_blue "installing required packages for bluetooth music hub..."
sudo apt-get install -y pulseaudio pulseaudio-module-bluetooth bluez-tools

# create bluetooth group

print_blue "creating bluetooth group and adding current user..."
sudo groupadd bluetooth
sudo usermod -a -G bluetooth $USER

# add relevant configuration

    # bluetoothctl config
print_blue "adding config to $bluetooth_config..."
sudo mkdir -p $bluetooth_dir
sudo touch $bluetooth_config

cat $bluetooth_config | sed 's/\(\[General\]\)/\1\
\
# ..... (added by pi-speaker.sh)\
Class = 0x41C\
DiscoverableTimeout = 0\
# ...../' | sudo tee $bluetooth_config > /dev/null

    #bluez-tools config
print_blue "adding config to $bluez_tools_config..."
sudo cat > $bluez_tools_config << EOF
[Unit]
Description=Bluetooth Auth Agent
After=bluetooth.service
PartOf=bluetooth.service

[Service]
Type=simple
ExecStart=/usr/bin/bt-agent -c NoInputNoOutput

[Install]
WantedBy=bluetooth.target
EOF

print_blue "restarting bluetooth service and rebooting device..."
sudo systemctl restart bluetooth
sudo reboot
