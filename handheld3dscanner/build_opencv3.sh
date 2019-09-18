#!/bin/bash -e

hh3s=~/handheld3dscanner
export hh3s
pkgname="opencv3"
gitname="opencv"
gittag="3.4.7"

mkdir -p ${hh3s} && cd ${hh3s}

if [ ! -f ${hh3s}/${gitname}/build/build_${pkgname}.started ]; then

./aptget_install_these.sh

if [ -d ${hh3s}/${gitname} ]; then
	cd ${gitname}
	git reset --hard HEAD
else
	git clone https://github.com/opencv/opencv.git
	cd ${gitname}
fi

git checkout -f ${gittag}

# we want extra modules for OpenCV, especially the non-free ones for SURF and SIFT, which can be used by rtabmap
if [ -d ./opencv_contrib ]; then
	cd opencv_contrib
	git reset --hard HEAD
else
	git clone https://github.com/opencv/opencv_contrib.git
	cd opencv_contrib
fi

git checkout -f ${gittag}
cd ${hh3s}/${gitname}

git apply ${hh3s}/patch_${pkgname}.patch
# the patch specifically has a fix for this problem https://github.com/opencv/opencv/issues/11486

mkdir -p build && cd build
sudo rm -rf ./*

cmake -D CMAKE_BUILD_TYPE=Release                             \
      -D CMAKE_INSTALL_PREFIX=/usr/local                      \
      -D OPENCV_EXTRA_MODULES_PATH=../opencv_contrib/modules  \
      -D ENABLE_CXX11=ON                                      \
      -D OPENCV_ENABLE_NONFREE=ON                             \
      -D ENABLE_PRECOMPILED_HEADERS=OFF                       \
      -D BUILD_PYTHON_SUPPORT=ON                              \
      -D WITH_XINE=ON                                         \
      -D WITH_OPENGL=ON                                       \
      -D WITH_TBB=ON                                          \
      -D BUILD_EXAMPLES=ON                                    \
      -D BUILD_NEW_PYTHON_SUPPORT=ON                          \
      -D WITH_V4L=ON                                          \
      ..                                                      \
      2>&1 | tee cmake_outputlog.txt

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
