#!/bin/bash -e

BASEDIR=$(cd $(dirname "$0"); pwd)

source /opt/ros/kinetic/setup.bash

DESKTOPDIR=/usr/share/applications
DESKTOPNAME=poweroff.desktop

sudo mkdir -p /usr/share/handheld3dscanner

echo "writing into ${DESKTOPDIR}/$DESKTOPNAME"

str="echo \"[Desktop Entry]\" > ${DESKTOPDIR}/$DESKTOPNAME"
sudo sh -c "$str"
str="echo \"Name=Power-Off\" >> ${DESKTOPDIR}/$DESKTOPNAME"
sudo sh -c "$str"
str="echo \"Comment=Power-Off\" >> ${DESKTOPDIR}/$DESKTOPNAME"
sudo sh -c "$str"
str="echo \"Exec=${BASEDIR}/run_shutdown.sh\" >> ${DESKTOPDIR}/$DESKTOPNAME"
sudo sh -c "$str"
str="echo \"Icon=${BASEDIR}/offbutton.png\" >> ${DESKTOPDIR}/$DESKTOPNAME"
sudo sh -c "$str"
str="echo \"Terminal=false\" >> ${DESKTOPDIR}/$DESKTOPNAME"
sudo sh -c "$str"
str="echo \"Type=Application\" >> ${DESKTOPDIR}/$DESKTOPNAME"
sudo sh -c "$str"
str="echo \"Categories=System;\" >> ${DESKTOPDIR}/$DESKTOPNAME"
sudo sh -c "$str"

if [ ! -f RTAB-Map.png ]; then
	cd ${BASEDIR}
	wget https://raw.githubusercontent.com/introlab/rtabmap/master/guilib/src/images/RTAB-Map.png
fi
