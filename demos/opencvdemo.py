#!/usr/bin/python3

import pyrealsense2 as rs
import numpy as np
import cv2

import sys, os, datetime

def demo(args):

	save_to_files = False
	if len(args) > 0:
		a0 = args[0]
		a0 = a0.lower().strip()
		if a0 == "true" or a0 == "yes" or a0 == "y":
			save_to_files = True
		else:
			try:
				if int(a0) != 0:
					save_to_files = True
			except:
				pass

	windowname = 'RealSense'

	# Configure depth and color streams
	pipeline = rs.pipeline()
	config = rs.config()
	config.enable_stream(rs.stream.depth, 1280, 720, rs.format.z16, 30)
	config.enable_stream(rs.stream.color, 1280, 720, rs.format.bgr8, 30)

	# Fun fact: IR streams are not zero-indexed
	config.enable_stream(rs.stream.infrared, 1, 1280, 720, rs.format.y8, 30)
	config.enable_stream(rs.stream.infrared, 2, 1280, 720, rs.format.y8, 30)

	# Start streaming
	pipeline.start(config)

	now = None

	try:
		while True:

			# Wait for a coherent pair of frames: depth and color
			frames = pipeline.wait_for_frames()

			frm = frames.get_depth_frame()
			if frm is not None:
				depth_frame = frm
			frm = frames.get_color_frame()
			if frm is not None:
				color_frame = frm
			frm = frames.get_infrared_frame(1)
			if frm is not None:
				irleft_frame = frm
			frm = frames.get_infrared_frame(2)
			if frm is not None:
				irright_frame = frm
			if not depth_frame or not color_frame or not irleft_frame or not irright_frame:
				continue

			# Convert images to numpy arrays
			depth_image = np.asanyarray(depth_frame.get_data())
			color_image = np.asanyarray(color_frame.get_data())
			irleft_image = np.asanyarray(irleft_frame.get_data())
			irleft_image = np.stack((irleft_image,)*3, axis=-1) # mono to color conversion
			irright_image = np.asanyarray(irright_frame.get_data())
			irright_image = np.stack((irright_image,)*3, axis=-1) # mono to color conversion

			# Apply colormap on depth image (image must be converted to 8-bit per pixel first)
			depth_colormap = cv2.applyColorMap(cv2.convertScaleAbs(depth_image, alpha=0.03), cv2.COLORMAP_JET)

			if save_to_files:
				if now is None:
					now = datetime.datetime.now()
					dirpath = "imgrec_%04u%02u%02u%02u%02u%02u" % (now.year, now.month, now.day, now.hour, now.minute, now.second)
					dirpath = os.path.join(os.path.expanduser("~"), dirpath)
					saveidx = 0
					os.mkdir(dirpath)
					print("Saving to %s" % dirpath)

					dirpath_depth = os.path.join(dirpath, "depth")
					dirpath_color = os.path.join(dirpath, "color")
					dirpath_ir_left = os.path.join(dirpath, "ir_left")
					dirpath_ir_right = os.path.join(dirpath, "ir_right")
					os.mkdir(dirpath_depth)
					os.mkdir(dirpath_color)
					os.mkdir(dirpath_ir_left)
					os.mkdir(dirpath_ir_right)

				cv2.imwrite(os.path.join(dirpath_depth, "%08.jpg" % saveidx), depth_colormap)
				cv2.imwrite(os.path.join(dirpath_color, "%08.jpg" % saveidx), color_image)
				cv2.imwrite(os.path.join(dirpath_ir_left, "%08.jpg" % saveidx), irleft_image)
				cv2.imwrite(os.path.join(dirpath_ir_right, "%08.jpg" % saveidx), irright_image)
				saveidx += 1
			else:
				if now is not None:
					print("Stopping recording")
				now = None

			# Stack images together
			bottom_images = np.hstack((color_image, depth_colormap))
			top_images = np.hstack((irleft_image, irright_image))
			quad_images = np.vstack((top_images, bottom_images))

			# Resize to fit the tiny LCD screen we use
			resized_images = cv2.resize(quad_images,(715,402))

			# Show images
			cv2.namedWindow(windowname, cv2.WINDOW_AUTOSIZE)
			cv2.imshow(windowname, resized_images)
			k = cv2.waitKey(1) # this waits the minimum of 1ms
			# Check if window is closed
			if cv2.getWindowProperty(windowname, 0) < 0:
				break
				# this throws a few errors into stderr, we can't avoid it from here, sorry
			if k == ord('r'):
				save_to_files = True
			elif k == ord('s'):
				save_to_files = False
	finally:
		# Stop streaming
		pipeline.stop()

if __name__ == "__main__":
	args = sys.argv[1:]
	demo(args)
