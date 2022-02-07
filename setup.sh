#!/bin/bash

config=".....\nClass = 0x41C\nDiscoverableTimeout = 0\n....."
bluetooth_dir=/etc/bluetooth

# install dependencies

echo "installing required packages for bluetooth music hub"
sudo apt-get install pulseaudio pulseaudio-module-bluetooth

# create bluetooth group

echo "creating bluetooth group and adding current user"
sudo groupadd bluetooth
sudo usermod -a -G bluetooth $(whoami)

# add relevant configuration

echo "adding config to /etc/bluetooth/main.conf"
sudo mkdir -p $bluetooth_dir
echo -e $config | sudo teee -a $bluetooth_dir/main.conf > /dev/null

echo "restarting bluetooth and rebooting device"
sudo systemctl restart bluetooth
sudo reboot
