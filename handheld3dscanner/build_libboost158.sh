#!/bin/bash -e

# boost 1.58 is required only if you need ROS, but for consistency's sake, we stick with it for everything
# http://osdevlab.blogspot.com/2016/02/how-to-install-latest-boost-library-on.html

hh3s=~/handheld3dscanner
export hh3s
pkgname="libboost158"

mkdir -p ${hh3s} && cd ${hh3s}

if [ ! -f ${hh3s}/boost_1_58_0/build_${pkgname}.started ]; then

if [ ! -f boost_1_58_0.tar.bz2 ]; then
	wget http://sourceforge.net/projects/boost/files/boost/1.58.0/boost_1_58_0.tar.bz2
fi

if ! echo "fdfc204fc33ec79c99b9a74944c3e54bd78be4f7f15e260c0e2700a36dc7d3e5  boost_1_58_0.tar.bz2" | sha256sum --check ; then
	echo "download for boost-1.58.0 failed, please check this script (build_libboost158.sh) and use an alternative URL if needed" >&2
	exit 1
fi

if [ ! -d boost_1_58_0 ]; then
	tar xvfo boost_1_58_0.tar.bz2
	cd boost_1_58_0
	./bootstrap.sh
fi

fi

cd ${hh3s}/boost_1_58_0
touch ${hh3s}/boost_1_58_0/build_${pkgname}.started
sudo ./b2 install

# installing libboost manually this way will overwrite other versions previously installed through apt-get

touch ${hh3s}/build_${pkgname}.done
