#!/bin/bash -e

BASEDIR=$(cd $(dirname "$0"); pwd)

if [ -f ${BASEDIR}/aptget.done ]; then
	echo "all apt-get packages have been installed already, skipping this script."
	exit 0
fi

sudo apt-get update

sudo apt-get install -y build-essential cmake make git pkg-config libusb-1.0-0 libusb-1.0-0-dev libglfw3-dev libgl1-mesa-dev libglu1-mesa-dev xorg-dev libgtk-3-dev qtbase5-dev libqt5svg5-dev python2.7-dev python3-dev

sudo apt-get install -y libatomic1 libbullet-dev libbz2-1.0
sudo apt-get install -y f2c libf2c2-dev libflann-dev libblas-dev libopenblas-dev liblapack-dev liblapacke-dev
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
sudo apt-get install -y libxvidcore-dev libx264-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
sudo apt-get install -y libdc1394-22-dev libxine2-dev libv4l-dev libavresample-dev
sudo apt-get install -y libgtk-3-dev
# warning : do NOT allow libgtk2.0-dev get installed, rtabmap won't link to the correct one and have fatal runtime errors
sudo apt-get install -y libsuitesparse-dev
sudo apt-get install -y libgoogle-glog-dev
sudo apt-get install -y libceres-dev
sudo apt-get install -y libglew-dev

#sudo apt-get install -y libboost-all-dev
# do not install libboost here, because ROS Kinetic needs libboost 1.58.0 and not the latest version
#sudo apt-get install -y libvtk7-dev libvtk7-qt-dev python-vtk7
#sudo apt-get install -y libpcl-dev
# do not install libpcl, it depends on vtk7, and ROS Kinetic wants vtk6

cd ${BASEDIR}
./set_gcc_version.sh

touch ${BASEDIR}/aptget.done
