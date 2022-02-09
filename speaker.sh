#!/bin/bash

# Utility Functions

print-colour()
{
    printf "$(tput setaf $1)$2$(tput sgr 0)\n"
}

print-blue()
{
    print-colour 6 "$1"
}

print-red()
{
    print-colour 1 "$1"
}

print-yellow()
{
    print-colour 3 "$1"
}

# Variables

BLUETOOTH_DIR=/etc/bluetooth
BLUETOOTH_CONFIG=$BLUETOOTH_DIR/main.conf
PIN_FILE=$BLUETOOTH_DIR/pin.conf
SERVICE_DIR=/etc/systemd/system
BT_AGENT_SERVICE=$SERVICE_DIR/bt-agent.service
BLUETOOTH_SERVICE=$SERVICE_DIR/bluetooth.target.wants/bluetooth.service

# User Input

read -p "$(print-yellow "Enter name of device: ") " NAME
read -p "$(print-yellow "Enter pin: ") " PIN
echo -e "*\t$PIN" | sudo tee $PIN_FILE > /dev/null
sudo chmod 600 $PIN_FILE

# Dependencies

print-yellow "these are the installed dependencies"
print-yellow "$(sudo apt list --installed | grep -e "pulseaudio" -e "bluez"))"

print-blue "installing required packages for pi-speaker..."
sudo apt-get install -y pulseaudio pulseaudio-module-bluetooth bluez-tools

print-yellow "After install"
print-yellow "$(sudo apt list --installed | grep -e "pulseaudio" -e "bluez"))"

# Bluetooth Group

print-blue "creating bluetooth group and adding current user..."
sudo groupadd -f bluetooth
sudo usermod -a -G bluetooth $USER

# Configuration Files

#    /etc/bluetooth/main.conf

print-blue "adding config to $BLUETOOTH_CONFIG..."

print-yellow "Before"
print-yellow "$( cat $BLUETOOTH_CONFIG )"

sudo sed -i -f - $BLUETOOTH_CONFIG << EOF
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

print-yellow "after"
print-yellow "$( cat $BLUETOOTH_CONFIG )"

# disable avrcp so that connected device can control volume
# TODO : should use $BLUETOOTH_SERVICE in /etc/systemd/system, but not working for some reason
#sudo sed -i 's/\(ExecStart.*\)/\1 --noplugin=avrcp,sap/' /lib/systemd/system/bluetooth.service

#    /etc/system/systemd/bt-agent.service

print-blue "adding config to $BT_AGENT_SERVICE..."

print-yellow "Before"
print-yellow "$( cat $BT_AGENT_SERVICE )"

cat <<EOF | sudo tee $BT_AGENT_SERVICE > /dev/null
[Unit]
Description=Bluetooth Auth Agent
After=bluetooth.service
PartOf=bluetooth.service

[Service]
Type=simple
ExecStart=/usr/bin/bt-agent -c NoInputNoOutput -p $PIN_FILE
ExecStartPost=/bin/sleep 1
ExecStartPost=/bin/hciconfig hci0 sspmode 0
ExecStartPost=/usr/bin/bluetoothctl -- power on
ExecStartPost=/usr/bin/bluetoothctl -- discoverable on
ExecStartPost=/usr/bin/bluetoothctl -- pairable on
ExecStartPost=/usr/bin/bluetoothctl -- agent on

[Install]
WantedBy=bluetooth.target
EOF

print-yellow "After"
print-yellow "$( cat $BT_AGENT_SERVICE )"

# Autoload On Boot

sudo systemctl daemon-reload

# print-blue "restarting bluetooth service..."
# sudo systemctl restart bluetooth

systemctl --user enable pulseaudio
print-blue "pulseaudio will launch on startup"

sudo systemctl enable bt-agent
print-blue "bt-agent (bluez-tools) will launch on startup"

sudo raspi-config nonint do_boot_behaviour "B2 Console Autologin"
print-blue "raspi-config edited: console will autologin on startup"


# Reboot

print-blue "restarting device..."
sudo reboot
