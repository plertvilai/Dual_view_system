function [all_tracks,analysis_time] = videoTracking(vidname,config, stereoParams)
% perform plankton tracking from a video
% INPUT:
% vidname = string of path to video file
% config = struct containing all configurations for the tracking
%       - err_thresh = correspondence error threshold in pixels
%       - dist_thresh = tracking error threshold in mm
%       - max_invis = tracking invisible max threshold
%       - adjust_range = image contrast adjustment [min, max] out of 255
%       - detection_params = parameters for edge detection
%               [edge detection sensitivty, min blob size in pixels]
%       - frame2read = [start frame, stop frame] for video
% stereoParams = stereo parameters from stereo calibration
% OUTPUT:
% all_tracks = cell array containing every track (in struct)
% analysis_time = array of analysis time per frame

v = VideoReader(vidname);

tic;
frames = read(v,config.frame2read);
toc;

% thresholds
err_thresh = config.err_thresh; % in pixels
dist_thresh = config.dist_thresh; % in mm
max_invis = config.max_invis; % in frames

% counters
track_cnt = 0; % count current track id

% output track cell
all_tracks = {};

% output for analysis time per frame
analysis_time = 1:1:size(frames,4);

tic;

for k=1:1:size(frames,4)
    % record analysis time
    analysis_time(k) = toc;
    
    tic;  
    frame = frames(:,:,:,k);
    
    % split stereo views and undistort
    [im1,im2] = stereoVideoSplit(frame,stereoParams);
    % contrast adjustment
    imadj1 = imadjust(im1,config.adjust_range/255);
    % edge detection algorithm
    mask1 = detectEdge(imadj1,config.detection_params(1),...
        [5,1],config.detection_params(2));
    % repeat for second view
    imadj2 = imadjust(im2,config.adjust_range/255);
    mask2 = detectEdge(imadj2,config.detection_params(1),...
        [5,1],config.detection_params(2));
    % connected component analysis
    s1  = regionprops(mask1,{'Orientation', 'MajorAxisLength', ...
        'MinorAxisLength', 'Centroid','Area','BoundingBox',...
        'MaxFeretProperties','MinFeretProperties'});
    s2  = regionprops(mask2,{'Orientation', 'MajorAxisLength', ...
        'MinorAxisLength', 'Centroid','Area','BoundingBox',...
        'MaxFeretProperties','MinFeretProperties'});

    % finding centroids and 3d points on the image
    [centOut,bbOut,ind1,ind2]=blobCorrespond2(mask1,mask2,err_thresh,stereoParams);
    
    % if there is no valid correspondence, then add invisible 
    % to all active tracks and then skip this frame
    if isempty(centOut)
        all_tracks = skipAllTracks(all_tracks);
        all_tracks = updateAllTrackStatus(all_tracks,max_invis);
        continue;
    end
    
    % note that feret diameter doesn't show up in s if s is empty
    % so this part has to be after checking for empty regionprops
    % for major axis ellipse
    ellip1 = regionprops2ellip(s1(ind1));
    ellip2 = regionprops2ellip(s2(ind2));
    % for major axis feret
    feret1 = cat(3,s1(ind1).MaxFeretCoordinates);
    feret2 = cat(3,s2(ind2).MaxFeretCoordinates);
    
    
    [p3d,~] = triangulate(centOut(:,:,1),centOut(:,:,2),stereoParams);
    
    % first case: if there is no active tracks
    % then assign all corresponded blobs to new tracks
    if isempty(all_tracks)
        for blob=1:1:size(centOut,1)
            track_cnt = track_cnt+1;
            new_track = initTracks(track_cnt,p3d(blob,:),...
                bbOut(blob,:,1),bbOut(blob,:,1),k,...
                cat(1,feret1(:,:,blob),feret2(:,:,blob)),...
                cat(1,ellip1(:,:,blob),ellip2(:,:,blob)));
            all_tracks{end+1}=new_track;
        end
        continue; % skip the rest in this case
    end
    
    % if there are active tracks, then iterate through all actives tracks
    % to find whether blobs can be assigned to existing tracks first
    for track_num = 1:1:length(all_tracks)
        track = all_tracks{track_num};
        
        % if the track is inactive, then skip
        if track.active==0
            continue;
        end
        
        % get centroid coordinate of the track
        % note that the last point can be NaN, so we need to find
        % the last centroid coordinate that is not NaN
        cent_pos = find(~isnan(sum(track.centroid3,2)),1,'last');
        cent = track.centroid3(cent_pos,:); 
        % find distance between the centroid to all blobs
        dist_array = pdist2(cent,p3d,'euclidean');
        [min_dist,ind] = min(dist_array);
        
        % if the nearest neighbor is farther than threshold,
        % then there is no new centroid to add
        if min_dist>dist_thresh
            track = updateTrack(track,{},{},{});
        % if there is a valid centroid, then add to the track
        else
            track = updateTrack(track,p3d(ind,:),...
                bbOut(ind,:,1),bbOut(ind,:,2),...
                cat(1,feret1(:,:,ind),feret2(:,:,ind)),...
                cat(1,ellip1(:,:,ind),ellip2(:,:,ind)));
        end
        % update the track in the cell array of all tracks
        all_tracks{track_num} = track;
        
        % delete the new blob from the list of detected blob
        p3d(ind,:)=[];
        bbOut(ind,:,:)=[];
        feret1(:,:,ind) = [];
        feret2(:,:,ind) = [];
        ellip1(:,:,ind) = [];
        ellip2(:,:,ind) = [];
        
    end
    
    % now assign all remaining blobs to new tracks
    for blob=1:1:size(p3d,1)
        track_cnt = track_cnt+1;
        new_track = initTracks(track_cnt,p3d(blob,:),...
                bbOut(blob,:,1),bbOut(blob,:,2),k,...
                cat(1,feret1(:,:,blob),feret2(:,:,blob)),...
                cat(1,ellip1(:,:,blob),ellip2(:,:,blob)));
        all_tracks{end+1}=new_track;
    end
    
    
    % update the active status of all tracks
    all_tracks = updateAllTrackStatus(all_tracks,max_invis);


    
    
end