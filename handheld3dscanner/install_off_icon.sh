#!/bin/bash -e

BASEDIR=$(cd $(dirname "$0"); pwd)

DESKTOPDIR=/usr/share/applications
DESKTOPNAME=poweroff.desktop

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
