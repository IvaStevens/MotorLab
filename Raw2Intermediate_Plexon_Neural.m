function Raw2Intermediate_Plexon_Neural( monkey_session)

if nargin == 0
elseif nargin == 1
    monkey = monkey_session{1};
    session = num2str( monkey_session{2});
else
end

CommonPath = getenv( 'ROBOT_COMMON');
addpath( [CommonPath '/matlab']);

SrcPath = getenv( 'ROBOTSRC');
addpath( [SrcPath '/plexon_loader']);

DataPath = getenv( 'ROBOTDATA');

input_filename  = [DataPath,'/Plexon/Raw/', ...
                   monkey, '/', ...
                   monkey, '.RGM.00', session, '/', ...
                   monkey, '.RGM.00', session, '.plx'];
output_filename = [DataPath, '/Plexon/Intermediate/',...
                   monkey, '.RGM.00', session '.mat'];
config_filename = [DataPath, '/', monkey, '/Raw/',...
                   monkey, '.RGM.00', session, '/',...
                   'PlexonEMG.config'];

if ~exist( input_filename, 'file')              
    return;
end
               
if exist( output_filename, 'file')
    disp( ['\nFile ', output_filename, ' already exists. '])
    disp( 'To overwrite, first delete existing file.')
    return
end

% Get header information from pl file
[OpenedFileName, ...
    Version, ...
    Freq, ...
    Comment, ...
    Trodalness, ...
    NPW, ...
    PreThresh, ...
    SpikePeakV, ...
    SpikeADResBits, ...
    SlowPeakV, ...
    SlowADResBits, ...
    Duration, ...
    DateTime] = plx_information(input_filename);

% Determine whether the file is PL2 or plx
[tmp, isPl2] = internalPL2ResolveFilenamePlx(OpenedFileName);

% Get counts
[tscounts, wfcounts, evcounts, slowcounts] = plx_info(OpenedFileName,1);

% Calculate the total number of time bins
samplingFrequency = 2000;
B = ts2bin(Duration, samplingFrequency);


%% SYNC PULSE DATA
Sync = nan(1, B);

sync_struct = PL2AdBySource(OpenedFileName, 'AI', 1);
syncFreq = sync_struct.ADFreq;
syncFirstTimestamp = sync_struct.FragTs;
syncFirstBin = ts2bin(syncFirstTimestamp, syncFreq);

syncValues = sync_struct.Values;
syncBool = syncValues > 1.5e4;

syncCounts = sync_struct.FragCounts;
start = syncFirstBin;
stop = syncFirstBin + syncCounts - 1;
Sync(1,start:stop) = syncBool;


%% SPIKE DATA

% I only have 160 channels and none of the channels have more than 5 units
nchannels = 160;
nunits = 5;

% Loop over all the units and create a cell array of timestamps
allts = cell(nunits, nchannels);
for iunit = 1:nunits
    for ich = 1:nchannels
        if (tscounts(iunit+1, ich+1) > 0)
            [allts{iunit,ich}] = PL2Ts(OpenedFileName, ich, iunit);
        end
    end
end

% Initialize variables to convert timestamps to time bins
W = nnz(~cellfun(@isempty, allts));
waveData = false(W,B);
waveChannel = nan(W,1);
waveUnit = nan(W,1);

minTS = nan(W,1);
maxTS = nan(W,1);
maxBin = nan(W,1);

% Loop over all the units and convert timestamps to time bins
[Unit,Channel] = find(~cellfun(@isempty, allts));
for w = 1:W        
    channel = Channel(w);
    unit = Unit(w);

    waveTS = allts{unit,channel};
    waveBins = ts2bin(waveTS, syncFreq); % Calculates the time bin of each timestamp
    minTS(w) = min(waveTS);
    maxTS(w) = max(waveTS);
    maxBin(w) = max(waveBins);

    waveData(w, waveBins) = true;
end


%% MUSCLE EMG DATA
%
LoadTextData( config_filename)
muscleNames = config.names;
channelNums = config.channelNum;

% channelNums = [193, 194, 195, 196, ...
%                197, 198, 199, 200, ...
%                201, 202, 203, 204, ...
%                205, 206, 207, 208];
% 
% muscleNames = {'ECRL', 'BRA', 'BIC', 'TRI_M',...
%                'TRI_L', 'INFSP', 'DELT_P', 'DELT_A',...
%          	   'ECU', 'EDC', 'FCR', 'FCU',...
%                'PEC', 'FDS', 'LAT', 'APL'};

% Initialize variables for muscle EMG           
disp('Initializing variables...')
M = length(channelNums);

muscleData = nan(M,B);
EMG = nan(M,B);
raw = nan(M,B);
disp('done')

disp('Extracting muscle data...')
for m = 1:M
    oneChannel = channelNums(m);
    oneMuscle_struct = PL2AdBySource(OpenedFileName, 'FP', oneChannel);
    
    oneMuscleFreq = oneMuscle_struct.ADFreq;
    oneMuscleFirstTimestamp = oneMuscle_struct.FragTs;
    oneMuscleFirstBin = ts2bin(oneMuscleFirstTimestamp, oneMuscleFreq);
    
    oneMuscleValues = oneMuscle_struct.Values;   
    oneMuscleCounts = oneMuscle_struct.FragCounts;
    start = oneMuscleFirstBin;
    stop = oneMuscleFirstBin + oneMuscleCounts - 1;
    muscleData(m,start:stop) = oneMuscleValues;
end
disp('done')
