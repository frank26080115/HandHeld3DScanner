#!/bin/bash -e

hh3s=~/handheld3dscanner
export hh3s

mkdir -p ${hh3s} && cd ${hh3s}

[ ! -f ${hh3s}/addswapspace.done       ] && ./add_swap_space.sh
[ ! -f ${hh3s}/build_librealsense.done ] && ./build_librealsense.sh
[ ! -f ${hh3s}/build_opencv3.done      ] && ./build_opencv3.sh
[ ! -f ${hh3s}/build_gtsam.done        ] && ./build_gtsam.sh
[ ! -f ${hh3s}/build_cvsba.done        ] && ./build_cvsba.sh
[ ! -f ${hh3s}/build_g2o.done          ] && ./build_g2o.sh
[ ! -f ${hh3s}/build_libpcl17.done     ] && ./build_libpcl17.sh
[ ! -f ${hh3s}/build_rtabmap.done      ] && ./build_rtabmap.sh

echo "this installation script has finished"
