#!/bin/bash

source /opt/ros/kinetic/setup.bash

if ! grep -q -F 'source /opt/ros/kinetic/setup.bash' ~/.bashrc ; then
	echo "adding 'source /opt/ros/kinetic/setup.bash' to .bashrc"
	sudo echo 'source /opt/ros/kinetic/setup.bash' >> ~/.bashrc
else
	echo "already found 'source /opt/ros/kinetic/setup.bash' inside .bashrc"
fi
