#!/bin/bash 

source ./util.sh # contains print_blue

# activate bluetoothctl

print_blue "activating bluetoothctl agent..."
bluetoothctl -- power on
bluetoothctl -- discoverable on
bluetoothctl -- pairable on
bluetoothctl -- agent on

# start pulseaudio

print_blue "starting pulseaudio..."
pulseaudio --start

