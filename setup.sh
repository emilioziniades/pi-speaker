#!/bin/bash

config="\n#.....( added by pi-speaker/setup.sh )\nClass = 0x41C\nDiscoverableTimeout = 0\n#....."
bluetooth_dir=/etc/bluetooth
bluetooth_config=$bluetooth_dir/main.conf

# install dependencies

echo "installing required packages for bluetooth music hub..."
sudo apt-get install -y pulseaudio pulseaudio-module-bluetooth

# create bluetooth group

echo "creating bluetooth group and adding current user..."
sudo groupadd bluetooth
sudo usermod -a -G bluetooth $USER

# add relevant configuration

echo "adding config to /etc/bluetooth/main.conf..."
sudo mkdir -p $bluetooth_dir
touch $bluetooth_config

cat $bluetooth_config | sed 's/\(\[General\]\)/\1\
\
# ..... (added by pi-speaker.sh)\
Class = 0x41C\
DiscoverableTimeout = 0\
# ...../' | sudo tee $bluetooth_config > /dev/null

echo "restarting bluetooth service and rebooting device..."
sudo systemctl restart bluetooth
sudo reboot
