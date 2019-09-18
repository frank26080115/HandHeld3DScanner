#!/bin/bash -e

# https://github.com/introlab/rtabmap/wiki/Installation#raspberrypi
# http://www.uco.es/investiga/grupos/ava/node/39

hh3s=~/handheld3dscanner
export hh3s
pkgname="cvsba"
dirname="cvsba-1.0.0"
tarname="cvsba-1.0.0.tgz"

mkdir -p ${hh3s} && cd ${hh3s}

if [ ! -f ${hh3s}/${gitname}/build/build_${pkgname}.started ]; then

./aptget_install_these.sh
./install_vtk6.sh

if [ ! -f ${hh3s}/build_opencv3.done ]; then
#	./build_opencv3.sh
	echo "ERROR: cvsba requires opencv, please install it or disable this error message in the script" >&2
	exit 1
fi
cd ${hh3s}

if [ ! -f ${tarname} ] ; then
	rm -f ${tarname}
fi
wget http://sourceforge.net/projects/cvsba/files/1.0.0/cvsba-1.0.0.tgz

if ! echo "1feb689cd87e27c442e63e85763941567a1718b9b89b7acfb6dc496a5bb04c86  ${tarname}" | sha256sum --check ; then
	echo "download for cvsba failed, please check this script (build_cvsba.sh) and use an alternative URL if needed" >&2
	rm -f ${tarname}
	exit 1
fi

tar -zxvf ${tarname} ${dirname}
mkdir -p ${dirname}/build
cd ${dirname}/build
cmake .. 2>&1 | tee cmake_outputlog.txt
[ ${PIPESTATUS[0]} -ne 0 ] && exit 1
restarted=0

else
cd ${hh3s}/${dirname}/build
restarted=1
fi

n=0
until [ $n -ge 10 ]
do
	touch ${hh3s}/${dirname}/build/build_${pkgname}.started
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

sudo mkdir /usr/local/lib/cmake/cvsba
sudo mv /usr/local/lib/cmake/Findcvsba.cmake /usr/local/lib/cmake/cvsba/cvsbaConfig.cmake

touch ${hh3s}/build_${pkgname}.done
