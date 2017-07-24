function fData = Postprocess_Joint_Torques(fData)
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
if ~isfield(fData, 'Force')
    return;
end
sk_disp('Postprocess_Force_Data')

subject = 'KingKong';
session = fData.SessionNo;
OpenSimPath = fullfile(fileparts(pwd), 'data', 'OpenSim');
sessionPath = fullfile(subject, [subject, sprintf('.%05i', session)]);
sessionFile = [subject, sprintf('.%05i', session)];
filepath = {OpenSimPath, sessionPath, sessionFile};

T = size(fData.Time, 2);
J = 40;
fData.Force.JointTorque = nan(J, T);

allCombos = unique(fData.ComboNo);
allCombos(allCombos == 0) = [];
C = length(allCombos);
for c = 1:C
    oneCombo = allCombos(c);
    sk_disp(sprintf('%i', C-c))
    
    % Perform inverse dynamics
    writeExternalForce(oneCombo, fData, filepath);
    writeForceMovement(oneCombo, fData, filepath);
    id_results_file = writeInverseDynamics(oneCombo, filepath);
    fData = addDynamicsTofData(oneCombo, id_results_file, fData);
end

fData = getNormalizedForce(fData);

function Data = getNormalizedForce(Data)
    Force = Data.Force.data(2,:);
    forceThreshLower = Data.Force.threshold.lower;
    trialRamp = Data.TaskStateMasks.ForceRamp;
    
    maxThreshold = max(forceThreshLower(2,trialRamp));
    refF = 2*maxThreshold/100;
    normForce = Force/refF;
    normThreshLower = forceThreshLower/refF;

    Data.Force.normData = normForce;
    Data.Force.threshold.normLower = normThreshLower;
    
function Data = addDynamicsTofData(oneCombo, id_results_file, Data)
    markerPos = Data.Kinematics.MarkerPos;
    comboNo = Data.ComboNo;
    
    comboMask = oneCombo == comboNo;
    nanMask = isnan(sum(markerPos, 1));
    mask = ~nanMask & comboMask;
    
    [idData, idLabels] = readStorageFile(id_results_file);
    Data.Force.JointTorque(:,mask) = idData(:,2:end)';
    Data.Force.JointNames = idLabels(2:end);
    
function writeExternalForce(oneCombo, Data, filepath)
    sk_disp('writeExternalForceMot')
    OpenSimPath = filepath{1};
    sessionPath = filepath{2};
    sessionFile = filepath{3};
    
    comboNo = Data.ComboNo;
    hndlPos = getMarkerPos('HDDU', Data)/1000;
    Force = Data.Force.data;
    dt = Data.Dt;

    comboMask = oneCombo == comboNo;
    nanMask = isnan(sum(hndlPos, 1)) | isnan(sum(Force, 1));
    mask = ~nanMask & comboMask;

    rotMarkers = [ 0, 1, 0;...
                   0, 0, 1;...
                   1, 0, 0];
% 	rotMarkers = [ 0, 0, 1;... 
%                    0,-1, 1;... 
%                    1, 0, 0];
    rotForce = [-1, 0, 0;...
                 0, 0, 1;...
                 0, 1, 0];

    rotatedHndl = (rotMarkers*hndlPos)';
    rotatedForce = nan(size(Force))';
    for i = [1,4]
        rotatedForce(:,i:i+2) = (rotForce*Force(i:i+2,:))';
    end

    point = rotatedHndl(mask,:);
    force = rotatedForce(mask,:);

    time = 0:dt:(size(force, 1)-1)*dt;
    
