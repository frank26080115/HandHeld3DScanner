#!/bin/bash -e

BASEDIR=$(cd $(dirname "$0"); pwd)
ros_catkin_ws=~/ros_catkin_ws
rtabmap_catkin_ws=~/rtabmap_catkin_ws
extras_catkin_ws=~/extras_catkin_ws

cd ${BASEDIR}
source /opt/ros/kinetic/setup.bash

#####################################################

#sudo apt-get install -y libtbb-dev
# should already have been installed

#./get_giturl.sh https://github.com/ros-planning/random_numbers 0.3.2
# this was a dependancy, I've moved this to the main ROS install instead

./get_giturl.sh https://github.com/borglab/gtsam 342f30d
# warning: gtsam is still being developed constantly

./get_giturl.sh https://github.com/willdzeng/cvsba

#./get_giturl.sh https://github.com/RainerKuemmerle/g2o 20170730_git
# already done by previous step, plus, ORB_SLAM2 brings in its own version

./get_giturl.sh https://github.com/ethz-asl/libnabo 1.0.7

#./get_giturl.sh https://github.com/ethz-asl/libpointmatcher 1.3.1
# disabled because it needs a 64 bit OS, see https://github.com/ethz-asl/libpointmatcher/issues/170

./get_giturl.sh https://github.com/OctoMap/octomap v1.7.1
./get_giturl.sh https://github.com/personalrobotics/OpenChisel

#./get_giturl.sh https://github.com/fovis/fovis 09fdf8a861e2c799becc7202de66912e89d1b55f
# fovis is outdated, doesn't install right, the fork below fixes the installation problems
./get_giturl.sh https://github.com/srv/libfovis kinetic

#./get_giturl.sh https://github.com/akhil22/libviso2
# can't build this, it uses special optimizations for x86 only

#./get_giturl.sh https://github.com/tum-vision/dvo fuerte
#./get_giturl.sh https://github.com/tum-vision/dvo_slam fuerte
# way too outdated to be built by catkin, will revisit
# remember that only dvo_core needs to be built
#./get_giturl.sh https://github.com/strasdat/Sophus
# Sophus is a dependancy
#./get_giturl.sh https://github.com/jlowenz/dvo_core ab4cb26
# it turns out, dvo_core requires x86

#./get_giturl.sh https://github.com/ethz-asl/okvis 1dce9129f22dd4d21d944788cd9da3a4341586aa
# does not build on ARM when OpenCV3 is used

#./get_giturl.sh https://github.com/KumarRobotics/msckf_vio
# MSCKF_VIO is currently not compatible without major changes, it's not enabled by default, and it's not useful for our use case

./get_giturl.sh https://github.com/stevenlovegrove/Pangolin v0.5
./get_giturl.sh https://github.com/raulmur/ORB_SLAM2

#./get_giturl.sh https://github.com/HKUST-Aerial-Robotics/VINS-Mono
#./get_giturl.sh https://github.com/HKUST-Aerial-Robotics/VINS-Fusion
# got a build error I don't know how to resolve, also improper installation problems

./get_giturl.sh https://github.com/sdmiller/cpu_tsdf

#####################################################

# octovis has some difficulty building, we don't need it
sudo rm -rf ${extras_catkin_ws}/src/octomap/octovis

# dependancy issues
sudo rm -rf ${extras_catkin_ws}/src/OpenChisel/chisel_ros
sudo rm -rf ${extras_catkin_ws}/src/VINS-Mono/ar_demo

