#!/bin/bash

vn=8

if [ -z $1 ]; then
	vn=$1
fi

sudo apt-get install -y gcc-${vn} g++-${vn}
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-${vn} 60 --slave /usr/bin/g++ g++ /usr/bin/g++-${vn}
sudo update-alternatives --set gcc "/usr/bin/gcc-${vn}"
