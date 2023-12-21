#!/bin/bash -e

BASEDIR=$(cd $(dirname "$0"); pwd)
ros_catkin_ws=~/ros_catkin_ws

cd ${BASEDIR}
./bashrc_ldlibpath.sh

if [ ! -d ${ros_catkin_ws}/src ]; then

	# all instructions from http://wiki.ros.org/ROSberryPi/Installing%20ROS%20Kinetic%20on%20the%20Raspberry%20Pi

	echo -e "\e[32m setting up keys to securely obtain ROS packages \e[0m"

	sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116

	echo -e "\e[32m updating apt cache and upgrading all packages \e[0m"
	sudo apt-get update && sudo apt-get upgrade -y

	echo -e "\e[32m installing the first few ROS tools \e[0m"
	sudo apt-get install -y python-rosdep python-rosinstall-generator python-wstool python-rosinstall

	echo -e "\e[32m initializing rosdep and updating it \e[0m"
	sudo rosdep init || true
	rosdep update || true

	mkdir -p ${ros_catkin_ws} && cd ${ros_catkin_ws}

	skip_collada_urdf=1
	skip_collada_urdf_str=''
	if [ $skip_collada_urdf -ne 0 ]; then
		echo "skipping the collada_urdf package"
		skip_collada_urdf_str='--exclude collada_parser collada_urdf'
	fi

	echo -e "\e[32m running rosinstall_generator and initializing workspace\e[0m"
	rosinstall_generator desktop geometry2 roscpp diagnostic_updater rtabmap_ros random_numbers --rosdistro kinetic --deps --wet-only ${skip_collada_urdf_str} --tar > kinetic-desktop-wet.rosinstall
	wstool init src kinetic-desktop-wet.rosinstall
	# use
	# wstool update -j4 -t src
	# if the update is interrupted
else
	echo -e "\e[33m the src directory in the workspace already exists, skipping wstool init, attempting wstool update instead \e[0m"
	cd ${ros_catkin_ws}
	wstool update -j4 -t src
fi

