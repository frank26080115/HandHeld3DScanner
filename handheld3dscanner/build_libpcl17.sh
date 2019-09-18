#!/bin/bash -e

hh3s=~/handheld3dscanner
export hh3s
pkgname="libpcl17"
gitname="pcl"
gittag="pcl-1.7.2"

# PCL 1.7 must be used as it is the only one compatible with rtabmap right now
# too bad it's not in the list of available packages already, so we must build it from source

mkdir -p ${hh3s} && cd ${hh3s}

if [ ! -f ${hh3s}/${gitname}/build/build_${pkgname}.started ]; then

./aptget_install_these.sh
./install_vtk6.sh

# something uninstalled libflann, which is still required here
sudo apt-get install -y libflann-dev

# we want v1.7 so make sure we don't have 1.9 installed
sudo apt-get remove libpcl*9*

if [ -d ${hh3s}/${gitname} ]; then
	cd ${gitname}
	git reset --hard HEAD
else
	git clone https://github.com/PointCloudLibrary/pcl.git
	cd ${gitname}
fi
git checkout -f ${gittag}
git apply ${hh3s}/patch_${pkgname}.patch

# liblz4 must exist, there's a fix that needs to be applied after cmake
sudo apt-get install -y liblz4-*

mkdir -p build && cd build
sudo rm -rf ./*
cmake -DCMAKE_BUILD_TYPE=Release -DPCL_ENABLE_SSE=OFF .. 2>&1 | tee cmake_outputlog.txt
[ ${PIPESTATUS[0]} -ne 0 ] && exit 1

# there's a error that can happen when the linker doesn't link against liblz4
# we can solve it by adding the library file into the linker command
linktxt=${hh3s}/${gitname}/build/kdtree/CMakeFiles/pcl_kdtree.dir/link.txt
if grep -q "liblz4" ${linktxt}; then
	echo "link.txt already contains liblz4"
else
	pathliblz4=/usr/lib/arm-linux-gnueabihf/liblz4.so
	echo "appending \"$pathliblz4\" to link.txt file \"${linktxt}\""
	originallinktxt=$(cat ${linktxt})
	echo "$originallinktxt $pathliblz4" > ${linktxt}
fi

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
[ $PIPESTATUS[0] -ne 0 ] && exit $PIPESTATUS[0]

sudo make install

touch ${hh3s}/build_${pkgname}.done
