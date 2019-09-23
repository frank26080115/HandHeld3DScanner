#!/bin/bash -e

# https://github.com/introlab/rtabmap/wiki/Installation#raspberrypi

BASEDIR=$(cd $(dirname "$0"); pwd)

pkgname="rtabmap"
gitname="rtabmap"
gittag="0.19.3-kinetic"

if [ ! -f ${BASEDIR}/${gitname}/build/Makefile ]; then

cd ${BASEDIR}

install_extras=1
if [ $install_extras -ne 0 ]; then
	sudo apt-get install -y libeigen3-dev
	sudo apt-get install -y f2c libf2c2-dev libflann-dev libblas-dev libopenblas-dev liblapack-dev liblapacke-dev libtbb2 libatlas-base-dev
	sudo apt-get install -y libxvidcore-dev libx264-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
	sudo apt-get install -y libdc1394-22-dev libxine2-dev libv4l-dev libavresample-dev
	sudo apt-get install -y libgoogle-glog-dev libceres-dev libglew-dev
fi

if [ -d ${BASEDIR}/${gitname} ]; then
	cd ${gitname}
	git reset --hard HEAD
else
	git clone https://github.com/introlab/rtabmap.git
	cd ${gitname}
fi

git checkout -f ${gittag}
git apply ${BASEDIR}/patch_${pkgname}_${gittag}.patch

# https://github.com/RainerKuemmerle/g2o/issues/53#issuecomment-455067781
sudo apt-get install -y libsuitesparse-dev
sudo cp ${BASEDIR}/FindCSparse.cmake /usr/share/cmake-*/Modules/

path_opencv_override=''
# we don't need to override this path to OpenCV if it's installed through apt or built from source
# but we do need to if we've used ROS to build it, since it'll live somewhere else
if [ -f /opt/ros/kinetic/share/OpenCV-3.3.1-dev/OpenCVConfig.cmake ]; then
	path_opencv_override='-DOpenCV_DIR=/opt/ros/kinetic/share/OpenCV-3.3.1-dev'
fi

mkdir -p build && cd build
sudo rm -rf ./*
cmake -DCMAKE_BUILD_TYPE=Release                        \
      ${path_opencv_override}                           \
      -DCMAKE_CXX_FLAGS="-latomic -march=native"        \
      -DWITH_CVSBA=OFF -DWITH_GTSAM=OFF -DWITH_G2O=OFF  \
      .. 2>&1 | tee cmake_outputlog.txt
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
