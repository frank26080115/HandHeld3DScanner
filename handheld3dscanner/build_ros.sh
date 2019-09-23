#!/bin/bash -xe

BASEDIR=$(cd $(dirname "$0"); pwd)
ros_catkin_ws=~/ros_catkin_ws

if [ ! -d ${ros_catkin_ws}/src ]; then

# all instructions from http://wiki.ros.org/ROSberryPi/Installing%20ROS%20Kinetic%20on%20the%20Raspberry%20Pi

sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y python-rosdep python-rosinstall-generator python-wstool python-rosinstall
sudo rosdep init
rosdep update

mkdir -p ${ros_catkin_ws} && cd ${ros_catkin_ws}
rosinstall_generator desktop --rosdistro kinetic --deps --wet-only --tar > kinetic-desktop-wet.rosinstall
wstool init src kinetic-desktop-wet.rosinstall

fi

if [ ! -f ${ros_catkin_ws}/rosdep.done ]; then

install_assimp=0
if [ $install_assimp -ne 0 ]; then
	echo "preemptively installing assimp so that the collada_urdf package successfully builds"
	mkdir -p ${ros_catkin_ws}/external_src cd ${ros_catkin_ws}/external_src
	wget http://sourceforge.net/projects/assimp/files/assimp-3.1/assimp-3.1.1_no_test_models.zip/download -O assimp-3.1.1_no_test_models.zip
	unzip assimp-3.1.1_no_test_models.zip
	cd assimp-3.1.1
	cmake .
	make
	sudo make install
	cd ${ros_catkin_ws}
fi

skip_collada_urdf=1
if [ $skip_collada_urdf -ne 0 ]; then
	echo "skipping the collada_urdf package"
	rosinstall_generator desktop --rosdistro kinetic --deps --wet-only --exclude collada_parser collada_urdf --tar > kinetic-desktop-wet.rosinstall
fi

install_boost158=1
if [ $install_boost158 -ne 0 ]; then
	cd ${BASEDIR}
	if [ ! -f ${BASEDIR}/build_libboost158.done ]; then
		echo "building and installing libboost 1.58.0"
		./build_libboost158.sh
	else
		echo "libboost 1.58.0 already built and installed"
	fi
	cd ${ros_catkin_ws}
fi

cd ${ros_catkin_ws}
rosdep install -y --from-paths src --ignore-src --rosdistro kinetic -r --os=debian:buster

touch rosdep.done

echo "rosdep finished, files available for patching"

fi

cd ${ros_catkin_ws}

patch_opencv3_cv2cpp=1
if [ $patch_opencv3_cv2cpp -ne 0 ]; then
	echo "applying patch to opencv3's cv2.cpp"
	[ ! -f ${BASEDIR}/patchros_opencv3_cv2cpp.patch ] && echo "patch file missing" && exit 1
	[ ! -f ${BASEDIR}/patchros_opencv3_cv2cpp.patch.done ] && patch -f ${ros_catkin_ws}/src/opencv3/modules/python/src2/cv2.cpp < ${BASEDIR}/patchros_opencv3_cv2cpp.patch || true
	# https://github.com/opencv/opencv/issues/14856#issuecomment-504416696
	echo "patch command may have failed if it was already applied, so don't worry"
	touch ${BASEDIR}/patchros_opencv3_cv2cpp.patch.done
fi

patch_opencv3_cmakeliststxt=1
if [ $patch_opencv3_cmakeliststxt -ne 0 ]; then
	echo "applying patch to opencv3's cv2.cpp"
	[ ! -f ${BASEDIR}/patchros_opencv3_cmakeliststxt.patch ] && echo "patch file missing" && exit 1
	[ ! -f ${BASEDIR}/patchros_opencv3_cmakeliststxt.patch.done ] && patch -f ${ros_catkin_ws}/src/opencv3/CMakeLists.txt < ${BASEDIR}/patchros_opencv3_cmakeliststxt.patch || true
	# this patch enables non-free modules like SIFT and SURF, as well as disables problematic modules
	echo "patch command may have failed if it was already applied, so don't worry"
	touch ${BASEDIR}/patchros_opencv3_cmakeliststxt.patch.done
