#!/bin/bash -e

# this will enable additional dependancy sources, update the apt-get cache, and then upgrade all already-installed packages

if ! grep -q 'enabled non free by script' /etc/apt/sources.list ; then
	sudo sh -c 'echo "deb-src http://raspbian.raspberrypi.org/raspbian/ buster main contrib non-free rpi" >> /etc/apt/sources.list'
	sudo sh -c 'echo "# enabled non free by script" >> /etc/apt/sources.list'
	sudo apt-get update && sudo apt-get upgrade -y
fi
