#!/bin/bash -e

# https://docs.opencv.org/master/db/db8/tutorial_sfm_installation.html

# note: this script is kinda useless since libceres-dev is available through apt-get already

BASEDIR=$(cd $(dirname "$0"); pwd)

pkgname="ceres-solver"
gitname="ceres-solver"
gittag="1.14.0"

cd ${BASEDIR}

if [ ! -f ${BASEDIR}/${gitname}/build/Makefile ]; then

if [ -d ${BASEDIR}/${gitname} ]; then
	cd ${gitname}
	git reset --hard HEAD
else
	git clone https://ceres-solver.googlesource.com/ceres-solver
	cd ${gitname}
fi

git checkout -f ${gittag}

mkdir -p build && cd build
sudo rm -rf ./*
cmake -DCMAKE_BUILD_TYPE=Release -DCXX11=ON  .. 2>&1 | tee cmake_outputlog.txt
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
