function fData = Postprocess_Joint_Kinematics(fData)
% fData = Postprocess_Kinematics_Data( fData)
%
% Performs any processing of the kinematic data that requires 
% information from the formatted data.
%
% INPUTS
% ------
% fData : struct
%     The formatted data.
%
% OUTPUTS
% -------
% fData : struct
%     The formatted data with any EMG postprocessing.
%
% sdk29@pitt.edu 2015-12

% Load data
if ~isfield(fData, 'Kinematics')
    return;
end
sk_disp('Postprocess_Kinematics_Data')

subject = 'Ivan';
session = fData.SessionNo;
OpenSimPath = fullfile(fileparts(pwd), 'data', 'OpenSim');
sessionPath = fullfile(subject, [subject, sprintf('.%05i', session)]);
sessionFile = [subject, sprintf('.%05i', session)];
filepath = {OpenSimPath, sessionPath, sessionFile};

allCombos = unique(fData.ComboNo);
allCombos(allCombos == 0) = [];
C = length(allCombos);
for c = 1:C
    oneCombo = allCombos(c);
    sk_disp(num2str(C-c))
    % Perform inverse kinematics
    writeTrc(oneCombo, fData, filepath);
    ik_results_file = writeInverseKinematics(oneCombo, filepath);
    fData = addKinematicsTofData(oneCombo, ik_results_file, fData);
end

function [] = sk_disp(arg)
    fprintf('%s\n', arg)

function Data = addKinematicsTofData(oneCombo, ik_results_file, Data)
    markerPos = Data.Kinematics.MarkerPos;
    comboNo = Data.ComboNo;
    
    comboMask = oneCombo == comboNo;
    nanMask = isnan(sum(markerPos, 1));
    mask = ~nanMask & comboMask;
    
    [ikData, ikLabels] = readStorageFile(ik_results_file);
    if ~isfield(Data.Kinematics, 'JointAngle')
        T = size(Data.Time, 2);
        J = size(ikData, 2) - 1;
        Data.Kinematics.JointAngle = nan(J,T);
    end
    % Joint angle dims is one less. Copy last value to bottom 
    Data.Kinematics.JointAngle(:,mask) = [ikData(:,2:end); ikData(end,2:end)]';
    Data.Kinematics.JointNames = ikLabels(2:end);

function writeTrc(oneCombo, Data, filepath)
    sk_disp(['writeTrc: ', sprintf('%02i', oneCombo)])
	OpenSimPath = filepath{1};
    sessionPath = filepath{2};
    sessionFile = filepath{3};
    ikPath = fullfile(OpenSimPath, sessionPath,...
                        'InverseKinematics');
    filename = [sessionFile,... 
                sprintf('%02i', oneCombo),...
                '.trc'];
    
    if ~exist(ikPath, 'dir')
        mkdir(ikPath)
    end
    
    if exist(fullfile(ikPath, filename), 'file')
        return
    end
    
    markerPos = Data.Kinematics.MarkerPos;
	markerNames = Data.Kinematics.MarkerNames;
	comboNo = Data.ComboNo;
	dt = Data.Dt;
	
	M = length(markerNames);
	comboMask = oneCombo == comboNo;
	nanMask = isnan(sum(markerPos, 1));
	mask = ~nanMask & comboMask;
	
    % Assumes formatted reference frame
    rotMat = [ 0, 1, 0;...
               0, 0, 1;...
               1, 0, 0];
           
	allPos = nan(size(markerPos))';
    for idx = 1:3:3*M
		allPos(:,idx:idx+2) = (rotMat*markerPos(idx:idx+2,:))';
    end
	pos = allPos(mask,:);
	
	dataRate = 1/dt;
	cameraRate = 100;
	numFrames = size(pos, 1);
	numMarkers = M;
	origDataRate = 100;
	origStartFrame = 1;
	origNumFrames = numFrames;
	
	time = 0:dt:(numFrames-1)*dt;
	frameNumbers = 1:numFrames;
	
	data = [frameNumbers', time', pos];
    
    fid = fopen(fullfile(ikPath, filename), 'w');
    if fid == -1
        error(['unable to open ', fullfile(ikPath, filename)])
    end

    fprintf(fid, '%s\t%d\t%s\t%s\n', 'PathFileType', 4, '(X/Y/Z)', filename);
    fprintf(fid, 'DataRate\tCameraRate\tNumFrames\tNumMarkers\tUnits\tOrigDataRate\tOrigDataStartFrame\tOrigNumFrames\n');
    fprintf(fid, '%d\t%d\t%d\t%d\tmm\t%d\t%d\t%d\n', dataRate,...
                                                     cameraRate,...
                                                     numFrames,...
                                                     numMarkers,...
                                                     origDataRate,...
                                                     origStartFrame,...
                                                     origNumFrames);
    fprintf(fid, 'Frame#\tTime\t');
    for m = 1:M
        oneName = markerNames{m};
        fprintf(fid, '%s\t\t\t', oneName);
    end
    fprintf(fid, '\n');
    fprintf(fid, '\t\t');
    for m = 1:numMarkers
        X = ['X', num2str(m)];
        Y = ['Y', num2str(m)];
        Z = ['Z', num2str(m)];
        fprintf(fid, '%s\t%s\t%s\t', X, Y, Z);
    end
    fprintf(fid, '\n');
    fprintf(fid, '\n');

    for r = 1:size(data, 1)
        fprintf(fid, '%i\t', data(r,1));
        for c = 2:size(data, 2)
            fprintf(fid, '%f\t', data(r,c));
        end
        fprintf(fid, '\n');
    end
    
    fclose(fid);
    
