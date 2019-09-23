#!/bin/bash -xe

BASEDIR=$(cd $(dirname "$0"); pwd)

if [ "$(cd ${BASEDIR}; pwd)" != "$(pwd)" ]; then
	echo "Script not called from the correct working directory, $(cd ${BASEDIR}; pwd) != $(pwd)"
	exit 1
fi

./bashrc_ldlibpath.sh

[ ! -f ${BASEDIR}/addswapspace.done       ] && ./add_swap_space.sh
[ ! -f ${BASEDIR}/aptget.done             ] && ./aptget_install_these.sh
[ ! -f ${BASEDIR}/build_librealsense.done ] && ./build_librealsense.sh
[ ! -f ${BASEDIR}/build_opencv3.done      ] && ./build_opencv3.sh
#[ ! -f ${BASEDIR}/build_gtsam.done        ] && ./build_gtsam.sh
#[ ! -f ${BASEDIR}/build_cvsba.done        ] && ./build_cvsba.sh
#[ ! -f ${BASEDIR}/build_g2o.done          ] && ./build_g2o.sh
#[ ! -f ${BASEDIR}/build_libpcl19.done     ] && ./build_libpcl19.sh
[ ! -f ${BASEDIR}/build_rtabmap.done      ] && ./build_rtabmap.sh

echo "this installation script has finished"
