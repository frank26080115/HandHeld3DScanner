#!/bin/bash -e

BASEDIR=$(cd $(dirname "$0"); pwd)
ros_catkin_ws=~/ros_catkin_ws
extras_catkin_ws=~/extras_catkin_ws

cd ${BASEDIR}
source /opt/ros/kinetic/setup.bash

giturl=$1

# split the URL so we get the last part
urlparts=$(echo $giturl | tr "/" "\n")
for urlpart in $urlparts
do
    gitname=$urlpart
done
giturl="$giturl".git

branch=$2

mkdir -p ${extras_catkin_ws} && mkdir -p ${extras_catkin_ws}/src
if [ ! -d ${extras_catkin_ws}/src/catkin ]; then
	cp -rf ${ros_catkin_ws}/src/catkin ${extras_catkin_ws}/src/
fi

if [ -d ${extras_catkin_ws}/src/${gitname} ]; then
	cd ${extras_catkin_ws}/src/${gitname}
	echo -e "\e[32m resetting already existing $gitname \e[0m"
	git reset --hard HEAD
else
	echo -e "\e[32m cloning $gitname \e[0m"
	cd ${extras_catkin_ws}/src
	git clone $giturl
	cd ${extras_catkin_ws}/src/${gitname}
fi

if [ ! -z $2 ]; then
	git checkout $branch
	if [ -f ${BASEDIR}/patch_${gitname}_${branch}.patch ]; then
		echo -e "\e[32m applying patch to $gitname branch $branch \e[0m"
		git apply ${BASEDIR}/patch_${gitname}_${branch}.patch
	else
		if [ -f ${BASEDIR}/patch_${gitname}.patch ]; then
			echo -e "\e[32m applying patch to $gitname \e[0m"
			git apply ${BASEDIR}/patch_${gitname}.patch
		fi
	fi
else
	if [ -f ${BASEDIR}/patch_${gitname}.patch ]; then
		echo -e "\e[32m applying patch to $gitname \e[0m"
		git apply ${BASEDIR}/patch_${gitname}.patch
	fi
fi

has_fakepackagexml=$(sudo find ./  -maxdepth 2 -name 'package.xml.isfake' | grep 'package.xml.isfake') && true
if [ ! -z "$has_fakepackagexml" ]; then
	for i in $has_fakepackagexml ; do
		sudo rm -f $i
		sudo rm -f $(echo $i | sed "s/\.isfake//g")
	done
fi

has_packagexml=$(sudo find ./  -maxdepth 2 -name 'package.xml' | grep 'package.xml') && true
if [ -z "$has_packagexml" ] || [ ! -z "$has_fakepackagexml" ] ; then
	if [ -f ${BASEDIR}/packagexml_${gitname}.xml ]; then
		echo -e "\e[32m Adding missing package.xml to ${gitname} \e[0m"
		cp -f ${BASEDIR}/packagexml_${gitname}.xml ${extras_catkin_ws}/src/${gitname}/
		mv -f ${extras_catkin_ws}/src/${gitname}/packagexml_${gitname}.xml ${extras_catkin_ws}/src/${gitname}/package.xml
		touch ${extras_catkin_ws}/src/${gitname}/package.xml.isfake
	else
		has_manifestxml=$(sudo find ./ -maxdepth 2 -name 'manifest.xml' | grep 'manifest.xml') && true
		if [ -z "$has_manifestxml" ] ; then
			echo -e "\e[33m ${gitname} missing package.xml and manifest.xml without a patch to fix it. It will be skipped in the catkin build! \e[0m"
		else
			echo -e "\e[33m ${gitname} missing package.xml but has manifest.xml files \e[0m"
		fi
	fi
fi
