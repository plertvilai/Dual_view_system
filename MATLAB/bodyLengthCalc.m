function body_length = bodyLengthCalc(ellip_array,stereoParams)
% Calculate body length of the input blobs
% INPUT: 
%   ellip_array = 2x2xN matrix of the coordiantes of the end points of the
%       major axes of ellipses in the format
%       [x end point 1, y end point 1; x end point 2, y end point 2]
%   - stereoParams = struct of stereo parameters (MATLAB format)
% OUTPUT:
%   body_length = 3xN array of calculated body lengths.
%       each row is in the format
%       [body length, mean reprojection error from triangulation, tilt
%       angle of the major axis]


body_length = zeros(size(ellip_array,3),3);

for k=1:1:size(ellip_array,3)
    axes = ellip_array(:,:,k);
    
    % perform trianglulation
    [p3d,err] = triangulate(axes(1:2,:),axes(3:4,:),stereoParams);
    % calculate length
    xyLen = norm(p3d(1,:)-p3d(2,:));
    % calculate mean reprojection error
    xyErr = max(err);
    % calculate vector angle
    vv = p3d(1,:)-p3d(2,:);
    angle = acos(vv(3)/norm(vv));
    if angle>pi/2
        angle=abs(angle-pi);
    end

    body_length(k,:) = [xyLen,xyErr,angle];
end
