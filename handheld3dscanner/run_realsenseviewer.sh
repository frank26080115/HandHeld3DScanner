#!/bin/bash

#realsense-viewer
# this app takes up too much screen space
# we have an alternative

save_dir=~/pointcloud_saves
mkdir -p $save_dir

# check if an external disk is attached
ext_disk=$(ls /media/pi | head -n1)
if [ ! -z "$ext_disk" ]; then
	tmp_dir=/media/pi/$ext_disk
	if [ -d "$tmp_dir" ]; then
		save_dir="/media/pi/$ext_disk/pointcloud_saves"
		mkdir -p "$save_dir"
	fi
fi
# note: if you are having trouble with attaching exFAT drives, try running
# sudo apt-get install -y exfat-fuse exfat-utils
# and also try to format the drive with a name that doesn't contain spaces

save_path="$save_dir/pointcloud-$(date +%Y%m%d-%H%M%S).bag"

rs-pointcloud "$save_path"
# we have modifications to the rs-pointcloud app that allows it to save while running
