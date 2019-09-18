#!/bin/bash -e

# https://github.com/introlab/rtabmap/wiki/Installation#raspberrypi

hh3s=~/handheld3dscanner
export hh3s
pkgname="g2o"
gitname="g2o"
gittag="e7b5b7a1143bcbb6d57faab4bff8b2ab3ccd17a6"

mkdir -p ${hh3s} && cd ${hh3s}

if [ ! -f ${hh3s}/${gitname}/build/build_${pkgname}.started ]; then

./aptget_install_these.sh
./install_vtk6.sh

if [ -d ${hh3s}/${gitname} ]; then
	cd ${gitname}
	git reset --hard HEAD
else
	git clone https://github.com/RainerKuemmerle/g2o.git
	cd ${gitname}
fi

git checkout -f ${gittag}
#git apply ${hh3s}/patch_${pkgname}.patch

# https://github.com/RainerKuemmerle/g2o/issues/53#issuecomment-455067781
sudo apt-get install -y libsuitesparse-dev
sudo cp ${hh3s}/FindCSparse.cmake /usr/share/cmake-*/Modules/

# it is of utmost importance that -march=native is off for the g2o build
# in fact, all dependancies of rtabmap should be built without -march=native

mkdir -p build && cd build
sudo rm -rf ./*
cmake -DBUILD_WITH_MARCH_NATIVE=OFF -DG2O_BUILD_APPS=OFF -DG2O_BUILD_EXAMPLES=OFF -DG2O_USE_OPENGL=OFF .. 2>&1 | tee cmake_outputlog.txt
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
