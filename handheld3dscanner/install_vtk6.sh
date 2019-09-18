#!/bin/bash -e

# we need vtk 6 for pcl 1.7, and we need pcl 1.7 for rtabmap, the most recent pcl doesn't play nicely with any of the rtabmap builds
# but a lot of recent packages pulls in vtk 7
# our trick is to remove vtk 7 and install vtk 6 right before when it is needed for a build

list7=$(apt list --installed | grep libvtk7 | head -n1)
list6=$(apt list --installed | grep libvtk6 | head -n1)

[ ! -z ${list7} ] && sudo apt-get remove -y libvtk7*
sudo apt-get install -y libvtk6-dev libvtk6.3 libvtk6-qt-dev python-vtk6

# this might pull in libboost1.67 when we really want 1.58 later, but since we are building and installing boost-1.58.0 from source, it will be fine