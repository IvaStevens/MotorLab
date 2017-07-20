function markerPos = getMarkerPos(markerName, Data)
Pos = Data.Kinematics.MarkerPos;

markerIdx = getMarkerIdx(markerName, Data);
markerPos = Pos(markerIdx,:);