if [ ! -f ${ros_catkin_ws}/rosdep.done ]; then

	install_assimp=0
	if [ $install_assimp -ne 0 ]; then
		# warning: this bit of script code has not been tested
		echo -e "\e[32m preemptively installing assimp so that the collada_urdf package successfully builds \e[0m"
		mkdir -p ${ros_catkin_ws}/external_src cd ${ros_catkin_ws}/external_src
		wget http://sourceforge.net/projects/assimp/files/assimp-3.1/assimp-3.1.1_no_test_models.zip/download -O assimp-3.1.1_no_test_models.zip
		unzip assimp-3.1.1_no_test_models.zip
		cd assimp-3.1.1
		cmake .
		make
		sudo make install
		cd ${ros_catkin_ws}
	fi

	cd ${ros_catkin_ws}

	echo -e "\e[32m installing a lot of required packages \e[0m"

	sudo apt-get remove -y libvtk7-dev libvtk7-qt-dev
	#rosdep install -y --from-paths src --ignore-src --rosdistro kinetic -r --os=debian:buster
	# rosdep will want to install vtk6, but if this script is running after vtk7 is installed, it will fail
	# so we remove vtk7 before doing rosdep install
	# vtk7 will be installed again later on in the script

	# the below commands are extracted from the rosdep execution
	sudo -H apt-get install -y libapr1-dev libaprutil1-dev
	sudo -H apt-get install -y libassimp-dev
	sudo -H apt-get install -y libbullet-dev
	sudo -H apt-get install -y libbz2-dev liblz4-dev
	sudo -H apt-get install -y libconsole-bridge-dev libcppunit-dev sbcl
	sudo -H apt-get install -y libeigen3-dev
	sudo -H apt-get install -y libgl1-mesa-dev libglu1-mesa-dev libogre-1.9-dev
	sudo -H apt-get install -y google-mock liblog4cxx-dev libgtest-dev
	sudo -H apt-get install -y libpoco-dev libcurl4-openssl-dev
	sudo -H apt-get install -y libprotobuf17 libprotobuf-dev libprotoc-dev protobuf-compiler
	sudo -H apt-get install -y libtiff5-dev libjpeg-dev libwebp-dev
	sudo -H apt-get install -y libtinyxml2-dev libtinyxml-dev libyaml-cpp-dev
	sudo -H apt-get install -y liburdfdom-dev liburdfdom-headers-dev liburdfdom-tools
	sudo -H apt-get install -y libv4l-dev libavcodec-dev libavformat-dev libavutil-dev libswscale-dev 
	sudo -H apt-get install -y python-coverage python-defusedxml python-empy python-matplotlib python-netifaces python-nose python-opengl python-paramiko python-psutil python-pydot python-pygraphviz graphviz
	sudo -H apt-get install -y python-sip-dev
	sudo -H apt-get install -y python-wxtools
	sudo -H apt-get install -y qt5-qmake qtbase5-dev libqt5opengl5 libqt5opengl5-dev pyqt5-dev python-pyqt5 python-pyqt5.qtopengl python-pyqt5.qtsvg python-pyqt5.qtwebkit
	sudo -H apt-get install -y libsdl-image1.2-dev libsdl1.2-dev
	sudo -H apt-get install -y tango-icon-theme
	sudo -H apt-get install -y uuid-dev hddtemp
	sudo -H apt-get install -y libboost-all-dev

	echo -e "\e[32m getting package \"ddynamic_reconfigure\" \e[0m"
	cd ${ros_catkin_ws}/src
	if [ ! -d ${ros_catkin_ws}/src/ddynamic_reconfigure ]; then
		git clone https://github.com/pal-robotics/ddynamic_reconfigure.git
		cd ddynamic_reconfigure
	else
		cd ${ros_catkin_ws}/src/ddynamic_reconfigure
		git reset --hard HEAD
	fi
	git checkout -f kinetic-devel

	cd ${ros_catkin_ws}

	touch rosdep.done

	echo -e "\e[32m rosdep finished, files available for patching \e[0m"

fi

# we only included rtabmap_ros for automatic dependancy fetching, but we don't actually want to build it yet
[ -d ${ros_catkin_ws}/src/rtabmap_ros ] && sudo rm -rf ${ros_catkin_ws}/src/rtabmap_ros
[ -d ${ros_catkin_ws}/src/rtabmap ] && sudo rm -rf ${ros_catkin_ws}/src/rtabmap

cd ${ros_catkin_ws}

patch_opencv3_cv2cpp=1
if [ $patch_opencv3_cv2cpp -ne 0 ]; then
	echo -e "\e[32m applying patch to opencv3's cv2.cpp \e[0m"
	[ ! -f ${BASEDIR}/patchros_opencv3_cv2cpp.patch ] && echo -e "\e[31m patch file missing \e[0m" && exit 1
	[ ! -f ${BASEDIR}/patchros_opencv3_cv2cpp.patch.done ] && patch -f ${ros_catkin_ws}/src/opencv3/modules/python/src2/cv2.cpp < ${BASEDIR}/patchros_opencv3_cv2cpp.patch || true
	# https://github.com/opencv/opencv/issues/14856#issuecomment-504416696
	echo "patch command may have failed if it was already applied, so don't worry"
	touch ${BASEDIR}/patchros_opencv3_cv2cpp.patch.done
fi

patch_opencv3_cmakeliststxt=1
if [ $patch_opencv3_cmakeliststxt -ne 0 ]; then
	echo -e "\e[32m applying patch to opencv3's cv2.cpp \e[0m"
	[ ! -f ${BASEDIR}/patchros_opencv3_cmakeliststxt.patch ] && echo -e "\e[31m patch file missing \e[0m" && exit 1
	[ ! -f ${BASEDIR}/patchros_opencv3_cmakeliststxt.patch.done ] && patch -f ${ros_catkin_ws}/src/opencv3/CMakeLists.txt < ${BASEDIR}/patchros_opencv3_cmakeliststxt.patch || true
	# this patch enables non-free modules like SIFT and SURF, as well as disables problematic modules
	echo "patch command may have failed if it was already applied, so don't worry"
	touch ${BASEDIR}/patchros_opencv3_cmakeliststxt.patch.done
