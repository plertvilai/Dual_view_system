# Dual-View Underwater Imaging System
This repository contains programming scripts associated with the dual-view underwater imaging system. Note that this repository only contains Python scripts for controlling the main computer of the instrument (a Raspberry Pi) during the deployment and MATLAB scripts for analyzing the data. The instruction for building the physical system can be found in this accompanying [repository](https://github.com/plertvilai/IPAX). 

## Python Code for Raspberry Pi
The folder RaspberryPi contains Python code for Raspberry Pi that is used during field deployment. The code is tested on Raspberry Pi 4B (4GB RAM) that runs on the official Raspberry Pi operating system (v.10) with Python 3.7.3. All Python packages necessary for the code is pre-installed with the Raspberry Pi OS, and there is no need to install any additional packages. 
There are two files in the folder:
- `dIPAX_hat.py` is the library containing all necessary functions that allows a Raspberry Pi to control the stereo synchronization board (from Arducam).
- `dIPAX_deploy.py` is the code to be run during a deployment. Deployment parameters, such as time interval between image acquisition, can be modified in this script.

## MATLAB Code for Data Analysis
The folder MATLAB contains MATLAB code for analyzing data from field deployments. All scripts were tested with MATLAB v.2020a. Note that to run the example code, the computer needs more than 16GB of RAM because it needs to store frames from a video onto the RAM. 
The main files in this folder are:
- `tracking_example.m` is the main analysis script that can be run. It contains scripts to perform organism tracking based on the given example video and also to visualize the tracking results. 
- `1625532935.mp4` is an example video file for organism tracking.
- `stereoParameters.mat` is a MATLAB data file containing the stereo parameters from the stereo calibration. The variable stereoParams is a struct containing all parameters (see [MATLAB Website](https://www.mathworks.com/help/vision/ref/stereoparameters.html)) for more details.
- The rest are MATLAB helper functions that are used in `tracking_example.m`. The description of each function is given at the beginning of each function file. 