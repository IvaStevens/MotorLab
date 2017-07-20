function scaleOpenSimModel(monkey_session)

    if nargin == 0
    elseif nargin == 1
        subject = monkey_session{1};
        session = num2str( monkey_session{2});
    else
    end
    % subject = 'KingKong';
    % session = 408;
    OpenSimPath = fullfile(fileparts(pwd), 'data', 'OpenSim');
    sessionPath = fullfile(subject, [subject, sprintf('.%05i', session)]);
    sessionFile = [subject, sprintf('.%05i', session)];
    
    xmlFile = fullfile(OpenSimPath, 'setup_Scale.xml');
    % modelFile = fullfile(OpenSimPath, ...
    %     [subject, '.osim']);
    modelFile = fullfile(subject, [subject, '.osim']);
    markerFile = fullfile(sessionPath, ...
        'Scale', 'StaticMarkers.trc');
    outputModelFile = fullfile(sessionPath, ...
        [subject, sprintf('.%05i', session), '.osim']);
    outputScaleFile = fullfile(sessionPath, ...
        'Scale', 'ScaleFactors.xml');
    outputMotionFile = fullfile(sessionPath, ...
        'Scale', 'StaticPose.mot');
    outputMarkerFile = fullfile(sessionPath, ...
        'Scale', 'AdjustedMarkers.trc');
    
    fid = fopen(fullfile(OpenSimPath, markerFile), 'r');
    if fid == -1
        error(['Unable to open ' fullfile(OpenSimPath, markerFile)]);
    end
    
    line = fgetl(fid);
    lineStr = textscan(line, '%s');
    lineStr = lineStr{1};
    readIdx = false;
    while ~ismember('Time', lineStr)
        if readIdx
            nRows = str2double(lineStr{idxFrames});
            nCols = str2double(lineStr{idxMarkers})*3+2;
            readIdx = false;
        end
        if ismember('NumFrames', lineStr)
            idxFrames = ismember(lineStr, 'NumFrames');
            readIdx = true;
        end
        if ismember('NumMarkers', lineStr)
            idxMarkers = ismember(lineStr, 'NumMarkers');
        end
        line = fgetl(fid);
        lineStr = textscan(line, '%s');
        lineStr = lineStr{1};
    end
    timeIdx = find(ismember(lineStr, 'Time'));
    fgetl(fid);
    markerData = fscanf(fid, '%f', [nCols,nRows])';
    time_range = [markerData(1,timeIdx), markerData(end,timeIdx)];
    fclose(fid);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Update the scale settings file %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    xDoc = xmlread(xmlFile);
    editXMLTag('model_file', modelFile, xDoc)
    editXMLTag('marker_file', markerFile, xDoc)
    editXMLTag('output_model_file', outputModelFile, xDoc)
    editXMLTag('output_scale_file', outputScaleFile, xDoc)
    editXMLTag('output_motion_file', outputMotionFile, xDoc)
    editXMLTag('output_marker_file', outputMarkerFile, xDoc)
    editXMLTag('time_range', time_range)
    write_XML_no_extra_lines(xmlFile, xDoc)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Perform the scale operation %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    system(['scale -S ', xmlFile])    