%     data = [time', force(:,1:3), point, force(:,4:end)];
    data = [time', force(:,1:3), point, zeros(size(force(:,1:3)))];

    name = {'ground_force_v', 'ground_force_p', 'ground_torque_'};
    append = {'x', 'y', 'z'};
    N = length(name);
    A = length(append);
    labels = cell(N*A,1);
    n = 1;
    for i = 1:N
        for j = 1:A
            labels{n} = [name{i}, append{j}];
            n = n + 1;
        end
    end

    idPath = fullfile(OpenSimPath, sessionPath,...
                    'InverseDynamics');
    if ~exist(idPath, 'dir')
        mkdir(idPath)
    end
    filename = [sessionFile,... 
                sprintf('%02i', oneCombo),...
                '_ExternalForce.mot'];

    fid = fopen(fullfile(idPath, filename), 'w');
    if fid == -1
        error(['unable to open ', [idPath, filename]])
    end
    sk_disp(fullfile(idPath, filename))

    fprintf(fid, '%s\n', filename);
    fprintf(fid, '%s\n', 'version=1');
    fprintf(fid, 'nRows=%i\n', size(data, 1));
    fprintf(fid, 'nColumns=%i\n', size(data, 2));
    fprintf(fid, '%s\n', 'inDegrees=yes');
    fprintf(fid, '\n');
    fprintf(fid, '%s\n', 'Units are S.I. units (second, meters, Newtons, ...)');
    fprintf(fid, '%s\n', 'Angles are in degrees.');
    fprintf(fid, '\n');
    fprintf(fid, '%s\n', 'endheader');
    fprintf(fid, 'time\t');
    for l = 1:N*A
        oneLabel = labels{l};
        fprintf(fid, '%s\t', oneLabel);
    end
    fprintf(fid, '\n');
    for r = 1:size(data, 1)
        for c = 1:size(data, 2)
            fprintf(fid, '%f\t', data(r,c));
        end
        fprintf(fid, '\n');
    end

    fclose(fid);

function writeForceMovement(oneCombo, Data, filepath)
	sk_disp('writeForceMovementMot')
    OpenSimPath = filepath{1};
    sessionPath = filepath{2};
    sessionFile = filepath{3};
	
    comboNo = Data.ComboNo;
    hndlPos = getMarkerPos('HDDU', Data)/1000;
    Force = Data.Force.data;
    
    comboMask = oneCombo == comboNo;
    nanMask = isnan(sum(hndlPos, 1)) | isnan(sum(Force, 1));
    mask = ~nanMask & comboMask;
    
    moveData = Data.Kinematics.JointAngle(:,mask)';
    moveNames = Data.Kinematics.JointNames;
    
    filename = [sessionFile, ...
        sprintf('%02i', oneCombo), ...
        '_ForceMovement.mot'];
	
    forceFile = fullfile(OpenSimPath, sessionPath,...
                         'InverseDynamics',...
						 [sessionFile, ...
                         sprintf('%02i', oneCombo), ...
                         '_ExternalForce.mot']);
    % Load file
    fid = fopen(forceFile, 'r');
    if fid == -1
        error( ['Unable to open ' forceFile]);
    end

    % Parse header
    nextline = fgetl(fid);
    while ~strcmp(nextline, 'endheader')
        if strncmpi( nextline, 'nRows', 5)
            nRows = str2double( nextline( strfind( nextline, '=')+1:length( nextline)));
        elseif strncmpi( nextline, 'nColumns', 8)
            nCols = str2double( nextline( strfind( nextline, '=')+1:length( nextline)));
        end
        nextline = fgetl(fid);
    end
    nextline = fgetl(fid);
    forceNames = textscan(nextline, '%s', 'Delimiter', '\t');
    forceData = fscanf(fid, '%f', [nCols, nRows])';
    
    names = cat(2, forceNames{1}{1}, moveNames, forceNames{1}{2:end});
    

	m = size(moveData, 1);
	f = size(forceData, 1);

	diff = m - f;
    if diff == 0
        data = [forceData(:,1), moveData, forceData(:,2:end)];
    end
    if diff < 0
		data = [forceData(1:diff,1), moveData, forceData(1:diff,2:end)];
    end
    if diff > 0
		data = [forceData(:,1), moveData(1:end-diff,:), forceData(:,2:end)];
    end
	
    fid = fopen(fullfile(OpenSimPath, sessionPath, filename), 'w');
    if fid == -1
        error(['unable to open ', fullfile(OpenSimPath, sessionPath, filename)])
    end
    sk_disp(fullfile(OpenSimPath, sessionPath, filename))
    
    fprintf(fid, '%s\n', filename);
    fprintf(fid, '%s\n', 'version=1');
    fprintf(fid, 'nRows=%i\n', size(data, 1));
    fprintf(fid, 'nColumns=%i\n', size(data, 2));
    fprintf(fid, '%s\n', 'inDegrees=yes');
    fprintf(fid, '\n');
    fprintf(fid, '%s\n', 'Units are S.I. units (second, meters, Newtons, ...)');
    fprintf(fid, '%s\n', 'Angles are in degrees.');
    fprintf(fid, '\n');
    fprintf(fid, '%s\n', 'endheader');

    for n = 1:length(names)
        oneName = names{n};
        fprintf(fid, '%s\t', oneName);
    end
    fprintf(fid, '\n');
    for row = 1:size(data, 1)
        for col = 1:size(data, 2)
            fprintf(fid, '%f\t', data(row,col));
        end
        fprintf(fid, '\n');
    end
    
    fclose(fid);

function outputPathFile = writeInverseDynamics(oneCombo, filepath)
	sk_disp('writeInverseDynamics')
    OpenSimPath = filepath{1};
    sessionPath = filepath{2};
    sessionFile = filepath{3};
	
    setupXML = fullfile(OpenSimPath, ...
                        'setup_ID.xml');
	forceXML = fullfile(OpenSimPath, ...
						'setup_external_force.xml');
	modelFile = fullfile(OpenSimPath, sessionPath,...
					     [sessionFile, '.osim']);
	dataFile = fullfile(OpenSimPath, sessionPath,...
						[sessionFile, ...
                        sprintf('%02i_ForceMovement.mot', oneCombo)]);
	outputFile = [sessionFile,...
                  sprintf('%02i_JointTorques.sto', oneCombo)];
	outputDirectory = fullfile(OpenSimPath, sessionPath,...
								'InverseDynamics');
    outputPathFile = fullfile(outputDirectory, outputFile);

    fid = fopen(dataFile, 'r');
    if fid == -1
        error(['Unable to open ' dataFile]);
    end
    
    line = fgetl(fid);
    lineStr = textscan(line, '%s', 'Delimiter', '\t');
    lineStr = lineStr{1};
    while ~ismember('time', lineStr)
        if strncmpi(line, 'nRows', 5)
            nRows = str2double(line(strfind(line, '=')+1:length(line)));
        elseif strncmpi(line, 'nColumns', 8)
            nCols = str2double(line(strfind(line, '=')+1:length(line)));
        end
        line = fgetl(fid);
        if ~isempty(line)
            lineStr = textscan(line, '%s', 'Delimiter', '\t');
            lineStr = lineStr{1};
        else
            line = fgetl(fid);
        end
    end
    timeIdx = find(ismember(lineStr, 'time'));
    data = fscanf(fid, '%f', [nCols,nRows])';
    time_range = [data(1,timeIdx), data(end,timeIdx)];
    fclose(fid);
	
    xDoc = xmlread(setupXML);
    editXMLTag('results_directory', outputDirectory, xDoc);
    editXMLTag('model_file', modelFile, xDoc);
    editXMLTag('time_range', sprintf(' %0.2f %0.2f', time_range), xDoc);
    editXMLTag('external_loads_file', forceXML', xDoc);
    editXMLTag('coordinates_file', dataFile, xDoc);
    editXMLTag('lowpass_cutoff_frequency_for_coordinates', '-1', xDoc);
    editXMLTag('output_gen_force_file', outputFile, xDoc);
    write_XML_no_extra_lines(setupXML, xDoc)
	
    xDoc = xmlread(forceXML);
    editXMLTag('datafile', dataFile, xDoc);
    editXMLTag('external_loads_model_kinematics_file', dataFile, xDoc);
    editXMLTag('lowpass_cutoff_frequency_for_load_kinematics', '-1', xDoc);
    write_XML_no_extra_lines(forceXML, xDoc);
    
    system(['"', fullfile('C:', 'OpenSim 3.3', 'bin', 'id'), '"', ' -S ', setupXML])
    

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

function markerIdx = getMarkerIdx(markerToFind, Data)
    markerNames = Data.Kinematics.MarkerNames;

    [~, nameIdx] = ismember(markerToFind, markerNames);
    start = 3*(nameIdx-1)+1;
    markerIdx = start:start+2;

function markerPos = getMarkerPos(markerName, Data)
    Pos = Data.Kinematics.MarkerPos;

    markerIdx = getMarkerIdx(markerName, Data);
    markerPos = Pos(markerIdx,:);
