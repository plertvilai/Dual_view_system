#!/usr/bin/python

# Dual-view system deployment script
# P. Lertvilai
# Feb, 2021

import os
import time
import RPi.GPIO as GPIO
import datetime

from dIPAX_hat import *

# Printing to Log file
print("dIPAX Deploy Script")
print("Program starts at %d timestamp"%time.time())

directory = "/home/pi/dualCam/" # main directory
logFile = "dIPAX_status.log"

#initialize dIPAX camera system
ipax = dIPAX(directory,shutter=500,iso=100) 
ipax.initialize()

# GPIO Setup
img_pin = 6 # input pin from switch; only take images if this pin is HIGH
GPIO.setmode(GPIO.BCM)
GPIO.setup(img_pin, GPIO.IN)

# deployment parameters
ntime_vid_int = 10 # interval between video during night time in MINUTES
tdelay = 3 # delay between each image acquisition in SECONDS	

# time keeping variables
tnow = datetime.datetime.now() # get current time in datetime format
hprev = tnow.hour-1 # previous hour; -1 to allow first run to take picture
unixPrev = time.time() # store previous timestamp
vidTime = time.time()

print("Begin main loop")

first = True # for first video record

# error flag
tout_flag = True # timeout
file_flag = True # file not exist
size_flag = True # invalid file size

# main loop of program
while(1):
	if not (GPIO.input(img_pin)): # if imaging pin is not HIGH, then do nothing
		time.sleep(5)
		continue

	tnow = datetime.datetime.now() # get current time in datetime format
	hnow = tnow.hour # get current hour in 24 hour format
	unixNow = time.time() # get current timestamp

	print("Time: %d:%d"%(tnow.hour,tnow.minute))

	# show error in console
	if not (tout_flag and file_flag and size_flag):
		print("-------------------------------------------")
		print("----------------ERROR----------------------")
		print("-------------------------------------------")

	if first: # first time to run, take video
		print("Taking video...")
		ipax.updateTime() #update time
		tout_flag = ipax.takeVideo(60000) # take 60s video
		file_flag,size_flag = ipax.checkOutput() # check whether output file is valid
		status_string = "%.1f,%d,%d,%d,%d,%d\n"%(ipax.time,ipax.mode,ipax.error,tout_flag,file_flag,size_flag)
		ipax.recordStat(status_string,logFile)
		ipax.addError(not (tout_flag and file_flag and size_flag))
		first = False # reset first flag
		vidTime = time.time()

	if time.time()-vidTime > ntime_vid_int*60: # if time has passed since last video
		print("Taking video...")
		ipax.updateTime() #update time
		tout_flag = ipax.takeVideo(60000) # take 60s video
		file_flag,size_flag = ipax.checkOutput() # check whether output file is valid
		status_string = "%.1f,%d,%d,%d,%d,%d\n"%(ipax.time,ipax.mode,ipax.error,tout_flag,file_flag,size_flag)
		ipax.recordStat(status_string,logFile)
		ipax.addError(not (tout_flag and file_flag and size_flag))
		vidTime = time.time()

	else:
		print("Taking picture...")
		ipax.updateTime() #update time
		tout_flag = ipax.takePicture() # take 60s video
		file_flag,size_flag = ipax.checkOutput() # check whether output file is valid
		status_string = "%.1f,%d,%d,%d,%d,%d\n"%(ipax.time,ipax.mode,ipax.error,tout_flag,file_flag,size_flag)
		ipax.recordStat(status_string,logFile)
		ipax.addError(not (tout_flag and file_flag and size_flag))
		time.sleep(tdelay)
