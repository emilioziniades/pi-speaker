#!/bin/bash 

source ./util.sh # contains print_blue

# activate bluetoothctl

print_blue "activating bluetoothctl agent..."
bluetoothctl -- power on
bluetoothctl -- discoverable on
bluetoothctl -- pairable on
bluetoothctl -- agent on

sudo systemctl status bluetooth > /dev/null

if [ $? -eq 0 ]; then
    print_blue "bluetoothctl active..."
else
    print_red "bluetoothctl not active..."
fi

# start pulseaudio

print_blue "starting pulseaudio..."
pulseaudio --start
pulseaudio --check
if [ $? -eq 0 ]; then
    print_blue "pulse audio started..."
else 
    print_red "pulse audio not started..."
fi

# print three lines of systemctl status bluetoothctl
