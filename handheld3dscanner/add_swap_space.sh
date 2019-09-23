#!/bin/bash -e

# OpenCV needs a large amount of RAM to build without crashing
# the Raspberry Pi is fairly limited on RAM, especially if we want to build on all 4 cores
# so we enable a large amount of swap memory, which means using flash memory as RAM

check=$(free -m | grep 'Swap' | awk '{print $2}')
if [ $check -ge 1023 ] ; then
	echo "swap space already $check, skipping"
	exit 0
fi

# this search and replace will overwrite whatever swap memory value it was before
# it is assumed that we are overwriting the default, which is usually only 100
sudo sed -i 's/CONF_SWAPSIZE=[0-9]\+$/CONF_SWAPSIZE=2048/g' /etc/dphys-swapfile
sudo /etc/init.d/dphys-swapfile stop
sudo /etc/init.d/dphys-swapfile start

check=$(free -m | grep 'Swap' | awk '{print $2}')
if [ $check -lt 1023 ] ; then
	echo "swap memory failed to update, $check" >&2
	exit 1
fi