# missing include dirs during build
[ -d ${extras_catkin_ws}/src/VINS-Fusion/camera_models/include ] && sudo cp -rf ${extras_catkin_ws}/src/VINS-Fusion/camera_models/include/* /opt/ros/kinetic/include
[ -d ${extras_catkin_ws}/src/VINS-Mono/camera_model/include ] && sudo cp -rf ${extras_catkin_ws}/src/VINS-Mono/camera_model/include/* /opt/ros/kinetic/include


cd ${extras_catkin_ws}
#rosdep install -y --from-paths src --ignore-src --rosdistro kinetic -r --os=debian:buster 2>&1 | tee rosdep_log.txt
# rosdep seems to want QT v4 and PCL v1.8
# we have more recent versions available

path_opencv_override=''
# we don't need to override this path to OpenCV if it's installed through apt or built from source
# but we do need to if we've used ROS to build it, since it'll live somewhere else
if [ -f /opt/ros/kinetic/share/OpenCV-3.3.1-dev/OpenCVConfig.cmake ]; then
	path_opencv_override='-DOpenCV_DIR=/opt/ros/kinetic/share/OpenCV-3.3.1-dev'
fi

#path_libboost_override="-DBoost_USE_STATIC_LIBS=ON -DBoost_NO_SYSTEM_PATHS=ON -DBOOST_LIBRARYDIR=${BOOSTPARENTDIR}/boost_1_58_0/stage/lib -DBOOST_INCLUDEDIR=${BOOSTPARENTDIR}/boost_1_58_0"
path_libboost_override=""
# the override is not required

if [ -f make_outputlog.txt ] ; then
	if grep -q 'Please remove the build space or pick a different build space' make_outputlog.txt ; then
		echo -e "\e[31m build space ownership error, must delete and rebuild \e[0m"
		sudo rm -rf ${extras_catkin_ws}/build_isolated
		sudo rm -rf ${extras_catkin_ws}/devel_isolated
	fi
fi

# I've noticed some failures in catkin_make_isolated that might suggest we need to watch out for permission issues
# the hack below is a nuclear solution
install_dir=/opt/ros/kinetic
sudo mkdir -p /opt && sudo mkdir -p /opt/ros && sudo mkdir -p /opt/ros/kinetic
if [ -d ${install_dir} ] ; then
	sudo chown -R $(id -u):$(id -g) ${install_dir}
	sudo chmod -R ugo+rw ${install_dir}
fi
if [ -d ${extras_catkin_ws}/build_isolated ] ; then
	sudo chown -R $(id -u):$(id -g) ${extras_catkin_ws}/build_isolated
	sudo chmod -R ugo+rw ${extras_catkin_ws}/build_isolated
fi
if [ -d ${extras_catkin_ws}/devel_isolated ] ; then
	sudo chown -R $(id -u):$(id -g) ${extras_catkin_ws}/devel_isolated
	sudo chmod -R ugo+rw ${extras_catkin_ws}/devel_isolated
fi

sudo rm make_outputlog.txt || true
# the build output tends to be extra long and with multiple build threads, errors might be hard to find on the terminal screen
# we tee everything to a log file to solve this
exec > >(tee -i make_outputlog.txt)

n=0
until [ $n -ge 10 ]
do
	source /opt/ros/kinetic/setup.bash
	catkin_failed=0
	echo -e "\e[32m calling catkin_make_isolated on $(date) \e[0m"
	if sudo ./src/catkin/bin/catkin_make_isolated --install                                                \
                                                  $path_opencv_override                                    \
                                                  $path_libboost_override                                  \
                                                  -DCATKIN_ENABLE_TESTING=False                            \
                                                  -DCMAKE_BUILD_TYPE=Release                               \
                                                  --install-space /opt/ros/kinetic                         \
                                                  -j4 2>&1 ; then
		echo -e "\e[32m catkin_make_isolated seems to have finished successfully \e[0m"
	else
		source /opt/ros/kinetic/setup.bash
		echo -e "\e[31m catkin_make_isolated seems to have finished and has a failure \e[0m"
		catkin_failed=1
	fi

	# these packages are not installed right, so we copy them manually
	[ -d ${extras_catkin_ws}/devel_isolated/open_chisel/lib ] && sudo cp -rf ${extras_catkin_ws}/devel_isolated/open_chisel/lib/* /opt/ros/kinetic/lib/
	[ -d ${extras_catkin_ws}/devel_isolated/camera_model/lib ] && sudo cp -rf ${extras_catkin_ws}/devel_isolated/camera_model/lib/* /opt/ros/kinetic/lib/
	[ -d ${extras_catkin_ws}/devel_isolated/camera_models/lib ] && sudo cp -rf ${extras_catkin_ws}/devel_isolated/camera_models/lib/* /opt/ros/kinetic/lib/

	if [ $catkin_failed -ne 0 ] ; then
		# patches go here
		sudo chown -R $(id -u):$(id -g) ${install_dir}
		sudo chown -R $(id -u):$(id -g) ${extras_catkin_ws}/build_isolated
		sudo chown -R $(id -u):$(id -g) ${extras_catkin_ws}/devel_isolated
		sudo chmod -R ugo+rw ${install_dir}
		sudo chmod -R ugo+rw ${extras_catkin_ws}/build_isolated
		sudo chmod -R ugo+rw ${extras_catkin_ws}/devel_isolated
	else
		echo -e "\e[32m catkin_make_isolated seems to have succeeded \e[0m"
		break
	fi
	n=$[$n+1]
	[ $n -ge 10 ] && exit 1
done

[ $catkin_failed -ne 0 ] && exit 1

# there's a chance that cvsba didn't get installed right
# with the catkin build, the installation seems proper, but I'm keeping the code here
[ ! -d /usr/local/lib/cmake/cvsba ] && sudo mkdir -pf /usr/local/lib/cmake/cvsba
if [ -f /usr/local/lib/cmake/Findcvsba.cmake ] ; then
	sudo cp -f /usr/local/lib/cmake/Findcvsba.cmake /usr/local/lib/cmake/cvsba/
	sudo mv -f /usr/local/lib/cmake/cvsba/Findcvsba.cmake /usr/local/lib/cmake/cvsba/cvsbaConfig.cmake
	echo -e "\e[33m made copy to /usr/local/lib/cmake/cvsba/cvsbaConfig.cmake \e[0m"
fi

echo -e "\e[32m starting build of Pangolin \e[0m"
cd ${extras_catkin_ws}/src/Pangolin
mkdir -p build && cd build
sudo rm -rf ./*
echo -e "\e[32m calling cmake for Pangolin \e[0m"
cmake ..
echo -e "\e[32m calling make for Pangolin \e[0m"
make -j4 && sudo make install
echo -e "\e[32m starting build of ORB2_SLAM \e[0m"
cd ${extras_catkin_ws}/src/ORB2_SLAM
./build.sh
echo -e "\e[32m ORB2_SLAM and Pangolin should be available for rtabmap now \e[0m"

# delete the cached build from before
sudo rm -rf ${rtabmap_catkin_ws}/build_isolated/rtabmap || true
sudo rm -rf ${rtabmap_catkin_ws}/build_isolated/rtabmap_ros || true
sudo rm -rf ${rtabmap_catkin_ws}/devel_isolated/rtabmap || true
sudo rm -rf ${rtabmap_catkin_ws}/devel_isolated/rtabmap_ros || true
