#!/bin/bash -e

BASEDIR=$(cd $(dirname "$0"); pwd)

pkgname="librealsense"
gitname="librealsense"
gittag="v2.33.1"
#gittag="ff2a291" # master as of Sept-17-2019

cd ${BASEDIR}

if [ ! -f ${BASEDIR}/${gitname}/build/Makefile ]; then

#./aptget_install_these.sh
# we need a more minimal install first
echo -e "\e[32m getting some packages required for librealsense \e[0m"
sudo apt-get install -y build-essential cmake make git pkg-config libusb-1.0-0 libusb-1.0-0-dev libglfw3-dev libgl1-mesa-dev libglu1-mesa-dev xorg-dev libgtk-3-dev qtbase5-dev python2.7-dev python3-dev

echo -e "\e[32m getting librealsense from GitHub \e[0m"
if [ -d ./${gitname} ]; then
	cd ${gitname}
	git reset --hard HEAD
else
	git clone https://github.com/IntelRealSense/librealsense.git
	cd ${gitname}
fi
git checkout -f ${gittag}

#git apply ${BASEDIR}/patch_${pkgname}_${gittag}.patch


if [ -f /etc/udev/rules.d/99-realsense-libusb.rules ]; then
	echo -e "\e[32m The udev rules file have already been copied."
	while read -r -t 0; do read -r; done
	read -p "Run setup_udev_rules again? (y/n) " -n 1 -r
	echo    # move to a new line
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		sudo ./scripts/setup_udev_rules.sh
	fi
	echo -e "\e[0m"
else
	# udev rules needs to be copied and applied for librealsense to work
	# only needs to be done once
	sudo ./scripts/setup_udev_rules.sh
fi

# FORCE_LIBUVC=true is required for Raspbian right now, to avoid having to perform any kernel patches

mkdir -p build && cd build
sudo rm -rf ./*
echo -e "\e[32m calling cmake for librealsense \e[0m"
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_EXAMPLES=true -DBUILD_PYTHON_BINDINGS=true -DPYTHON_EXECUTABLE=$(which python3) -DFORCE_LIBUVC=true .. 2>&1 | tee cmake_outputlog.txt
[ ${PIPESTATUS[0]} -ne 0 ] && exit 1
restarted=0

else
cd ${BASEDIR}/${gitname}/build
restarted=1
fi

# -j4 makes the build happen faster, but it has a tendency to crash the build without any error messages
# so we loop it about 10 times before giving up, it should progress from where it left off when it crashes
n=0
until [ $n -ge 10 ]
do
	echo -e "\e[32m make attempt on $(date) \e[0m" | tee -a make_outputlog.txt
	make -j4 2>&1 | tee -a make_outputlog.txt
	if [ ${PIPESTATUS[0]} -eq 0 ]; then
		break
	else
		if [ $restarted -eq 0 ]; then
			echo -e "\e[33m removing possibly corrupted object files \e[0m"
			find . -type f -size 0 -name *.cpp.o
			find . -type f -size 0 -name *.c.o
		fi
	fi
	n=$[$n+1]
done
[ ${PIPESTATUS[0]} -ne 0 ] && exit 1

sudo make install

sudo cp -f ${BASEDIR}/${gitname}/build/wrappers/python/pyrealsense*.so /usr/local/lib/ || true
sudo cp -f ${BASEDIR}/${gitname}/build/wrappers/python/pyrealsense*.so.* /usr/local/lib/ || true

sudo ldconfig

touch ${BASEDIR}/build_${pkgname}.done
