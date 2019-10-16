#!/bin/bash

source /opt/ros/kinetic/setup.bash

if ! grep -q -F 'source /opt/ros/kinetic/setup.bash' ~/.bashrc ; then
	echo -e "\e[32m adding 'source /opt/ros/kinetic/setup.bash' to .bashrc \e[0m"
	sudo echo 'source /opt/ros/kinetic/setup.bash' >> ~/.bashrc
else
	echo -e "\e[32m already found 'source /opt/ros/kinetic/setup.bash' inside .bashrc \e[0m"
fi
