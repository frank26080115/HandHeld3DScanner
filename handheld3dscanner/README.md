This directory contains multiple scripts and supporting files that will automate the installation of

 * librealsense2
 * ROS Kinetic Desktop
 * RTAB-Map

... onto a Raspberry Pi 4 Model B (4GB RAM) running Raspbian Buster (kernel 4.19)

(no other systems have been tested, because no other Raspberry Pi systems have USB 3 ports that are required for Intel RealSense cameras)

These packages are mostly built and installed from source, which avoids me having to package binaries (and violating any copyrights), but takes a long time and requires an internet connection.

Dependancies that can be obtained from repositories are installed from apt-get whenever they are compatible to save time.

Common errors that occur during the build process are resolved automatically through patch files and bash scripting.

The installation script does NOT:

 * add the icons to the LXDE desktop or task bar, but it makes the menu item available to be added
 * setup the HyperPixel display
 * modify the boot config file
 * apply UVC patches to the kernel (the Intel RealSense camera cannot work as a webcam because of this, sorry)

Installation Instructions
=========================

You may simply use git to clone this repository, and run `./install.sh` from a terminal or SSH.

Or copy this `handheld3dscanner` directory (case sensitive!), upload it somewhere to the Pi, and run `./install.sh` from a terminal or SSH.

`./install.sh` needs execute permissions! Use the terminal command `cd` to change directory into `handheld3dscanner`, then run the terminal command `chmod +x install.sh`.

Before you start though, make sure you've used `sudo raspi-config` to configure your system first, expand the file-system size, and setup networking as appropriate.

Usage Instructions
==================

From a terminal on the LXDE desktop, run the command `realsense-viewer` to simply test your sweet new Intel RealSense camera. Any of the Intel examples should work. You may try to save the recordings as ROS bags and replay them on inside ROS later.

From a terminal on the LXDE desktop, run the command `rtabmap` to run SLAM and odometry. If you save the rtabmap database file, you can use the database viewer and other tools later to generate a 3D model of your 3D scan.

These commands are also added to the LXDE "start menu" and so you may also pin them to the application bar. I don't have a good way of automatically doing this for you because the config file for it is not easy to work with.

Obviously, the GUI tools will not work through SSH! Also I have had trouble running them with a headless virtual VNC desktop.

Using `roslaunch` on the `realsense2_camera` launch files does not work right now. `rtabmap` will crash internally, so even `rviz` won't be able to work. Sorry!

Notes and Caveats
=================

The script is designed to be run from a clean Raspbian Buster Desktop installation. If you are not using a clean installation, there are small chances that other packages installed on your system may interfere with the building of the source packages. For example, the `CMakeLists.txt` file that most of these source packages use will automatically look for additional SLAM or mathematics libraries on your system and automatically link against them during the build, but if the libraries are incompatible, the final built executable may crash!

A stable internet connection is required at all times during this build! `git`, `wget`, and `apt-get` are automatically called throughout the entire process.

The installation is designed to be continued if it becomes interrupted, simply run `./install.sh` again to continue. However, this may not work perfectly depending on how screwed up a power-loss left your Pi.

This entire installation takes an entire day! Make sure your power supply and internet connection is ready for it. The CPU will also run at its fastest speed when it is kept cool.

Most of the longer build processes will generate a log file because the terminal screen will fill up. Use these log files to troubleshoot.

Modifications
=============

The scripts in here are heavily commented, it should be easy for you to enable other features inside RTAB-Map later, by installing additional dependancies and changing cmake parameters.

OpenCV 3.3 is already built with almost all of the possible additional modules, even the non-free ones.

If `roslaunch` can work, then it would skip a lot of button clicking from within the GUI, as more bash scripts can be used instead of button clicks.