fi

patch_geometry2_buffercorecpp=1
if [ $patch_geometry2_buffercorecpp -ne 0 ]; then
	echo -e "\e[32m applying patch to geometry2's buffer_core.cpp \e[0m"
	[ ! -f ${BASEDIR}/patchros_geometry2_buffercorecpp.patch ] && echo -e "\e[31m patch file missing \e[0m" && exit 1
	[ ! -f ${BASEDIR}/patchros_geometry2_buffercorecpp.patch.done ] && patch -f ${ros_catkin_ws}/src/geometry2/tf2/src/buffer_core.cpp < ${BASEDIR}/patchros_geometry2_buffercorecpp.patch || true
	# https://github.com/ros/console_bridge/issues/56 and https://github.com/ros/ros-overlay/issues/509
	echo "patch command may have failed if it was already applied, so don't worry"
	touch ${BASEDIR}/patchros_geometry2_buffercorecpp.patch.done
fi

patch_rospack=0
if [ $patch_rospack -ne 0 ]; then
	# the problem is that we need ROS Kinetic because it's the only one supported for our use case
	# rospack for Kinetic was written for libboost 1.58, the build will fail if we use any newer versions of libboost
	# but so many dependancies are using the newer libboost and having the older one causes problems in the rtabmap build
	# the solution is to use git to update rospack to the latest Melodic version instead
	sudo rm -rf ${ros_catkin_ws}/src/rospack
	cd ${ros_catkin_ws}/src
	git clone https://github.com/ros/rospack.git
	cd rospack
	git checkout melodic-devel
	cd ${ros_catkin_ws}
fi

install_extras=1
if [ $install_extras -ne 0 ]; then
	# these optional packages are linked to by OpenCV, enabling more features
	echo -e "\e[32m installing more packages from apt-get \e[0m"
	sudo apt-get install -y libeigen3-dev
	sudo apt-get install -y f2c libf2c2-dev libflann-dev libblas-dev libopenblas-dev liblapack-dev liblapacke-dev libtbb2 libtbb-dev libatlas-base-dev
	sudo apt-get install -y libxvidcore-dev libx264-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
	sudo apt-get install -y libdc1394-22-dev libxine2-dev libv4l-dev libavresample-dev
	sudo apt-get install -y libgoogle-glog-dev libceres-dev libglew-dev
	# --dry-run shows these do not cause conflicts
	# warning: libflann depends on the latest libboost
fi

install_libpcl_apt=1
if [ $install_libpcl_apt -ne 0 ]; then
	echo -e "\e[32m ensuring PCL and VTK packages are correct \e[0m"
	sudo apt-get remove -y libvtk6-dev libvtk6-qt-dev
	sudo apt-get install -y libvtk7-dev libvtk7-qt-dev
	sudo apt-get install -y libpcl-dev
fi

cd ${ros_catkin_ws}

patch_qt_gui_cpp_sip=1
# https://aur.archlinux.org/packages/ros-melodic-qt-gui-cpp/
# the makefile we have to match doesn't exist yet, but if it does, it means the previous build has failed, so patch it now
if [ $patch_qt_gui_cpp_sip -ne 0 ] && [ -f ${ros_catkin_ws}/build_isolated/qt_gui_cpp/sip/qt_gui_cpp_sip/Makefile ]; then
	# this patch can only be applied after calling cmake on qt_gui_cpp, if it happens here it means the script has paused and restarted
	# https://aur.archlinux.org/packages/ros-melodic-qt-gui-cpp/
	echo "applying patch to patch_qt_gui_cpp_sip's makefile"
	sudo sed -i -e 's/\-l\-lpthread//g' ${ros_catkin_ws}/build_isolated/qt_gui_cpp/sip/qt_gui_cpp_sip/Makefile
fi

