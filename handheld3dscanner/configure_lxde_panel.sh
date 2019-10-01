#!/bin/bash -e

BASEDIR=$(cd $(dirname "$0"); pwd)

echo -e "\e[32m"
echo "The LXDE desktop can be reconfigured, but that will overwrite changes you have made to it"
read -p "Perform the reconfiguration? (y/n) " -n 1 -r
echo    # move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	cp -f ${BASEDIR}/panel ~/.config/lxpanel/LXDE-pi/panels/
	echo "Overwrote ~/.config/lxpanel/LXDE-pi/panels/panel"
else
	echo "You said NO"
fi
echo -e "\e[0m"
