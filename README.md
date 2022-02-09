# pi-speaker

Script to setup a Raspberry Pi as a bluetooth speaker.

Tested on a fresh install of Raspberry Pi OS Lite (Released 28 January 2022, Debian 11 (bullseye)). Raspberry Pi OS Desktop should work the same. 

All credit to DrFunk for his [post on the Raspberry Pi forums](https://forums.raspberrypi.com/viewtopic.php?t=235519). This script basically automates the instructions laid out there. 

The script makes use of the pulseaudio and the bluez-tools libraries.

## Caveat

This script makes use of sudo commands to install the relevant libraries and update the configuration and systemd service files as root. Read through the script and ensure you are happy with what is being executed.

## Instructions

These instructions assume that 1) You have a working install of Raspberry Pi OS and 2) You have installed git.

First, clone the repo.

```console
pi@raspberrypi:~$ git clone https://github.com/emilioziniades/pi-speaker 
```

Then, move into the directory and run the speaker.sh script.

```console
pi@raspberrypi:~$ cd pi-speaker
pi@raspberrypi:~/pi-speaker$ ./speaker.sh
```

You'll be prompted to provide a name and PIN code which will be used during bluetooth connection. Pick a non-obvious PIN code. 

```console
Enter name of device:  pi-speaker
Enter pin:  1234
```

The script should then run. Status of the script's progress will be indicated in blue. If everything ran succesfully, the last message you should see will be an indication that the device is rebooting.

```console
restarting device...
```

That's it! A reboot is required for the changes to take effect. Once the device has successfully restarted, you should be able to connect to the Raspberry Pi using the name and PIN chosen above. Plug your speakers into the Raspberry Pi's AUX port and enjoy the music!

## Contributions

Let me know about any bugs by opening an issue. Any contributions are welcome! Identify a feature you want to add, implement it and submit a pull request. 
