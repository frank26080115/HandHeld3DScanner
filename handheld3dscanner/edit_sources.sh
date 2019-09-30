#!/bin/bash -e

if ! grep -q 'enabled non free by script' /etc/apt/sources.list ; then
	sudo sh -c 'echo "deb-src http://raspbian.raspberrypi.org/raspbian/ buster main contrib non-free rpi" >> /etc/apt/sources.list'
	sudo sh -c 'echo "# enabled non free by script" >> /etc/apt/sources.list'
	sudo apt-get update && sudo apt-get upgrade
fi
