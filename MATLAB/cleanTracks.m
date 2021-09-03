function track_cell = cleanTracks(track_cell,max_invis)
% clean NaN from tracks
% INPUT:
%   track_cell = raw cell array of tracks from tracking functions which
%       contains NaN values
%   max_invis = the value of maximum broken frames before tracks are
%       considered ended
%  OUTPUT:
%   track_cell = cell array of tracks without NaN

for k=1:1:length(track_cell)
    track = track_cell{k};
    % if track is inactive, then we need to clean the end of the track
    % first
    if track.consecutiveInvisibleCount > max_invis
        track.centroid3 = track.centroid3(1:end-max_invis-1,:);
        track.bbox_1 = track.bbox_1(1:end-max_invis-1,:);
        track.bbox_2 = track.bbox_2(1:end-max_invis-1,:);
        track.ellip = track.ellip(:,:,1:end-max_invis-1);
        track.feret = track.feret(:,:,1:end-max_invis-1);
        track.age = track.age-max_invis-1;
    end
    % now fill NaN using linear interpolation
    track.centroid3 = fillmissing(track.centroid3,'linear');
    track.bbox_1 = fillmissing(track.bbox_1,'linear');
    track.bbox_2 = fillmissing(track.bbox_2,'linear');
    track.feret = fillmissing(track.feret,'linear',3);
    track.ellip = fillmissing(track.ellip,'linear',3);
    
    track_cell{k} = track;
end

