#!/bin/bash -e

BASEDIR=$(cd $(dirname "$0"); pwd)

echo -e "\e[32m"
echo "The LXDE desktop can be reconfigured, but that will overwrite changes you have made to it"
while read -r -t 0; do read -r; done
read -p "Perform the reconfiguration? (y/n) " -n 1 -r
echo    # move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	mkdir -p ~/.config/lxpanel/LXDE-pi/panels/
	cp -f ${BASEDIR}/panel ~/.config/lxpanel/LXDE-pi/panels/
	echo "Overwrote ~/.config/lxpanel/LXDE-pi/panels/panel"
	mkdir -p ~/.config/lxsession/LXDE-pi
	cp -f ${BASEDIR}/desktop.conf ~/.config/lxsession/LXDE-pi/
	echo "Overwrote ~/.config/lxsession/LXDE-pi/desktop.conf"
else
	echo "You said NO"
fi
echo -e "\e[0m"
