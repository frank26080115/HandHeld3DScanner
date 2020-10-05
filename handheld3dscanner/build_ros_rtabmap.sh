#!/bin/bash -e

BASEDIR=$(cd $(dirname "$0"); pwd)
rtabmap_catkin_ws=~/rtabmap_catkin_ws

cd ${BASEDIR}
./bashrc_ldlibpath.sh
source /opt/ros/kinetic/setup.bash

mkdir -p ${rtabmap_catkin_ws} && cd ${rtabmap_catkin_ws}
mkdir -p ${rtabmap_catkin_ws}/src
cd ${rtabmap_catkin_ws}/src

# copy over catkin tools here
cp -rf ~/ros_catkin_ws/src/catkin .

if [ ! -d ${rtabmap_catkin_ws}/src/realsense-ros ]; then
	git clone https://github.com/IntelRealSense/realsense-ros.git
	cd realsense-ros
else
	cd ${rtabmap_catkin_ws}/src/realsense-ros
	git reset --hard HEAD
fi
git checkout -f 2.33.1
cd ${rtabmap_catkin_ws}/src

if [ ! -d ${rtabmap_catkin_ws}/src/rtabmap_ros ]; then
	git clone https://github.com/introlab/rtabmap_ros.git
	cd rtabmap_ros
else
	cd ${rtabmap_catkin_ws}/src/rtabmap_ros
	git reset --hard HEAD
fi
git checkout -f 0.19.3-kinetic
cd ${rtabmap_catkin_ws}/src

if [ ! -d ${rtabmap_catkin_ws}/src/rtabmap ]; then
	git clone https://github.com/introlab/rtabmap.git
	cd rtabmap
else
	cd ${rtabmap_catkin_ws}/src/rtabmap
	git reset --hard HEAD
fi
git checkout -f 0.19.3-kinetic
git apply ${BASEDIR}/patch_rtabmap_0.19.3-kinetic.patch
cd ${rtabmap_catkin_ws}/src

cd ${rtabmap_catkin_ws}

if [ -f my.rosinstall ] ; then
	# use wstool to automatically download dependancies
	if [ ! -f src/.rosinstall ] ; then
		wstool init src my.rosinstall
	else
		wstool merge -t src my.rosinstall
		wstool update -t src
	fi
	# use
	# wstool update -j4 -t src
	# if the update is interrupted
fi
# note: for this script, we are not using the automatic installation generator so we are not using wstool

#rosdep install --from-paths src -i -y -s --rosdistro kinetic --os=debian:buster --skip-keys=librealsense2 --skip-keys=rtabmap
# rosdep would've tried to install libpcl 1.8 for some reason, but at this point, we have libpcl 1.9 already, and Buster doesn't seem to have 1.8 anyways
sudo -H apt-get install -y libbullet-dev libsdl-image1.2-dev libsdl1.2-dev

# https://github.com/RainerKuemmerle/g2o/issues/53#issuecomment-455067781
sudo apt-get install -y libsuitesparse-dev
sudo cp -f ${BASEDIR}/FindCSparse.cmake /usr/share/cmake-*/Modules/

path_opencv_override=''
# we don't need to override this path to OpenCV if it's installed through apt or built from source
# but we do need to if we've used ROS to build it, since it'll live somewhere else
if [ -f /opt/ros/kinetic/share/OpenCV-3.3.1-dev/OpenCVConfig.cmake ]; then
	path_opencv_override='-DOpenCV_DIR=/opt/ros/kinetic/share/OpenCV-3.3.1-dev'
fi

if [[ -z "$1" ]]; then
	extra_options='-DWITH_G2O=OFF'
	# removing these extra features is a safe build that's known to work
	# use the $1 arg later to add extra features
else
	extra_options="$1"
fi

