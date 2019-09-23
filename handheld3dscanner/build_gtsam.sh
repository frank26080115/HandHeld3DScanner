#!/bin/bash -e

# https://github.com/introlab/rtabmap/wiki/Installation#raspberrypi

BASEDIR=$(cd $(dirname "$0"); pwd)

pkgname="gtsam"
gitname="gtsam"
gittag="4.0.0-alpha2"

cd ${BASEDIR}

if [ ! -f ${BASEDIR}/${gitname}/build/Makefile ]; then

./aptget_install_these.sh

if [ ! -f /usr/include/boost/version.hpp ]; then
	echo "Boost's version.hpp file was not found, subsequent build might fail."
	echo "Please use apt-get to install the latest version, or build v1.58.0 from source."
	echo "Example: sudo apt-get install libboost-all-dev"
fi

if [ -d ${BASEDIR}/${gitname} ]; then
	cd ${gitname}
	git reset --hard HEAD
else
	git clone https://github.com/borglab/gtsam.git
	cd ${gitname}
fi

git checkout -f ${gittag}

mkdir -p build && cd build
sudo rm -rf ./*
cmake -DCMAKE_CXX_FLAGS=-march=native -DGTSAM_USE_SYSTEM_EIGEN=ON -DGTSAM_BUILD_EXAMPLES_ALWAYS=OFF -DGTSAM_BUILD_TESTS=OFF -DGTSAM_BUILD_UNSTABLE=OFF .. 2>&1 | tee cmake_outputlog.txt
[ ${PIPESTATUS[0]} -ne 0 ] && exit 1
restarted=0

else
cd ${BASEDIR}/${gitname}/build
restarted=1
fi

n=0
until [ $n -ge 10 ]
do
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

touch ${BASEDIR}/build_${pkgname}.done
