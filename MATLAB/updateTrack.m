function track = updateTrack(track,cent, bbox_1,bbox_2,feret,ellip)
% update the track with new information to be stored
% if there is no new information, cent is empty and NaN will be used as a
% place holder instead.
% INPUT:
%   - track = a struct of a track
%   - cent = 1x3 array of centroid [x,y,z]
%   - bbox_1 = 1x4 array of bounding box on the left view in the format
%       [x top left, y top left, x width, y width]
%   - bbox_2 = 1x4 array of bounding box on the right view in the format
%       [x top left, y top left, x width, y width]
%   - feret = 4x2 array of end points of feret diameters from both views
%       [x end point 1 left view,y end point 1 left view
%       x end point 2 left view,y end point 2 left view
%       x end point 1 right view,y end point 1 right view
%       x end point 2 right view,y end point 2 right view]
%   - ellip = 4x2 array of end points of feret diameters from both views
%       same format as ellip
% OUTPUT:
%   - track = a struct of track with updated parameters

% if there is no new centroid to add, this means that the object 
% is not visible in this frame
if isempty(cent) 
    track.centroid3 = cat(1,track.centroid3,[NaN,NaN,NaN]);
    track.bbox_1 = cat(1,track.bbox_1,[NaN,NaN,NaN,NaN]);
    track.bbox_2 = cat(1,track.bbox_2,[NaN,NaN,NaN,NaN]);
    track.ellip = cat(3,track.ellip,[NaN,NaN;NaN,NaN;NaN,NaN;NaN,NaN]);
    track.feret = cat(3,track.feret,[NaN,NaN;NaN,NaN;NaN,NaN;NaN,NaN]);
    track.age = track.age+1;
    track.consecutiveInvisibleCount = track.consecutiveInvisibleCount+1;
else
    % if there is a new centroid, then add to track
    track.centroid3 = cat(1,track.centroid3,cent);
    track.bbox_1 = cat(1,track.bbox_1,bbox_1);
    track.bbox_2 = cat(1,track.bbox_2,bbox_2);
    track.ellip = cat(3,track.ellip,ellip);
    track.feret = cat(3,track.feret,feret);
    track.age = track.age+1;
    track.totalVisibleCount = track.totalVisibleCount+1;
    % also, need to reset the consecutive invisible count
    track.consecutiveInvisibleCount = 0;
end


