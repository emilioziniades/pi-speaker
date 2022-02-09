#!/bin/bash

# Utility Function

print-blue() { printf "$(tput setaf 6)$1$(tput sgr 0)\n" ; }

# Variables

BLUETOOTH_DIR=/etc/bluetooth
BLUETOOTH_CONFIG=$BLUETOOTH_DIR/main.conf
PIN_FILE=$BLUETOOTH_DIR/pin.conf
SERVICE_DIR=/etc/systemd/system
BT_AGENT_SERVICE=$SERVICE_DIR/bt-agent.service
BLUETOOTH_SERVICE=$SERVICE_DIR/bluetooth.target.wants/bluetooth.service

# Banner

tput setaf 6
cat banner.txt
tput sgr 0

# User Input

read -p "$(print-blue "Enter name of device: ")" NAME
read -p "$(print-blue "Enter pin: ")" PIN

# Save pin code to /etc/bluetooth/pin.conf

print-blue "storing PIN code in $PIN_FILE"
echo -e "*\t$PIN" | sudo tee $PIN_FILE > /dev/null
sudo chmod 600 $PIN_FILE

# Change device name

print-blue "changing device name to $NAME..."
bluetoothctl -- system-alias "$NAME" > /dev/null

# Dependencies

print-blue "installing required packages for pi-speaker..."
sudo apt-get install -y pulseaudio pulseaudio-module-bluetooth bluez-tools > /dev/null 2>&1

# Bluetooth Group

print-blue "creating bluetooth group and adding current user..."
sudo groupadd -f bluetooth
sudo usermod -a -G bluetooth $USER

# Configuration Files

#    /etc/bluetooth/main.conf

print-blue "adding config to $BLUETOOTH_CONFIG..."

sudo sed --in-place -f - $BLUETOOTH_CONFIG <<- EOF
	s/\(\[General\]\)/\1\\
	\\
	# (added by pi-speaker setup script)\\
	# \.\.\.\.\.\\
	Class = 0x41C\\
	DiscoverableTimeout = 0\\
	# \.\.\.\.\.\\
	/
EOF

#   /etc/systemd/system/bluetooth.target.wants/bluetooth.service

print-blue "adding config to $BLUETOOTH_SERVICE..."

sudo sed --in-place --follow-symlinks 's/\(ExecStart.*\)/\1 --noplugin=avrcp,sap/' $BLUETOOTH_SERVICE

#    /etc/system/systemd/bt-agent.service

print-blue "adding config to $BT_AGENT_SERVICE..."

cat <<-EOF | sudo tee $BT_AGENT_SERVICE > /dev/null
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

# Autoload On Boot

print-blue "reloading systemd configuration..."
sudo systemctl daemon-reload

print-blue "setting pulseaudio to launch on startup..."
systemctl --user enable pulseaudio > /dev/null

print-blue "setting bt-agent (bluez-tools) to launch on startup..."
sudo systemctl enable bt-agent > /dev/null

print-blue "editing raspi-config to autologin on startup"
sudo raspi-config nonint do_boot_behaviour "B2 Console Autologin" > /dev/null


# Reboot

print-blue "restarting device..."
sudo reboot
