function scaleOpenSimModel(monkey_session)

    if nargin == 0
    elseif nargin == 1
        subject = monkey_session{1};
        session = num2str( monkey_session{2});
    else
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set the variable names %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    OpenSimPath = fullfile(fileparts(pwd), 'data', 'OpenSim');
    sessionPath = fullfile(subject, [subject, sprintf('.%05s', session)]);
    
    xmlFile = fullfile(OpenSimPath, 'setup_Scale_Monkey.xml');
    modelFile = fullfile(subject, [subject, '.osim']);
    markerFile = fullfile(sessionPath, ...
        'Scale', 'StaticMarkers.trc');
    modelName = [subject, sprintf('.%05s', session)];
    outputModelFile = fullfile(sessionPath, ...
        [subject, sprintf('.%05s', session), '.osim']);
    outputScaleFile = fullfile(sessionPath, ...
        'Scale', 'ScaleFactors.xml');
    outputMotionFile = fullfile(sessionPath, ...
        'Scale', 'StaticPose.mot');
    outputMarkerFile = fullfile(sessionPath, ...
        'Scale', 'AdjustedMarkers.trc');
    
    if exist(fullfile(OpenSimPath, outputModelFile), 'file')
        return
    else
        scalePath = fullfile(OpenSimPath, sessionPath, 'Scale');
        if ~exist(scalePath, 'dir')
            mkdir(scalePath)
        end
        rawDataPath = fullfile('R:', 'data', 'Vicon', 'Raw',...
            [subject, sprintf('%05s', session)]);
        filename = [subject,...
            sprintf('%05s01_MarkerKinematics.mat', session)];
        if exist(rawDataPath, 'dir') && ...
                ~exist(fullfile(scalePath, filename), 'file')
            copyfile(fullfile(rawDataPath, filename), ...
                fullfile(scalePath, filename))
        end
        if exist(fullfile(OpenSimPath, subject, 'Geometry'), 'dir') && ...
                ~exist(fullfile(OpenSimPath, sessionPath, 'Geometry'), 'dir')
            copyfile(fullfile(OpenSimPath, subject, 'Geometry'), ...
                fullfile(OpenSimPath, sessionPath, 'Geometry'))
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%
    % Get the time range %
    %%%%%%%%%%%%%%%%%%%%%%
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
    editXMLTag('ScaleTool', modelName, xDoc)
    editXMLTag('model_file', modelFile, xDoc)
    editXMLTag('marker_file', markerFile, xDoc)
    editXMLTag('output_model_file', outputModelFile, xDoc)
    editXMLTag('output_scale_file', outputScaleFile, xDoc)
    editXMLTag('output_motion_file', outputMotionFile, xDoc)
    editXMLTag('output_marker_file', outputMarkerFile, xDoc)
    editXMLTag('time_range', time_range, xDoc)
    write_XML_no_extra_lines(xmlFile, xDoc)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Perform the scale operation %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    system(['scale -S ', xmlFile])    