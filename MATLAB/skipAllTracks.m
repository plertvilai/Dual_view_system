function track_array = skipAllTracks(track_array)
% Add invisible count and NaN to all tracks in the track array
% Use this function in case there is no blob detected
% INPUT:
%   track_array = array of all tracks
% OUTPUT:
%   track_array = array of all tracks with invisible count added

for k=1:1:length(track_array)
    track = track_array{k};
    
    % for active tracks, we need to add an empty centroid
    % and a consecutive visible count
    if track.active==1
        track.centroid3 = cat(1,track.centroid3,[NaN,NaN,NaN]);
        track.ellip = cat(3,track.ellip,[NaN,NaN;NaN,NaN;NaN,NaN;NaN,NaN]);
        track.feret = cat(3,track.feret,[NaN,NaN;NaN,NaN;NaN,NaN;NaN,NaN]);
        track.bbox_1 = cat(1,track.bbox_1,[NaN,NaN,NaN,NaN]);
        track.bbox_2 = cat(1,track.bbox_2,[NaN,NaN,NaN,NaN]);
        track.age = track.age+1;
        track.consecutiveInvisibleCount = track.consecutiveInvisibleCount+1;
    end
    track_array{k} = track;
    % note that we do nothing to inactive tracks
end