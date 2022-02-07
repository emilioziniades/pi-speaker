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


# launch pulseaudio on boot and configure autoload

systemctl --user enable pulseaudio
print_blue "pulseaudio will launch on startup"

sudo systemctl enable bt-agent
print_blue "bt-agent (bluez-tools) will launch on startup"

sudo raspi-config nonint do_boot_behaviour "B2 Console Autologin"
print_blue "raspi-config edited: console will autologin on startup"
