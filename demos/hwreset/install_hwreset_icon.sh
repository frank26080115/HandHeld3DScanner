#!/bin/bash -e

BASEDIR=$(cd $(dirname "$0"); pwd)

APPLICATIONDIR=/usr/share/applications
DESKTOPDIR=~/Desktop
DESKTOPNAME=RS-HW-Reset.desktop

echo "writing into ${APPLICATIONDIR}/$DESKTOPNAME"

str="echo \"[Desktop Entry]\" > ${APPLICATIONDIR}/$DESKTOPNAME"
sudo sh -c "$str"
str="echo \"Name=RS-HW-Reset\" >> ${APPLICATIONDIR}/$DESKTOPNAME"
sudo sh -c "$str"
str="echo \"Comment=Hardware reset RealSense cameras\" >> ${APPLICATIONDIR}/$DESKTOPNAME"
sudo sh -c "$str"
str="echo \"Exec=${BASEDIR}/hwreset.py\" >> ${APPLICATIONDIR}/$DESKTOPNAME"
sudo sh -c "$str"
str="echo \"Icon=${BASEDIR}/hwreset_icon.png\" >> ${APPLICATIONDIR}/$DESKTOPNAME"
sudo sh -c "$str"
str="echo \"Terminal=false\" >> ${APPLICATIONDIR}/$DESKTOPNAME"
sudo sh -c "$str"
str="echo \"Type=Application\" >> ${APPLICATIONDIR}/$DESKTOPNAME"
sudo sh -c "$str"
str="echo \"Categories=AudioVideo;Player;Recorder;\" >> ${APPLICATIONDIR}/$DESKTOPNAME"
sudo sh -c "$str"
cp ${APPLICATIONDIR}/$DESKTOPNAME $DESKTOPDIR
