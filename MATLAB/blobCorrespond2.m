function [centOut,bbOut,ind1,ind2]=blobCorrespond2(mask1,mask2,err_thresh,stereoParams)
% perform blob correspondence between two stereoviews
% INPUT:
%   mask1 = (boolean matrix) the binary mask from left view
%   mask2 = (boolean matrix) the binary mask from right view
%   err_thresh = (double) threshold of reprojection error to correspond
%       blobs in pixel
%   stereoParams = (struct) stereo parameters in MATLAB format (see stereo
%       calibration)
% OUTPUT:
%   centOut = (3xNx2 double matrix; N = number of corresponded blobs) on each page, 
%       each row is the centroid in 3D (x,y,z). Page one is for left view and
%       page tow is for right view.
%   bbOut = (4xNx2 double matrix; N = number of corresponded blobs) on each
%       page each row is the boudning box of the corresponded blobs in the
%       format [x of top left corner, y of top left corner, x width, y width]
%   ind1 = (double 1D array) the array of indices of corresponded blobs on
%       the left view
%   ind2 = (double 1D array) the array of indices of corresponded blobs on
%       the right view
%   
s1  = regionprops(mask1,{'Orientation', 'MajorAxisLength', ...
    'MinorAxisLength', 'Centroid','Area','BoundingBox'});
s2  = regionprops(mask2,{'Orientation', 'MajorAxisLength', ...
    'MinorAxisLength', 'Centroid','Area','BoundingBox'});

cent1 = cat(1,s1.Centroid);
cent2 = cat(1,s2.Centroid);

% output arrays of valid centroid with correspondence
valid_cent1 = [];
valid_cent2 = [];
% output of valid bounding boxes
bb1 = [];
bb2 = [];
% output of valid indices
ind1 = [];
ind2 = [];

% if either view is empty
% then just write video
if isempty(cent1)||isempty(cent2) 
    centOut = cat(3,valid_cent1,valid_cent2);
    bbOut = cat(3,bb1,bb2);
    return;
end
    
% for k =1
for k =1:1:size(cent1,1)
    row = cent1(k,:); % row of interest
    repRow = row(ones(1,size(cent2,1)),:); % duplicate to match cent2
    % perform 3D triangulation
    [~,err] = triangulate(repRow,cent2,stereoParams);
    % find the minimum error point from right view
    [err_min,ind] = min(err);
    
    % if the minimum error is greater than max error
    % skip this point (no match on the right view)
    if err_min > err_thresh
        continue;
    end
    
    % if correspondence is found, then store the centroid and boudnig box
    valid_cent1 = cat(1,valid_cent1,cent1(k,:));
    valid_cent2 = cat(1,valid_cent2,cent2(ind,:));
    bb1 = cat(1,bb1,s1(k).BoundingBox);
    bb2 = cat(1,bb2,s2(ind).BoundingBox);
    ind1 = cat(1,ind1,k);
    ind2 = cat(1,ind2,ind);
end

% outputs
centOut = cat(3,valid_cent1,valid_cent2);
bbOut = cat(3,bb1,bb2);