# I've noticed some failures in catkin_make_isolated that might suggest we need to watch out for permission issues
# the hack below is a nuclear solution
install_dir=/opt/ros/kinetic
sudo mkdir -p /opt && sudo mkdir -p /opt/ros && sudo mkdir -p /opt/ros/kinetic
if [ -d ${install_dir} ] ; then
	sudo chown -R $(id -u):$(id -g) ${install_dir}
	sudo chmod -R ugo+rw ${install_dir}
fi
if [ -d ${ros_catkin_ws}/build_isolated ] ; then
	sudo chown -R $(id -u):$(id -g) ${ros_catkin_ws}/build_isolated
	sudo chmod -R ugo+rw ${ros_catkin_ws}/build_isolated
fi
if [ -d ${ros_catkin_ws}/devel_isolated ] ; then
	sudo chown -R $(id -u):$(id -g) ${ros_catkin_ws}/devel_isolated
	sudo chmod -R ugo+rw ${ros_catkin_ws}/devel_isolated
fi

sudo rm make_outputlog.txt || true
# the build output tends to be extra long and with multiple build threads, errors might be hard to find on the terminal screen
# we tee everything to a log file to solve this
exec > >(tee -i make_outputlog.txt)

n=0
until [ $n -ge 10 ]
do
	catkin_failed=0
	echo -e "\e[32m calling catkin_make_isolated on $(date) \e[0m"
	if sudo ./src/catkin/bin/catkin_make_isolated --install                                                \
                                                  -DCATKIN_ENABLE_TESTING=False                            \
                                                  -DCMAKE_BUILD_TYPE=Release                               \
                                                  -DBoost_USE_STATIC_LIBS=ON                               \
                                                  -DBoost_NO_SYSTEM_PATHS=ON                               \
                                                  -DBOOST_LIBRARYDIR=${BASEDIR}/boost_1_58_0/stage/lib     \
                                                  -DBOOST_INCLUDEDIR=${BASEDIR}/boost_1_58_0               \
                                                  --install-space /opt/ros/kinetic                         \
                                                  -j4 2>&1 ; then
		echo -e "\e[32m catkin_make_isolated seems to have finished successfully \e[0m"
	else
		echo -e "\e[31m catkin_make_isolated seems to have finished and has a failure \e[0m"
		catkin_failed=1
	fi
	if [ $catkin_failed -ne 0 ] ; then
		if [ $patch_qt_gui_cpp_sip -ne 0 ] && [ -f ${ros_catkin_ws}/build_isolated/qt_gui_cpp/sip/qt_gui_cpp_sip/Makefile ] ; then
			# this patch can only be applied after calling cmake on qt_gui_cpp, so we let the build fail at least one time before attempting again
			# https://aur.archlinux.org/packages/ros-melodic-qt-gui-cpp/
			echo -e "\e[33m applying patch to patch_qt_gui_cpp_sip's makefile \e[0m"
			sudo sed -i -e 's/\-l\-lpthread//g' ${ros_catkin_ws}/build_isolated/qt_gui_cpp/sip/qt_gui_cpp_sip/Makefile
		else
			echo -e "\e[31m unable to apply patch for qt_gui_cpp_sip/Makefile \e[0m" && exit 1
		fi
		sudo chown -R $(id -u):$(id -g) ${install_dir}
		sudo chown -R $(id -u):$(id -g) ${ros_catkin_ws}/build_isolated
		sudo chown -R $(id -u):$(id -g) ${ros_catkin_ws}/devel_isolated
		sudo chmod -R ugo+rw ${install_dir}
		sudo chmod -R ugo+rw ${ros_catkin_ws}/build_isolated
		sudo chmod -R ugo+rw ${ros_catkin_ws}/devel_isolated
	else
		echo -e "\e[32m catkin_make_isolated seems to have succeeded \e[0m"
		break
	fi
	n=$[$n+1]
	[ $n -ge 10 ] && exit 1
done

[ $catkin_failed -ne 0 ] && exit 1

cd ${BASEDIR}
touch build_ros.done