# I've noticed some failures in catkin_make_isolated that might suggest we need to watch out for permission issues
# the hack below is a nuclear solution
install_dir=/opt/ros/kinetic
sudo mkdir -p /opt && sudo mkdir -p /opt/ros && sudo mkdir -p /opt/ros/kinetic
if [ -d ${install_dir} ] ; then
	sudo chown -R $(id -u):$(id -g) ${install_dir}
	sudo chmod -R ugo+rw ${install_dir}
fi
if [ -d ${rtabmap_catkin_ws}/build_isolated ] ; then
	sudo chown -R $(id -u):$(id -g) ${rtabmap_catkin_ws}/build_isolated
	sudo chmod -R ugo+rw ${rtabmap_catkin_ws}/build_isolated
fi
if [ -d ${rtabmap_catkin_ws}/devel_isolated ] ; then
	sudo chown -R $(id -u):$(id -g) ${rtabmap_catkin_ws}/devel_isolated
	sudo chmod -R ugo+rw ${rtabmap_catkin_ws}/devel_isolated
fi

if [ -f ${install_dir}/share/cpu_tsdf/CPUTSDFConfig.cmake ] ; then
	# rabmap's cmake has trouble finding CPUTSDF so an environment variable must be set before building rtabmap
	echo -e "\e[32m CPUTSDF seems to have been installed, setting CPUTSDF_DIR \e[0m"
	export CPUTSDF_DIR=${install_dir}/share/cpu_tsdf
fi

if [ -f ~/extras_catkin_ws/src/ORB_SLAM2/lib/libORB_SLAM2.so ] ; then
	# ORB_SLAM2 has no installation, so an environment variable must be set before building rtabmap
	echo -e "\e[32m ORB_SLAM2 seems to have been installed, setting ORB_SLAM2_ROOT_DIR \e[0m"
	export ORB_SLAM2_ROOT_DIR=$(readlink --canonicalize ~/extras_catkin_ws/src/ORB_SLAM2)
fi

cd ${rtabmap_catkin_ws}
[ -f make_outputlog.txt ] && sudo rm make_outputlog.txt || true

exec > >(tee -i make_outputlog.txt)

n=0
until [ $n -ge 10 ]
do
	catkin_failed=0
	echo -e "\e[32m calling catkin_make_isolated on $(date) \e[0m"
	sudo ldconfig
	if sudo -E ./src/catkin/bin/catkin_make_isolated --install                                             \
                                                  $path_opencv_override                                    \
                                                  $extra_options                                           \
                                                  -DCATKIN_ENABLE_TESTING=False                            \
                                                  -DCMAKE_BUILD_TYPE=Release                               \
                                                  --install-space /opt/ros/kinetic                         \
                                                  -j4 2>&1 ; then
		echo -e "\e[32m catkin_make_isolated seems to have finished successfully \e[0m"
	else
		echo -e "\e[31m catkin_make_isolated seems to have finished and has a failure \e[0m"
		catkin_failed=1
	fi
	if [ $catkin_failed -ne 0 ] ; then
		sudo chown -R $(id -u):$(id -g) ${install_dir}
		sudo chown -R $(id -u):$(id -g) ${rtabmap_catkin_ws}/build_isolated
		sudo chown -R $(id -u):$(id -g) ${rtabmap_catkin_ws}/devel_isolated
		sudo chmod -R ugo+rw ${install_dir}
		sudo chmod -R ugo+rw ${rtabmap_catkin_ws}/build_isolated
		sudo chmod -R ugo+rw ${rtabmap_catkin_ws}/devel_isolated
	else
		echo -e "\e[32m catkin_make_isolated seems to have succeeded \e[0m"
		break
	fi
	n=$[$n+1]
	[ $n -ge 10 ] && exit 1
done

[ $catkin_failed -ne 0 ] && exit 1

# assumed rtabmap is installed in the kinetic directory, we symlink it to our local bin
sudo ln -s $(which rtabmap) /usr/local/bin/rtabmap || true

cd ${BASEDIR}
touch ${BASEDIR}/build_ros_rtabmap.done
