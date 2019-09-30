#!/bin/bash -e

BASEDIR=$(cd $(dirname "$0"); pwd)

source /opt/ros/kinetic/setup.bash

DESKTOPDIR=/usr/share/applications
DESKTOPNAME=rtabmap.desktop

sudo mkdir -p /usr/share/handheld3dscanner

echo "writing into ${DESKTOPDIR}/$DESKTOPNAME"

str="echo \"[Desktop Entry]\" > ${DESKTOPDIR}/$DESKTOPNAME"
sudo sh -c "$str"
str="echo \"Name=RTAB-Map\" >> ${DESKTOPDIR}/$DESKTOPNAME"
sudo sh -c "$str"
str="echo \"Comment=RTAB-Map for robot visual odometry\" >> ${DESKTOPDIR}/$DESKTOPNAME"
sudo sh -c "$str"
str="echo \"Exec=${BASEDIR}/run_rtabmap.sh\" >> ${DESKTOPDIR}/$DESKTOPNAME"
sudo sh -c "$str"
str="echo \"Icon=${BASEDIR}/RTAB-Map.png\" >> ${DESKTOPDIR}/$DESKTOPNAME"
sudo sh -c "$str"
str="echo \"Terminal=false\" >> ${DESKTOPDIR}/$DESKTOPNAME"
sudo sh -c "$str"
str="echo \"Type=Application\" >> ${DESKTOPDIR}/$DESKTOPNAME"
sudo sh -c "$str"
str="echo \"Categories=AudioVideo;Player;Recorder;\" >> ${DESKTOPDIR}/$DESKTOPNAME"
sudo sh -c "$str"

if [ ! -f RTAB-Map.png ]; then
	cd ${BASEDIR}
	wget https://raw.githubusercontent.com/introlab/rtabmap/master/guilib/src/images/RTAB-Map.png
fi