function motionFile = writeInverseKinematics(oneCombo, filepath)
	sk_disp(['writeInverseKinematics', sprintf('%02i', oneCombo)])
    OpenSimPath = filepath{1};
    sessionPath = filepath{2};
    sessionFile = filepath{3};
    
    xmlFile = fullfile(OpenSimPath, 'setup_IK_Monkey.xml');
	modelFile = fullfile(OpenSimPath, sessionPath, ...
        [sessionFile, '.osim']);
	markerFile = fullfile(OpenSimPath, sessionPath, ...
        'InverseKinematics', [sessionFile, ...
        sprintf('%02i.trc', oneCombo)]);
	motionFile = fullfile(OpenSimPath, sessionPath, ...
        'InverseKinematics', [sessionFile, ... 
        sprintf('%02i_IK.mot', oneCombo)]);
    if exist(motionFile, 'file')
        return
    end
	
	fid = fopen(markerFile, 'r');
    if fid == -1
        error(['Unable to open ' markerFile]);
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
	
    xDoc = xmlread(xmlFile);
    editXMLTag('model_file', modelFile, xDoc)    
    editXMLTag('marker_file', markerFile, xDoc)
    editXMLTag('time_range', sprintf('%0.2f %0.2f', time_range), xDoc)
    editXMLTag('output_motion_file', motionFile, xDoc)
    write_XML_no_extra_lines(xmlFile, xDoc)
	
	system(['ik -S ', xmlFile])    

function write_XML_no_extra_lines(save_name,XDOC)
    XML_string = xmlwrite(XDOC); %XML as string
    XML_string = regexprep(XML_string,'\n[ \t\n]*\n','\n'); %removes extra tabs, spaces and extra lines

    %Write to file
    fid = fopen(save_name,'w');
    fprintf(fid,'%s\n',XML_string);
    fclose(fid); 

function editXMLTag(tag, newInfo, xDoc)
    allListItems = xDoc.getElementsByTagName(tag);
    thisListItem = allListItems.item(0);
    thisListItem.getFirstChild.setData(newInfo);
    
function [data, columnLabels] = readStorageFile(fname)
    % dataStruct = readStorageFile(fname)
    %
    % Reads the data from an OpenSim storage file and creates a structure with
    % column labels as field names and columns values as field values.
    %
    % INPUTS
    % ------
    % fname : string
    %   Full path of the OpenSim storage file to be read.
    %
    % OUTPUTS
    % -------
    % dataStruct : struct
    %   dataStruct.name : column label
    %   dataStruct.value : column values
    %
    % 2014-10 sdk29@pitt.edu
    
    % Load file
    fid = fopen(fname, 'r');
    if fid == -1
        error(['Unable to open ' fname]);
    end
    
    % Parse header
    nextline = fgetl(fid);
    while ~strcmp(nextline, 'endheader')
        if strncmpi(nextline, 'nRows', 5)
            nRows = str2double(nextline(strfind(nextline, '=')+1:length( nextline)));
        elseif strncmpi( nextline, 'nColumns', 8)
            nCols = str2double( nextline( strfind( nextline, '=')+1:length( nextline)));
        end
        nextline = fgetl( fid);
    end
    
    % Get column labels
    nextline = fgetl( fid);
    if (all( isspace( nextline)))
        nextline = fgetl( fid);
    end
    columnLabels = strsplit( nextline, '\t');
    
    % Scan data
    data = fscanf( fid, '%f', [nCols,nRows])';
    
    % % Make a data struct
    % for c = nCols:-1:1
    %     dataStruct(c).name = columnLabels{c};
    %     dataStruct(c).values = data(:,c);
    % end
    
    fclose( fid);
