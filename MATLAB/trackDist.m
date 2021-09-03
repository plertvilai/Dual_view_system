function dist = trackDist(track)
% calculate the distance traveled by the object between frames 
% in the given track
% INPUT: 
%   track = a struct of a track
% OUTPUT:
%   dist = an array of distance the object traveled in the track
%       in the same unit as the centroid of the track (default mm).

cent = track.centroid3;
d = diff(cent); % find the difference between two consecutive position
dist = vecnorm(d,2,2); % find distance in mm