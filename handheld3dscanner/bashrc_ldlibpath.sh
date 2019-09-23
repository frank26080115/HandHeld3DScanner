#!/bin/bash -e

#export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib:/opt/ros/kinetic/lib

if ! grep -q 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/ros/kinetic/lib' ~/.bashrc ; then
	echo "adding LD_LIBRARY_PATH to .bashrc"
	sudo echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/ros/kinetic/lib' >> ~/.bashrc
else
	echo "already found LD_LIBRARY_PATH inside .bashrc"
fi
