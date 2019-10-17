#!/usr/bin/python3

import pyrealsense2 as rs

ctx = rs.context()
devices = ctx.query_devices()
for dev in devices:
    s = str(dev)
    dev.hardware_reset()
    print("reset: %s" % s)

# sometimes, something goes wrong and the only fix is to unplug the camera
# but since that's impossible while the whole camera is enclosed in the box
# the other solution is to power-down the entire raspberry pi instead
# which is super time consuming
# so here, we have a simple script to issue the camera a hardware reset command

