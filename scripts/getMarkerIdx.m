function markerIdx = getMarkerIdx(markerToFind, Data)
markerNames = Data.Kinematics.MarkerNames;

[~, nameIdx] = ismember(markerToFind, markerNames);
start = 3*(nameIdx-1)+1;
markerIdx = start:start+2;