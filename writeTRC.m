function [] = writeTRC(fileIputName, fileOutputName)
load(fileIputName);
M = length(MarkerNames);
markerPos = MarkerPos(: , 2:end);

% Assumes Vicon reference frame
rotMat = [ 0 -1 0;
           0  0 1;
          -1  0 0 ];
allPos = nan(size(markerPos));

for idx = 1: 3: 3*M
    allPos(:,idx:idx+2) = (rotMat*markerPos(:,idx:idx+2)')';
end

mask = ~isnan(sum(allPos, 2));
pos = allPos(mask,:);

dt = unique(round(diff(Time), 2));
dataRate = 1/dt;
cameraRate = 100;
numFrames = size(pos, 1);
numMarkers = M;
origDataRate = 1;
origStartFrame = 1;
origNumFrames = numFrames;

time = (0:numFrames-1)*dt;
frameNumbers = 1:numFrames;
data = [frameNumbers; time; pos']';

% write data file
fileID = fopen(fileOutputName','w');
fprintf(fileID, '%s\n', strjoin({'PathFileType','4', '(X/Y/Z)', fileOutputName}, '\t'));
fprintf(fileID, '%s\n', strjoin({'DataRate','CameraRate', 'NumFrames', 'Units', 'OrigDataStartFrame', 'OrigNumFrames'}, '\t'));
fprintf(fileID, '%d\t%d\t%d\t%d\tmm\t%d\t%d\t%d\n', dataRate, cameraRate, numFrames, numMarkers, origDataRate, origStartFrame, origNumFrames );
fprintf(fileID, '%s\n', strjoin({sprintf('Frame#\tTime\t'), strjoin(MarkerNames, '\t\t\t')}, ''));

xyzStr = reshape([1:numMarkers; 1:numMarkers; 1:numMarkers], 1, 3*numMarkers);
fprintf(fileID, '%s\n\n', strjoin({sprintf('\t\t'), sprintf('X%d\tY%d\tZ%d\t', xyzStr)}, ''));
fprintf(fileID, '%s\n', sprintf(strjoin({'%d\t%0.6f\t' repmat('%0.6f\t', 1, 3*numMarkers), '\n'},''), data'));

fclose(fileID);

end