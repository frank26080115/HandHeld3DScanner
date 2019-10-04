#!/bin/bash -e

BASEDIR=$(cd $(dirname "$0"); pwd)

source /opt/ros/kinetic/setup.bash

APPLICATIONDIR=/usr/share/applications
DESKTOPDIR=~/Desktop
DESKTOPNAME=rtabmap.desktop

echo "writing into ${APPLICATIONDIR}/$DESKTOPNAME"

str="echo \"[Desktop Entry]\" > ${APPLICATIONDIR}/$DESKTOPNAME"
sudo sh -c "$str"
str="echo \"Name=RTAB-Map\" >> ${APPLICATIONDIR}/$DESKTOPNAME"
sudo sh -c "$str"
str="echo \"Comment=RTAB-Map for robot visual odometry\" >> ${APPLICATIONDIR}/$DESKTOPNAME"
sudo sh -c "$str"
str="echo \"Exec=${BASEDIR}/run_rtabmap.sh\" >> ${APPLICATIONDIR}/$DESKTOPNAME"
sudo sh -c "$str"
str="echo \"Icon=${BASEDIR}/RTAB-Map.png\" >> ${APPLICATIONDIR}/$DESKTOPNAME"
sudo sh -c "$str"
str="echo \"Terminal=false\" >> ${APPLICATIONDIR}/$DESKTOPNAME"
sudo sh -c "$str"
str="echo \"Type=Application\" >> ${APPLICATIONDIR}/$DESKTOPNAME"
sudo sh -c "$str"
str="echo \"Categories=AudioVideo;Player;Recorder;\" >> ${APPLICATIONDIR}/$DESKTOPNAME"
sudo sh -c "$str"
cp ${APPLICATIONDIR}/$DESKTOPNAME $DESKTOPDIR

if [ ! -f RTAB-Map.png ]; then
	cd ${BASEDIR}
	wget https://raw.githubusercontent.com/introlab/rtabmap/master/guilib/src/images/RTAB-Map.png
fi
