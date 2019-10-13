#!/bin/bash -e

gitbranch=rpi-4.19.y
LINUX_BRANCH=$gitbranch
has_hid_sensor=0

# note: the patch for HID sensors won't do anything on Raspbian right now since it simply doesn't even have those modules

echo "Running the script that patches the UVC kernel module to work with Intel RealSense"
echo "Currently you are using kernel version $(uname -r) , and this script is going to fetch the branch for $gitbranch"
echo "If this is wrong then the patch won't work"

kregex='s/[^0-9]*([0-9]+\.[0-9]+)[^0-9]*.*/\1/g'
[ $(uname -r | sed -r "$kregex") != $(echo "$gitbranch" | sed -r "$kregex") ] && echo -e "\e[31m ERROR: Kernel Version and Branch MISMATCH \e[0m" && exit 1

BASEDIR=$(cd $(dirname "$0"); pwd)
WORKINGDIR=${BASEDIR}/kernelpatch

[ ! -f ${BASEDIR}/patch_kernel_${gitbranch}.patch ] && echo -e "\e[31m ERROR: Patch File Missing! ${BASEDIR}/patch_kernel_${gitbranch}.patch doesn't exist, your kernel version might not be supported by this script yet \e[0m" && exit 1

mkdir -p ${WORKINGDIR} && cd ${WORKINGDIR}

if [ ! -d ${WORKINGDIR}/linux ]; then
	echo -e "\e[32mcloning the Raspberry Pi kernel git repo... this will take a while...\e[0m"
	git clone https://github.com/raspberrypi/linux.git
	cd ${WORKINGDIR}/linux
else
	cd ${WORKINGDIR}/linux
	git reset --hard HEAD
fi
git checkout $gitbranch

echo -e "\e[32minstalling the Raspberry Pi kernel headers from apt-get... this will take a while...\e[0m"
sudo apt-get install -y raspberrypi-kernel-headers

echo -e "\e[32m installing some other tools...\e[0m"
sudo apt-get install -y bison flex libssl-dev bc

echo -e "\e[32m performing edits to the files now \e[0m"
git apply ${BASEDIR}/patch_kernel_${gitbranch}.patch

echo -e "\e[32m calling make... it might ask you questions, please just use the default answer suggested \e[0m"

CONFIG_LOCATION=/usr/src/linux-headers-`uname -r`

if [ ! -f $CONFIG_LOCATION/.config ]; then
	echo -e "\e[31m Problem: you need to reboot! It seems like your kernel was updated as a part of the \"apt-get upgrade\" step so the \"uname -r\" report \"$(uname -r)\" does not match the linux headers directory \"$(ls /usr/src | grep linux-headers | tail -n1)\" \e[0m"
	echo -e "\e[32m After you reboot, simply call ./install.sh again \e[0m"
	exit 1
fi

# Prepare to compile modules
cp $CONFIG_LOCATION/.config .
cp $CONFIG_LOCATION/Module.symvers .

yes "" | make scripts olddefconfig modules_prepare

echo -e "\e[32m beginning compilation... \e[0m"
# Make modules
KBASE=`pwd`
cd drivers/media/usb/uvc
cp $KBASE/Module.symvers .

echo -e "\e[32m for uvc... \e[0m"
make -C $KBASE M=$KBASE/drivers/media/usb/uvc/ modules
sudo cp $KBASE/drivers/media/usb/uvc/uvcvideo.ko ~/$LINUX_BRANCH-uvcvideo.ko
make -C $KBASE M=$KBASE/drivers/media/usb/uvc/ clean

if [ $has_hid_sensor -ne 0 ]; then
	echo -e "\e[32m for accel and gyro... \e[0m"
	cd $KBASE/drivers/iio
	cp $KBASE/Module.symvers .
	make -C $KBASE M=$KBASE/drivers/iio modules
	sudo cp $KBASE/drivers/iio/accel/hid-sensor-accel-3d.ko ~/$LINUX_BRANCH-hid-sensor-accel-3d.ko
	sudo cp $KBASE/drivers/iio/gyro/hid-sensor-gyro-3d.ko ~/$LINUX_BRANCH-hid-sensor-gyro-3d.ko
fi

# Unload existing module if installed 
echo -e "\e[32m unloading existing drivers... \e[0m"
sudo modprobe -r uvcvideo
if [ $has_hid_sensor -ne 0 ]; then
	sudo modprobe -r hid-sensor-accel-3d
	sudo modprobe -r hid-sensor-gyro-3d
fi

# Delete existing module
sudo rm /lib/modules/`uname -r`/kernel/drivers/media/usb/uvc/uvcvideo.ko
if [ $has_hid_sensor -ne 0 ]; then
	sudo rm /lib/modules/`uname -r`/kernel/drivers/iio/accel/hid-sensor-accel-3d.ko
	sudo rm /lib/modules/`uname -r`/kernel/drivers/iio/gyro/hid-sensor-gyro-3d.ko
fi

# Copy out to module directory
sudo cp ~/$LINUX_BRANCH-uvcvideo.ko /lib/modules/`uname -r`/kernel/drivers/media/usb/uvc/uvcvideo.ko
if [ $has_hid_sensor -ne 0 ]; then
	sudo cp ~/$LINUX_BRANCH-hid-sensor-accel-3d.ko /lib/modules/`uname -r`/kernel/drivers/iio/accel/hid-sensor-accel-3d.ko
	sudo cp ~/$LINUX_BRANCH-hid-sensor-gyro-3d.ko /lib/modules/`uname -r`/kernel/drivers/iio/gyro/hid-sensor-gyro-3d.ko
fi

# Reload the modules
echo -e "\e[32m reloading existing drivers... \e[0m"
sudo modprobe uvcvideo
if [ $has_hid_sensor -ne 0 ]; then
	sudo modprobe hid-sensor-accel-3d
	sudo modprobe hid-sensor-gyro-3d
fi

echo -e "\e[32m kernel module patching script has completed \e[0m"

echo -e "\e[32m installing Cheese just for fun \e[0m"
sudo apt-get install -y cheese
cheeseicon=$(ls -w 1 /usr/share/applications | grep -i cheese | grep desktop)
cp /usr/share/applications/$cheeseicon ~/Desktop

echo -e "\e[32m done, I think you should reboot \e[0m"
