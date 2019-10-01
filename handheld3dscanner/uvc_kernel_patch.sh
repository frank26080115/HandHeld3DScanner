#!/bin/bash -e

gitbranch=rpi-4.19.y
LINUX_BRANCH=$gitbranch

echo "Running the script that patches the UVC kernel module to work with Intel RealSense"
echo "Currently you are using kernel version $(uname -r) , and this script is going to fetch the branch for $gitbranch"

BASEDIR=$(cd $(dirname "$0"); pwd)
WORKINGDIR=${BASEDIR}/kernelpatch

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
git apply ${BASEDIR}/patch_uvc_kernel_module.patch

echo -e "\e[32m calling make... it will ask you questions, please just use the default answer suggested \e[0m"

CONFIG_LOCATION=/usr/src/linux-headers-`uname -r`

# Prepare to compile modules
cp $CONFIG_LOCATION/.config .
cp $CONFIG_LOCATION/Module.symvers .

make scripts oldconfig modules_prepare

# Compile UVC modules
echo -e "\e[32m beginning compilation of uvc... \e[0m"
# Make modules
KBASE=`pwd`
cd drivers/media/usb/uvc
cp $KBASE/Module.symvers .
make -C $KBASE M=$KBASE/drivers/media/usb/uvc/ modules

# Copy to sane location
sudo cp $KBASE/drivers/media/usb/uvc/uvcvideo.ko ~/$LINUX_BRANCH-uvcvideo.ko

# Unload existing module if installed 
echo -e "\e[32m unloading existing uvcvideo driver... \e[0m"
sudo modprobe -r uvcvideo

# Delete existing module
sudo rm /lib/modules/`uname -r`/kernel/drivers/media/usb/uvc/uvcvideo.ko

# Copy out to module directory
sudo cp ~/$LINUX_BRANCH-uvcvideo.ko /lib/modules/`uname -r`/kernel/drivers/media/usb/uvc/uvcvideo.ko

echo -e "\e[32m UVC kernal patching script has completed \e[0m"

echo -e "\e[32m installing Cheese just for fun \e[0m"
sudo apt-get install -y cheese

echo -e "\e[32m done, I think you should reboot \e[0m"
