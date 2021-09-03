function stat_table = tracks2tableStat(track_array,vid_id,track_length_thresh,stereoParams)
% Calculate group statistics from a cell array of tracks
% INPUT:
%   - track_array = a cell array of tracks
%   - vid_id = offset for video id x 1000
%   - track_length_thresh = minimum number of track length to be considered
%       in frames
%   - stereoParams = struct of stereo parameters (MATLAB format)
% OUTPUT:
%   - stat_table = a table containing group statistics for each track

% output arrays
body_array = []; % [track id, body length, reprojection error, angle]
dist_array = []; % [track id, dist]

for track_num=1:1:length(track_array)
    track = track_array{track_num};
    % check whether track is longer than threshold
    if track.age<track_length_thresh
        continue;
    end
    
    % find body length and add to the output array
    body_ellip = bodyLengthCalc(track.ellip,stereoParams);
    id_array = ones(size(body_ellip,1),1)*(track.id+vid_id*1000);
    add_array = cat(2,id_array,body_ellip);
    body_array = cat(1,body_array,add_array);
    
    % find distance
    dist = trackDist(track);
    id_array = ones(size(dist,1),1)*(track.id+vid_id*1000);
    add_array = cat(2,id_array,dist);
    dist_array = cat(1,dist_array,add_array);
end

% convert from array to table for group statistic calculation
dist_table = array2table(dist_array,'VariableNames',{'TrackID','Displacement'});
body_table = array2table(body_array,'VariableNames',...
    {'TrackID','BodyLength','Error','Angle'});
    

% calculate group statistics
dist_stat = grpstats(dist_table,'TrackID',{'mean','std','median',...
    'min','max'});
body_stat = grpstats(body_table,'TrackID',{'mean','std','median',...
    'min','max'},...
    'DataVars','BodyLength');
% combine two tables together
stat_table = join(dist_stat,body_stat,'Key','TrackID');
