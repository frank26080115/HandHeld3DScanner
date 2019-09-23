#!/bin/bash -e

BASEDIR=$(cd $(dirname "$0"); pwd)

pkgname="opencv3"
gitname="opencv"
gittag="3.4.7"

# note: Raspbian repo has 3.2 available through apt-get

cd ${BASEDIR}

if [ ! -f ${BASEDIR}/${gitname}/build/Makefile ]; then

if [ -d ${BASEDIR}/${gitname} ]; then
	cd ${BASEDIR}/${gitname}
	git reset --hard HEAD
else
	git clone https://github.com/opencv/opencv.git
	cd ${BASEDIR}/${gitname}
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
cd ${BASEDIR}/${gitname}

git apply ${BASEDIR}/patch_${pkgname}.patch

mkdir -p build && cd build
sudo rm -rf ./*

# -std=c++11

cmake -D CMAKE_BUILD_TYPE=Release                             \
      -D CMAKE_CXX_FLAGS="-march=native -latomic"             \
      -D CMAKE_INSTALL_PREFIX=/usr/local                      \
      -D OPENCV_EXTRA_MODULES_PATH=../opencv_contrib/modules  \
      -D ENABLE_CXX11=OFF                                     \
      -D OPENCV_ENABLE_NONFREE=ON                             \
      -D ENABLE_PRECOMPILED_HEADERS=OFF                       \
      -D BUILD_opencv_dnn=OFF                                 \
      -D BUILD_PYTHON_SUPPORT=ON                              \
      -D WITH_XINE=ON                                         \
      -D WITH_OPENGL=ON                                       \
      -D WITH_TBB=ON                                          \
      -D BUILD_EXAMPLES=OFF                                   \
      -D BUILD_NEW_PYTHON_SUPPORT=ON                          \
      -D WITH_V4L=ON                                          \
      ..                                                      \
      2>&1 | tee cmake_outputlog.txt

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
