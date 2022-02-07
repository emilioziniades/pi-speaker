#!/bin/bash

source ./util.sh # contains #print blue

bluetooth_dir=/etc/bluetooth
bluetooth_config=$bluetooth_dir/main.conf

# install dependencies

print_blue "installing required packages for bluetooth music hub..."
sudo apt-get install -y pulseaudio pulseaudio-module-bluetooth

# create bluetooth group

print_blue "creating bluetooth group and adding current user..."
sudo groupadd bluetooth
sudo usermod -a -G bluetooth $USER

# add relevant configuration

print_blue "adding config to /etc/bluetooth/main.conf..."
sudo mkdir -p $bluetooth_dir
sudo touch $bluetooth_config

cat $bluetooth_config | sed 's/\(\[General\]\)/\1\
\
# ..... (added by pi-speaker.sh)\
Class = 0x41C\
DiscoverableTimeout = 0\
# ...../' | sudo tee $bluetooth_config > /dev/null

print_blue "restarting bluetooth service and rebooting device..."
sudo systemctl restart bluetooth
sudo reboot
