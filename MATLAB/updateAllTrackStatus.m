function track_cell = updateAllTrackStatus(track_cell,max_invis)
% Update the status of all the tracks in the cell to be
% inactive if inivisible count exceeds the max
% INPUT:
%   - track_cell = a cell array of tracks
%   - max_invis = the value of maximum broken frames before tracks are
%       considered ended
% OUTPUT:
%   - track_cell = a cell array of tracks with updated track status

for k=1:1:length(track_cell)
    track = track_cell{k};
    if track.consecutiveInvisibleCount > max_invis
        track.active = 0;
    end
    track_cell{k} = track;
end