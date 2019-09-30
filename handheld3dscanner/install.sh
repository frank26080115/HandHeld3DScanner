#!/bin/bash -e

BASEDIR=$(cd $(dirname "$0"); pwd)

if [ "$(cd ${BASEDIR}; pwd)" != "$(pwd)" ]; then
	echo "Script not called from the correct working directory, $(cd ${BASEDIR}; pwd) != $(pwd)"
	exit 1
fi

sudo chmod +x *.sh

./bashrc_ldlibpath.sh
./set_gcc_version.sh 8
./edit_sources.sh

[ ! -f ${BASEDIR}/addswapspace.done       ] && ./add_swap_space.sh
[ ! -f ${BASEDIR}/build_librealsense.done ] && ./build_librealsense.sh
[ ! -f ${BASEDIR}/build_libboost158.done  ] && ./build_libboost158.sh
[ ! -f ${BASEDIR}/build_ros.done          ] && ./build_ros.sh
./source_ros.sh
[ ! -f ${BASEDIR}/build_ros_rtabmap.done  ] && ./build_ros_rtabmap.sh
./install_rtabmap_icon.sh
./install_off_icon.sh

echo "this installation script has finished"
