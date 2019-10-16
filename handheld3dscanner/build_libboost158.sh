#!/bin/bash -e

# boost 1.58 is required only if you need ROS, but for consistency's sake, we stick with it for everything
# http://osdevlab.blogspot.com/2016/02/how-to-install-latest-boost-library-on.html

BASEDIR=$(cd $(dirname "$0"); pwd)

pkgname="libboost158"
tarname="boost_1_58_0"

cd ${BASEDIR}

if [ ! -f ${BASEDIR}/${tarname}/bootstrap.log ]; then

sudo apt-get install -y libbz2-dev

if [ ! -f ${tarname}.tar.bz2 ]; then
	wget http://sourceforge.net/projects/boost/files/boost/1.58.0/boost_1_58_0.tar.bz2
fi

if ! echo "fdfc204fc33ec79c99b9a74944c3e54bd78be4f7f15e260c0e2700a36dc7d3e5  ${tarname}.tar.bz2" | sha256sum --check ; then
	echo -e "\e[31m download for boost-1.58.0 failed, please check this script (build_libboost158.sh) and use an alternative URL if needed \e[0m" >&2
	exit 1
fi

if [ ! -d ${tarname} ]; then
	tar xvfo ${tarname}.tar.bz2
	cd ${tarname}
	./bootstrap.sh
fi

fi

cd ${BASEDIR}/${tarname}
./b2

# installing libboost manually this way will overwrite other versions previously installed through apt-get

touch ${BASEDIR}/build_${pkgname}.done
