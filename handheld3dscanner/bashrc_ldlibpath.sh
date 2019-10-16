#!/bin/bash -e

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/lib:/usr/local/lib:/opt/ros/kinetic/lib:/usr/lib/arm-linux-gnueabihf

if ! grep -q 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib:/usr/local/lib:/opt/ros/kinetic/lib:/usr/lib/arm-linux-gnueabihf' ~/.bashrc ; then
	echo -e "\e[32m adding LD_LIBRARY_PATH to .bashrc \e[0m"
	echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib:/usr/local/lib:/opt/ros/kinetic/lib:/usr/lib/arm-linux-gnueabihf' >> ~/.bashrc
else
	echo -e "\e[32m already found LD_LIBRARY_PATH inside .bashrc"
fi

export PYTHONPATH=${PYTHONPATH}:/usr/lib:/usr/local/lib:/usr/lib/arm-linux-gnueabihf

if ! grep -q 'export PYTHONPATH=$PYTHONPATH:/usr/lib:/usr/local/lib:/usr/lib/arm-linux-gnueabihf' ~/.bashrc ; then
	echo -e "\e[32m adding PYTHONPATH to .bashrc \e[0m"
	echo 'export PYTHONPATH=$PYTHONPATH:/usr/lib:/usr/local/lib:/usr/lib/arm-linux-gnueabihf' >> ~/.bashrc
else
	echo -e "\e[32m already found PYTHONPATH inside .bashrc \e[0m"
fi