fi

patch_geometry2_buffercorecpp=1
if [ $patch_geometry2_buffercorecpp -ne 0 ]; then
	echo "applying patch to geometry2's buffer_core.cpp"
	[ ! -f ${BASEDIR}/patchros_geometry2_buffercorecpp.patch ] && echo "patch file missing" && exit 1
	[ ! -f ${BASEDIR}/patchros_geometry2_buffercorecpp.patch.done ] && patch -f ${ros_catkin_ws}/src/geometry2/tf2/src/buffer_core.cpp < ${BASEDIR}/patchros_geometry2_buffercorecpp.patch || true
	# https://github.com/ros/console_bridge/issues/56 and https://github.com/ros/ros-overlay/issues/509
	echo "patch command may have failed if it was already applied, so don't worry"
	touch ${BASEDIR}/patchros_geometry2_buffercorecpp.patch.done
fi

install_extras=0
if [ $install_extras -ne 0 ]; then
	# these optional packages are linked to by OpenCV, enabling more features
	sudo apt-get install -y libeigen3-dev
	sudo apt-get install -y f2c libf2c2-dev libflann-dev libblas-dev libopenblas-dev liblapack-dev liblapacke-dev libtbb2 libatlas-base-dev
	sudo apt-get install -y libxvidcore-dev libx264-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
	sudo apt-get install -y libdc1394-22-dev libxine2-dev libv4l-dev libavresample-dev
	sudo apt-get install -y libgoogle-glog-dev libceres-dev libglew-dev
	# --dry-run shows these do not cause conflicts
fi

# warning: do NOT enable this secction, VTK7 has problems with rtabmap
# and this pulls in libboost 1.67 which conflicts with 1.58, having both will cause cloud maps to not work
install_libpcl_apt=0
if [ $install_libpcl_apt -ne 0 ]; then
	echo "ERROR: DO NOT install VTK7 or libboost 1.67! This means you need to build libpcl 1.9 from source instead of automatically installing it." && exit 1
	sudo apt-get remove -y libvtk6-*
	sudo apt-get install -y libvtk7-dev libvtk7-qt-dev
	sudo apt-get install -y libpcl-dev
	# a newer libboost might have been pulled in, but don't worry, we can just re-install our version of libboost 1.58.0
	if [ $install_boost158 -ne 0 ]; then
		[ ! -f ${BASEDIR}/boost_1_58_0/b2 ] && echo "ERROR, libboost cannot be installed, seems like previous libboost build failed" && exit 1
		cd ${BASEDIR}/boost_1_58_0
		sudo ./b2 install
		sudo ldconfig
	fi
fi

cd ${ros_catkin_ws}

patch_qt_gui_cpp_sip=1
# https://aur.archlinux.org/packages/ros-melodic-qt-gui-cpp/

n=0
until [ $n -ge 10 ]
do
	echo "make attempt on $(date)" | tee -a make_outputlog.txt
	sudo ./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release --install-space /opt/ros/kinetic | tee -a make_outputlog.txt
	if [ ${PIPESTATUS[0]} -eq 0 ]; then
		break
	else
		if [ $patch_qt_gui_cpp_sip -ne 0 ]; then
			# this patch can only be applied after CMAKE so we let the build fail at least one time before attempting again
			# https://aur.archlinux.org/packages/ros-melodic-qt-gui-cpp/
			echo "applying patch to patch_qt_gui_cpp_sip's makefile"
			sudo sed -i -e 's/\-l\-lpthread//g' ${ros_catkin_ws}/build_isolated/qt_gui_cpp/sip/qt_gui_cpp_sip/Makefile
		fi
	fi
	n=$[$n+1]
done

cd ${BASEDIR}
./source_ros.sh

touch build_ros.done
