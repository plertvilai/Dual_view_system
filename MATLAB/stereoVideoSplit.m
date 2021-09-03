function [I1,I2]=stereoVideoSplit(im,stereoParams)
% Split the raw image from vidoe into separate views
% and then undistort each image using the camera parameters
% INPUT:
%   - im = MxNx3 RGB image
%   - stereoParams = struct of stereo parameters (MATLAB format)
% OUTPUT:
%   - I1 = MxN grayscale image of left view
%   - I2 = MxN grayscale image of right view

% obtain image size from stereo parameters
imSize = stereoParams.CameraParameters1.ImageSize;
% since the image is binned horizontally by a factor of two,
% we need to double the x pixel first
imSize_full = [imSize(1),imSize(2)*2];
left_crop = [1,1,imSize(2)-1,imSize(1)-1];
right_crop = [imSize(2)+1,1,imSize(2)*2-1,imSize(1)-1];

img = rgb2gray(im);
imr = imresize(img,imSize_full);
left_im = imcrop(imr,left_crop);
right_im = imcrop(imr,right_crop);

I1 = undistortImage(left_im,stereoParams.CameraParameters1);
I2 = undistortImage(right_im,stereoParams.CameraParameters2);