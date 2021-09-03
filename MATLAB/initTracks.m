function tracks = initTracks(id, cent, bbox_1,bbox_2,fcnt,feret,ellip)
% create an empty struct for a track
% see the comment for each parameters below for detail

tracks = struct(...
    'id', id, ...           % track id
    'centroid3', cent, ...    % an Nx3 matrix of centroid of track in 3d
    'bbox_1', bbox_1, ...       % an Nx4 matrix of bouding box on left view
    'bbox_2', bbox_2, ...       % an Nx4 matrix of bouding box on right view
    'age', 1, ...          % the total number of frames in this track (including invisible frames)
    'framestart', fcnt, ... % the first frame number in the video that this track appears
    'feret', feret, ...  % an Nx2 matrix of the end points of feret diameter in each frame
    'ellip', ellip, ...  % an Nx2 matrix of the end points of major axis of fitted ellipse in each frame
    'totalVisibleCount', 1, ... % number of total frames that the track has been invisible
    'active',1,...          % boolean indicating whether track is still active. becomes 0 when track ended.
    'consecutiveInvisibleCount', 0); % number of consecutive frames that the track has been invisible
