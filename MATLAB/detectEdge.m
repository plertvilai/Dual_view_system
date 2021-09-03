function mask = detectEdge(img_org,thresh,strelSize,sizeThresh)
% Perform full image processing on grayscale image. 
% The grayscale image should be undistorted before inputing into this function
% The processing steps are
%   1. Sobel edge detection
%   2. Morphological dilation
%   3. Morphological open
%   4. Size filtering
% INPUT:
%   img_org = (MxN uint8 matrix) Grayscale image
%   thresh = edge detection threshold for Sobel edge detector
%   strelSize = a 1x3 array containing the size of each structuring element
%       for morphological dilation in this order (all in pixels)
%       1. length of vertical line
%       2. length of horizontal line
%       3. radius of circle
%   sizeThresh = blob size threshold in pixels. Any blobs smaller than this value
%       will be deleted from the mask
% OUTPUT:
%   mask = (MxN boolean matrix) binary mask of detected objects
bwIm = img_org;

% find edge image
mask = edge(bwIm,'sobel',thresh);

% clean up edge
se90 = strel('line',strelSize(1),90);
se0 = strel('line',strelSize(1),0);
seC = strel('disk',strelSize(2));
BWsdil = imdilate(mask,[se90 se0,seC]);
BWdfill = imfill(BWsdil,'holes');

% clean up small parts with disk with the same area as size threshold
se2 = strel('disk',round(sqrt(sizeThresh/pi)));
mask0 = imopen(BWdfill,se2);

mask = bwareaopen(mask0,sizeThresh);