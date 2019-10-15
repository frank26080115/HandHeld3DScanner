#!/bin/bash -e

BASEDIR=$(cd $(dirname "$0"); pwd)

if [ "$(cd ${BASEDIR}; pwd)" != "$(pwd)" ]; then
	echo -e "\e[31m Script not called from the correct working directory, $(cd ${BASEDIR}; pwd) != $(pwd) \e[0m"
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

[ ! -f ${BASEDIR}/build_ros_rtabmap.done  ] && ./build_ros_rtabmap.sh
./install_rtabmap_icon.sh

echo -e "\e[32m librealsense2, ROS Kinetic, and RTAB-Map have been installed \e[0m"

echo -e "\e[32m If you want to, we can patch the UVC kernel module so the Intel RealSense camera works as a webcam. This will take another hour and several gigabytes of storage. This step will require some user interaction as well."
while read -r -t 0; do read -r; done
read -p "Perform the patch? (y/n) " -n 1 -r
echo    # move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	./kernel_patch.sh
else
	echo "You said NO"
fi
echo -e "\e[0m"

./configure_lxde_panel.sh
./configure_rtabmap_ini.sh

if [ -d extras ] ; then
echo -e "\e[32m If you want to, we can add some extra features to RTAB-Map. This takes some extra time and disk space."
while read -r -t 0; do read -r; done
read -p "Add extra features? (y/n) " -n 1 -r
echo    # move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	chmod +x extras/*.sh
	cd extras
	./build_all_extras.sh
	# this step above would've deleted the cached built artifacts
	cd ${BASEDIR}
	./build_ros_rtabmap.sh "-DWITH_G2O=OFF"
else
	echo "You said NO"
fi
echo -e "\e[0m"
fi

echo -e "\e[32m All Installation Done \e[0m"
