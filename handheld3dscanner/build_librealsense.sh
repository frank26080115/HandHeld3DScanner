#!/bin/bash -e

hh3s=~/handheld3dscanner
export hh3s
pkgname="librealsense"
gitname="librealsense"
#gittag="v2.28.0"
gittag="ff2a291" # master as of Sept-17-2019

mkdir -p ${hh3s} && cd ${hh3s}

if [ ! -f ${hh3s}/${gitname}/build/build_${pkgname}.started ]; then

#./aptget_install_these.sh
# we need a more minimal install first
sudo apt-get update
sudo apt-get install -y build-essential cmake make git pkg-config libusb-1.0-0 libusb-1.0-0-dev libglfw3-dev libgl1-mesa-dev libglu1-mesa-dev xorg-dev libgtk-3-dev qtbase5-dev python2.7-dev python3-dev
./set_gcc_version.sh

if [ -d ./${gitname} ]; then
	cd ${gitname}
	git reset --hard HEAD
else
	git clone https://github.com/IntelRealSense/librealsense.git
	cd ${gitname}
fi
git checkout -f ${gittag}

git apply ${hh3s}/patch_${pkgname}_${gittag}.patch

sudo ./scripts/setup_udev_rules.sh

mkdir -p build && cd build
sudo rm -rf ./*
cmake -DCMAKE_BUILD_TYPE=release -DBUILD_EXAMPLES=true -DFORCE_LIBUVC=true .. 2>&1 | tee cmake_outputlog.txt
[ ${PIPESTATUS[0]} -ne 0 ] && exit 1
restarted=0

else
cd ${hh3s}/${gitname}/build
restarted=1
fi

# -j4 makes the build happen faster, but it has a tendency to crash the build without any error messages
# so we loop it about 10 times before giving up, it should progress from where it left off when it crashes
n=0
until [ $n -ge 10 ]
do
	touch ${hh3s}/${gitname}/build/build_${pkgname}.started
	echo "make attempt on $(date)" | tee -a make_outputlog.txt
	make -j4 2>&1 | tee -a make_outputlog.txt
	if [ ${PIPESTATUS[0]} -eq 0 ]; then
		break
	else
		if [ $restarted -eq 0 ]; then
			echo "removing possibly corrupted object files"
			find . -type f -size 0 -name *.cpp.o
			find . -type f -size 0 -name *.c.o
		fi
	fi
	n=$[$n+1]
done
[ ${PIPESTATUS[0]} -ne 0 ] && exit 1

sudo make install
sudo ldconfig

touch ${hh3s}/build_${pkgname}.done
