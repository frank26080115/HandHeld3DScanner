#!/bin/bash -e

hh3s=~/handheld3dscanner
export hh3s

if [ -f ${hh3s}/aptget.done ]; then
	echo "all apt-get packages have been installed already, skipping this script."
	exit 0
fi

sudo apt-get update

sudo apt-get install -y build-essential cmake make git pkg-config libusb-1.0-0 libusb-1.0-0-dev libglfw3-dev libgl1-mesa-dev libglu1-mesa-dev xorg-dev libgtk-3-dev qtbase5-dev libqt5svg5-dev python2.7-dev python3-dev

sudo apt-get install -y libatomic1 libbullet-dev libbz2-1.0
sudo apt-get install -y f2c libf2c2-dev libflann-dev libblas-dev liblapack-dev
sudo apt-get install -y liblz4-1 liblz4-dev liblz4-tool libbz2-dev
sudo apt-get install -y libeigen3-dev libtf2-eigen-dev
sudo apt-get install -y libprotobuf-dev libtbb2
sudo apt-get install -y libqt5core5a xorg-dev
sudo apt-get install -y libtesseract-dev libsuitesparse-dev
sudo apt-get install -y libtiff-dev libtiff5-dev
sudo apt-get install -y libopenni2-dev libsqlite3-dev
sudo apt-get install -y libusb-1.0-0 libusb-1.0-0-dev
sudo apt-get install -y bison flex bc
sudo apt-get install -y libhdf5-dev libopenmpi-dev
sudo apt-get install -y libjpeg-dev libtiff5-dev libjasper-dev libpng12-dev
sudo apt-get install -y libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libatlas-base-dev gfortran
sudo apt-get install -y libxvidcore-dev libx264-dev libgstreamer1.0-dev
sudo apt-get install -y libgtk2.0-dev libgtk-3-dev

cd ${hh3s}
./set_gcc_version.sh

touch ${hh3s}/aptget.done
