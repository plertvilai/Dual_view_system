%% Organism Tracking
% This section outlines the process for tracking organism (corixid insect
% in this example). 

% load stereo parameters
load('stereoParameters.mat')
% parameters for tracking
track_config = struct(...
    'err_thresh', 20, ...    % reprojection error threhold for correspondence in pixels      
    'dist_thresh', 8, ...    % distance threshold for tracking in mm
    'max_invis', 5, ...      % broken track threshold to end track
    'adjust_range', [14,150], ...       % image contrast adjustment
    'detection_params', [0.005,1000], ...  % image processing parameters
    'track_length_tresh', 5,... % minimum track length for analysis
    'frame2read', [600,1200]);  % frame number to read from video 

% perform organism tracking
% output:
% tracks => a cell array of all tracks. Each track is a struct containing
%           information of the track. See initTracks.m function for the
%           detail of parameters in each track struct
% tt => an array of analysis time per frame. This output is not used in
% further data analysis and only use to evaluate the speed of the algorithm
% only
[tracks,tt] = videoTracking('1625532935.mp4',track_config, stereoParams);

% cleaning the raw output from tracking algorithm.
% remove NaN from the broken tracks with linear interpolation
clean_tracks = cleanTracks(tracks,track_config.max_invis);
% convert the tracks to a statistic table for simpler data exploration
stat_table = tracks2tableStat(clean_tracks,1,...
    track_config.track_length_tresh, stereoParams);

%% Tracks visualization
% This section shows an example of how to visualize the tracking results
% from the previous section by drawing boudning box on videos.

% load frames from video
vid_name = '1625532935.mp4';
v = VideoReader('1625532935.mp4');
frames = read(v,[600,1200]);

% create arrays of frames for each view
nn = size(frames,4);
im_array1 = zeros(1080,1920,3,nn,'uint8');
im_array2 = zeros(1080,1920,3,nn,'uint8');
for k =1:1:nn
    % read first image
    [im1,im2] = stereoVideoSplit(frames(:,:,:,k),stereoParams);
    im_array1(:,:,:,k) = im1(:,:,[1,1,1],:);
    im_array2(:,:,:,k) = im2(:,:,[1,1,1],:);
end

% color to be used for drawing bounding box
% note that functions insertText and insertShape expect
% RGB triplets in the range of 0-255 as opposed to 
% the usual 0-1
color_all = round(255*lines(length(clean_tracks)));

% draw the bounding boxes on the images
for track_num=1:1:length(clean_tracks)
    track = clean_tracks{track_num};
    % skip tracks that are too short
    if track.age < track_config.track_length_tresh
        continue;
    end
    
    % bbox color for this track
    track_color = color_all(track.id,:);
    
    % for valid tracks, iterate over all frames
    % starting from framestart and until the end of the track (age)
    im_num=track.framestart:1:(track.framestart+track.age-1);
%     for m=1:1:6
    for m=1:1:length(im_num)
        im1 = im_array1(:,:,:,im_num(m));
        imViz1 = insertShape(im1,'rectangle',track.bbox_1(m,:),...
            'Color',track_color);
        imViz1 = insertText(imViz1,track.bbox_1(m,1:2)-[10,30],...
            track.id,'FontSize',24,'BoxColor',track_color);
        
        im2 = im_array2(:,:,:,im_num(m));
        imViz2 = insertShape(im2,'rectangle',track.bbox_2(m,:),...
            'Color',track_color);
        imViz2 = insertText(imViz2,track.bbox_2(m,1:2)-[10,30],...
            track.id,'FontSize',24,'BoxColor',track_color);
        
        % insert images back into the output arrays
        im_array1(:,:,:,im_num(m)) = imViz1;
        im_array2(:,:,:,im_num(m)) = imViz2;
    end
end

% play both views side by side
implay([im_array1,im_array2])

%% Tracks visualization (cont)
% This section shows an example of how to visualize the tracking results
% from the previous section in a 3d plot format.

color_all_01 = lines(length(clean_tracks));

figure()
hold on

for track_num = 1:1:length(clean_tracks)
    track_color = color_all_01(track.id,:);
    track = clean_tracks{track_num};
    if track.age<5 % skip short tracks
        continue
    end
    X = track.centroid3(:,1);
    Y = track.centroid3(:,2);
    Z = track.centroid3(:,3);
    plot3(X,Y,Z,'LineWidth',1.5,'Color',track_color)
end
hold off
xlabel('X')
ylabel('Y')
zlabel('Z')
view(45,45)
xlim([-40,-5])
ylim([0,18])
zlim([70,150])
grid on
title('Tracks of organisms')

%% Particle Tracking
% This section outlines the process for tracking ambient particles

% parameters for tracking
% note that this is slightly different from the parameters for organism
% tracking
particle_track_config = struct(...
    'err_thresh', 30, ...     % reprojection error threhold for correspondence in pixels     
    'dist_thresh', 2, ...     % distance threshold for tracking in mm
    'max_invis', 5, ...       % broken track threshold to end track    
    'detection_params', [1,5,50], ...   % image processing parameters
    'track_length_tresh', 5,... % minimum track length for analysis
    'frame2read', [50,1750]); % frame number to read from video 

% perform organism tracking
% output is in the same format as the organism tracking
[tracks0,tt0] = videoParticleTracking('1625532935.mp4',...
    particle_track_config, stereoParams);
 
% cleaning the raw output from tracking algorithm.
clean_tracks = cleanTracks(tracks0,particle_track_config.max_invis);
% convert the tracks to a statistic table for simpler data exploration
stat_table = tracks2tableStat(clean_tracks,1,...
    particle_track_config.track_length_tresh, stereoParams);