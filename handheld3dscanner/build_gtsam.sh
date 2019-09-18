#!/bin/bash -e

# https://github.com/introlab/rtabmap/wiki/Installation#raspberrypi

hh3s=~/handheld3dscanner
export hh3s
pkgname="gtsam"
gitname="gtsam"
gittag="4.0.0-alpha2"

mkdir -p ${hh3s} && cd ${hh3s}

if [ ! -f ${hh3s}/${gitname}/build/build_${pkgname}.started ]; then

./aptget_install_these.sh
./install_vtk6.sh

# at this point in time it seems like libboost1.67 will have been installed
# but not -all-dev version
# let's just replace it with 1.58.0 completely, it'll help build ROS if we need to
if [ ! -f ${hh3s}/build_libboost158.done ]; then
	./build_libboost158.sh
fi
cd ${hh3s}

if [ -d ${hh3s}/${gitname} ]; then
	cd ${gitname}
	git reset --hard HEAD
else
	git clone https://github.com/borglab/gtsam.git
	cd ${gitname}
fi

git checkout -f ${gittag}
#git apply ${hh3s}/patch_gtsam.patch

mkdir -p build && cd build
sudo rm -rf ./*
cmake -DGTSAM_USE_SYSTEM_EIGEN=ON -DGTSAM_BUILD_EXAMPLES_ALWAYS=OFF -DGTSAM_BUILD_TESTS=OFF -DGTSAM_BUILD_UNSTABLE=OFF .. 2>&1 | tee cmake_outputlog.txt
[ ${PIPESTATUS[0]} -ne 0 ] && exit 1
restarted=0

else
cd ${hh3s}/${gitname}/build
restarted=1
fi

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

touch ${hh3s}/build_${pkgname}.done
