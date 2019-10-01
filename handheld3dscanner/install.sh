#!/bin/bash -e

BASEDIR=$(cd $(dirname "$0"); pwd)

if [ "$(cd ${BASEDIR}; pwd)" != "$(pwd)" ]; then
	echo "Script not called from the correct working directory, $(cd ${BASEDIR}; pwd) != $(pwd)"
	exit 1
fi

sudo chmod +x *.sh
# this gives execution permission to all the scripts here

./bashrc_ldlibpath.sh
# this ensures the linker can find all installed libraries

./set_gcc_version.sh 8
# it seems like the best GCC version to use is 8

./edit_sources.sh
# this will enable additional dependancy sources, update the apt-get cache, and then upgrade all already-installed packages

./install_off_icon.sh

[ ! -f ${BASEDIR}/addswapspace.done       ] && ./add_swap_space.sh
# some packages need additional RAM to build successfully, so we add some swap space to add virtual memory

[ ! -f ${BASEDIR}/build_librealsense.done ] && ./build_librealsense.sh
./install_realsenseviewer_icon.sh

[ ! -f ${BASEDIR}/build_libboost158.done  ] && ./build_libboost158.sh
# this will leave all the library files inside this directory, not installed into the system
# otherwise, it will interfere with some later build steps and cause crashes

[ ! -f ${BASEDIR}/build_ros.done          ] && ./build_ros.sh
./source_ros.sh

[ ! -f ${BASEDIR}/build_ros_rtabmap.done  ] && ./build_ros_rtabmap.sh
./install_rtabmap_icon.sh

./configure_lxde_panel.sh
./configure_rtabmap_ini.sh

echo "this installation script has finished"
