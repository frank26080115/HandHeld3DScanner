#!/bin/bash -e

BASEDIR=$(cd $(dirname "$0"); pwd)

DESKTOPDIR=/usr/share/applications
DESKTOPNAME=realsenseviewer.desktop

echo "writing into ${DESKTOPDIR}/$DESKTOPNAME"

str="echo \"[Desktop Entry]\" > ${DESKTOPDIR}/$DESKTOPNAME"
sudo sh -c "$str"
str="echo \"Name=RealSense-Viewer\" >> ${DESKTOPDIR}/$DESKTOPNAME"
sudo sh -c "$str"
str="echo \"Comment=RealSense-Viewer for Intel RealSense cameras\" >> ${DESKTOPDIR}/$DESKTOPNAME"
sudo sh -c "$str"
str="echo \"Exec=${BASEDIR}/run_realsenseviewer.sh\" >> ${DESKTOPDIR}/$DESKTOPNAME"
sudo sh -c "$str"
if [ -f ${BASEDIR}/realsenseviewer_icon.png ] ; then
	str="echo \"Icon=${BASEDIR}/realsenseviewer_icon.png\" >> ${DESKTOPDIR}/$DESKTOPNAME"
else
	ico_path=${BASEDIR}/librealsense/tools/realsense-viewer/res/icon.ico
	do_convert=1
	if [ $do_convert -ne 0 ]; then
		# ICO files are a Windows standard
		# chances are, it's not supported
		# we install and use a converter tool called icotool on the icon to get a PNG
		sudo apt-get install -y icoutils
		rsvicons_dir=${BASEDIR}/realsenseviewer_extracted_icons
		mkdir -p ${rsvicons_dir} && cd ${rsvicons_dir}
		icotool -x ${ico_path}
		# change the file name to something else if we need to
		str="echo \"Icon=${rsvicons_dir}/icon_4_48x48x32.png\" >> ${DESKTOPDIR}/$DESKTOPNAME"
	else
		str="echo \"Icon=${ico_path}\" >> ${DESKTOPDIR}/$DESKTOPNAME"
	fi
fi
sudo sh -c "$str"
str="echo \"Terminal=false\" >> ${DESKTOPDIR}/$DESKTOPNAME"
sudo sh -c "$str"
str="echo \"Type=Application\" >> ${DESKTOPDIR}/$DESKTOPNAME"
sudo sh -c "$str"
str="echo \"Categories=AudioVideo;Player;Recorder;\" >> ${DESKTOPDIR}/$DESKTOPNAME"
sudo sh -c "$str"
