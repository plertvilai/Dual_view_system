function output = regionprops2ellip(s_in)
% Calculate the coordinates of the end points of major axis
% of fitted ellipse using the output of regionsprop()
% INPUT:
%   s_in = 1xN struct of regionprops. Note that the regionprops need to
%   following parameters
%       1. MinorAxisLength
%       2. MajorAxisLength
%       3. Orientation
%       4. Centroid
% OUTPUT:
%   output = 2x2xN matrix of end points of the major axes
%       each page is in the format 
%       [x end point 1, y end point 1; x end point 2, y end point 2]

nn = length(s_in);
output = zeros(2,2,nn);

for k =1:1:nn
    s = s_in(k);
    % first get centroid coordinates
    centX = s.Centroid(1);
    centY = s.Centroid(2);

    % find the difference between the endpoints of major axis
    deltaX = s.MinorAxisLength*sind(s.Orientation); 
    deltaY = s.MinorAxisLength*cosd(s.Orientation); 
    % subtract those values from the centroid
%     minXY = [centX-deltaX/2,centY-deltaY/2,centX+deltaX/2,centY+deltaY/2];
    % output format to match feret coordinates
%     minXY0 = [centX-deltaX/2,centY-deltaY/2;centX+deltaX/2,centY+deltaY/2];
    % find the difference between the endpoints of major axis
    deltaX = -s.MajorAxisLength*cosd(s.Orientation); 
    deltaY = s.MajorAxisLength*sind(s.Orientation); 
    % subtract those values from the centroid
    majXY = [centX-deltaX/2,centY-deltaY/2;centX+deltaX/2,centY+deltaY/2];
    
    output(:,:,k) = majXY;
end

