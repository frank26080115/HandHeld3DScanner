#!/bin/bash -e

BASEDIR=$(cd $(dirname "$0"); pwd)

echo -e "\e[32m"
echo "The RTAB-Map configuration file can be overwritten with some default values."
read -p "Perform the reconfiguration? (y/n) " -n 1 -r
echo    # move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	mkdir -p ~/.rtabmap
	if [ ! -z "$(fbset -s | grep '480x800')" ]; then
		mv -f ${BASEDIR}/rtabmap_800x480.ini ${BASEDIR}/rtabmap.ini
	else
		if [ ! -z "$(fbset -s | grep '720x720')" ]; then
			mv -f ${BASEDIR}/rtabmap_720x720.ini ${BASEDIR}/rtabmap.ini
		else
			echo "Unknown or unsupported screen resolution for this script, the rtabmap.ini will not be modified"
			exit 0
		fi
	fi
	cp -f ${BASEDIR}/rtabmap.ini ~/.rtabmap/
	echo "Overwrote ~/.rtabmap/rtabmap.ini"
else
	echo "You said NO"
fi
echo -e "\e[0m"
