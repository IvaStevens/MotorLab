function Preprocess_Plexon_EMG(monkey_session)
% Preprocess_Plexon_EMG(monkey_session)
%
% Filters the raw EMG data and saves in the intermediate directory.
%
% INPUTS
% ------
%
% OUTPUTS
% -------
%
% sdk29@pitt.edu 2016-09 2016-08

disp('Preprocess_Plexon_EMG')

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
                   monkey, '.RGM.00', session, '001.pl2'];
output_filename = [DataPath, '/Plexon/Intermediate/EMG/',...
                   monkey, '.RGM.00', session '.mat'];
config_filename = [DataPath, '/', monkey, '/Raw/',...
                   monkey, '.RGM.00', session, '/',...
                   'PlexonEMG.config'];

if ~exist( input_filename, 'file')              
    disp(['Input filename does not exist: ', input_filename])
    return;
end
               
if exist( output_filename, 'file')
    disp( ['\nFile ', output_filename, ' already exists. '])
    disp( 'To overwrite, first delete existing file.')
    return
end

LoadTextData(config_filename)
muscleNames = config.names;
channelNums = config.channelNum;

% Load info from the plexon file
[OpenedFileName, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, Duration, ~] = plx_information(input_filename);

% ------------------------------------------------------------
% Initialize variables
% ------------------------------------------------------------

disp('Initializing variables...')
M = length(channelNums);
B = getSampleCounts(OpenedFileName, channelNums(1));

muscleData = nan(M,B);
EMG = nan(M,B);
raw = nan(M,B);
disp('done')

% ------------------------------------------------------------
% Extract muscle data
% ------------------------------------------------------------

disp('Extracting muscle data...')
for m = 1:M
    oneChannel = channelNums(m);
    fprintf('%i, ', oneChannel)
    
    oneMuscleValues = getStackedAdData(OpenedFileName, 'FP', oneChannel);
    muscleData(m,:) = oneMuscleValues;
end
disp('done')

% ------------------------------------------------------------
% Filter muscle data
% ------------------------------------------------------------

% Data have already been high-pass filtered in Plexon
disp('Filtering muscle data...')
emgFreq = getSamplingFrequency(OpenedFileName, channelNums(1));
Fc_high = 100;
Fc_low = 30;
for m = 1:M
    oneChannel = channelNums(m);
    fprintf('%i, ', oneChannel)
    
    highPass = EMGfilter(Fc_high, 'high', emgFreq, muscleData(m,:));
    rectified = abs(highPass);
    lowPass = EMGfilter(Fc_low, 'low', emgFreq, rectified);
    
    muscleName = muscleNames{m};
    emg.(muscleName).highPass = highPass;
    emg.(muscleName).rectified = rectified;
    emg.(muscleName).lowPass = lowPass;
    emg.(muscleName).channelNum = channelNums(m);
    
    EMG(m,:) = lowPass;
    raw(m,:) = muscleData(m,:);
end
disp('done')

% ------------------------------------------------------------
% Extract sync pulse
% ------------------------------------------------------------

disp('Extracting sync pulses...')
syncValues = getPaddedAdData(OpenedFileName, 'AI', 1);
Sync = syncValues > 2500;
disp('done')

% ------------------------------------------------------------
% Pad data to fit file duration
% ------------------------------------------------------------

disp('Padding data to fit file duration...')
paddedEMG = padStackedAdData(OpenedFileName, 'FP', channelNums(1), EMG);
paddedRaw = padStackedAdData(OpenedFileName, 'FP', channelNums(1), raw);
% pad emg data?
disp('done')

% ------------------------------------------------------------
% Resample Sync to match EMG
% ------------------------------------------------------------

disp('Resample Sync to match EMG')
if size(Sync,2) ~= size(paddedEMG,2)
    freqFactor = int32(size(paddedEMG,2)/size(Sync,2));
    Sync = reshape([Sync; Sync], 1, freqFactor*size(Sync,2));
    if size(Sync,2) > size(paddedEMG,2)
        extraBins = size(Sync,2) - size(paddedEMG,2);
        Sync(end-extraBins+1:end) = [];
    end
end
disp('done')

% ------------------------------------------------------------
% Check to see if the sync pulse was an event 
% instead of analog input
% ------------------------------------------------------------

if ~any(Sync)
    disp('Sync pulse was an event, recalculating...')
    % Get digital Events (Sync pulse)
    [~, ~, evcounts, ~] = plx_info(OpenedFileName,1);
    [~,nevchannels] = size( evcounts );  
    if ( nevchannels > 0 ) 
        % need the event chanmap to make any sense of these
        [~,evchans] = plx_event_chanmap(OpenedFileName);
        for iev = 1:nevchannels
            if ( evcounts(iev) > 0 )
                evch = evchans(iev);
                if ( evch == 257 )
                    [~, tsevs{iev}, ~] = plx_event_ts(OpenedFileName, evch); 
                else
                    [~, tsevs{iev}, ~] = plx_event_ts(OpenedFileName, evch);
                end
            end
        end
    end
    syncTS = tsevs{9};
    syncBins = unique(ts2bin(syncTS, emgFreq));
    
    raw_folder = fileparts(input_filename);
    syncBins = apply_removeFalseSyncs(syncBins, raw_folder);
    
    B = ts2bin(Duration, emgFreq);
    Sync = false(1,B);
    Sync(1,syncBins) = true;
    
    disp('done')
end

% ------------------------------------------------------------
% Format and save according to RGM
% ------------------------------------------------------------

Muscle.EMG = paddedEMG;
Muscle.Raw = paddedRaw;
Muscle.MuscleNames = muscleNames;
Muscle.Freq = emgFreq;
Muscle.Sync = Sync;

disp(['Saving intermediate data ', output_filename])
save(output_filename, 'Muscle', 'emg')
disp('done')

function paddedValues = padStackedAdData(filename, source, channel, values)
    [~, ...
    ~, ...
    ~, ...
    ~, ...
    ~, ...
    ~, ...
    ~, ...
    ~, ...
    ~, ...
    ~, ...
    ~, ...
    Duration, ...
    ~] = plx_information(filename);

    [filename, isPl2] = internalPL2ResolveFilenamePlx( filename );
    if isPl2
        dataStruct = PL2AdBySource(filename, source, channel);
        ts = dataStruct.FragTs;
        counts = dataStruct.FragCounts;
        freq = dataStruct.ADFreq;
    else
        [freq, ~, ts, counts, ~] = plx_ad(filename, [source, sprintf('%02i', channel)]);    
    end
    
    B = ts2bin(Duration, freq);
    R = size(values,1);
    paddedValues = nan(R,B);
    for frag = 1:length(counts)
        start = ts2bin(ts(frag), freq);
        stop = start + counts(frag) - 1;
%         if stop > size(values,2)
%             disp('Warning: check the end of array')
%             stop = size(values,2);
%         end
        if frag == 1
            paddedValues(:,start:stop) = values(:,1:counts(frag));
        else
            paddedValues(:,start:stop) = values(:,counts(frag-1)+1:counts(frag-1)+counts(frag));
        end
    end

function paddedValues = getPaddedAdData(filename, source, channel)
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
    DateTime] = plx_information(filename);

    [filename, isPl2] = internalPL2ResolveFilenamePlx( filename );
    if isPl2
        dataStruct = PL2AdBySource(filename, source, channel);
        ts = dataStruct.FragTs;
        counts = dataStruct.FragCounts;
        freq = dataStruct.ADFreq;
        values = dataStruct.Values;
        values = values';
    else
        [freq, n, ts, counts, values] = plx_ad(filename, [source, sprintf('%02i', channel)]);    
        values = values';
    end
    
    B = ts2bin(Duration, freq);
    paddedValues = nan(1,B);
    for frag = 1:length(counts)
        start = ts2bin(ts(frag), freq);
        stop = start + counts(frag) - 1;
        if frag == 1
            paddedValues(start:stop) = values(1:counts(frag));
        else
            paddedValues(start:stop) = values(counts(frag-1)+1:counts(frag-1)+counts(frag));
        end
    end
    
function stackedValues = getStackedAdData(filename, source, channel)
    [filename, isPl2] = internalPL2ResolveFilenamePlx( filename );
    if isPl2
        dataStruct = PL2AdBySource(filename, source, channel);
%         ts = dataStruct.FragTs;
        counts = dataStruct.FragCounts;
%         freq = dataStruct.ADFreq;
        values = dataStruct.Values;
        values = values';
    else
        [freq, n, ts, counts, values] = plx_ad(filename, [source, sprintf('%02i', channel)]);    
        values = values';
    end
    
    B = sum(counts);
    stackedValues = nan(1,B);
    idx = 1;
    for frag = 1:length(counts)
        start = idx;
        stop = start + counts(frag) - 1;
        if frag == 1
            stackedValues(start:stop) = values(1:counts(frag));
        else
            stackedValues(start:stop) = values(counts(frag-1)+1:counts(frag-1)+counts(frag));
        end
        idx = stop + 1;
    end

function syncBins = apply_removeFalseSyncs(syncBins, raw_folder)
    fname = [raw_folder, '/removeFalseSyncs.m'];
    if exist(fname, 'file')
        disp('Removing false syncs...')
        addpath(raw_folder)
        syncBins = removeFalseSyncs(syncBins);
        rmpath(raw_folder)
        disp('done')
    end

function sampleCounts = getSampleCounts(filename, channel)
[filename, isPl2] = internalPL2ResolveFilenamePlx( filename );
plx_channel = 1 + plx_ad_resolve_channel(filename, ['FP', num2str(channel)]);
if isPl2
    pl2 = PL2GetFileIndex(filename);
    sampleCounts = pl2.AnalogChannels{plx_channel}.NumValues;
    return
end

[n, samplecounts] = plx_adchan_samplecounts(filename);
sampleCounts = samplecounts(plx_channel);

function samplingFrequency = getSamplingFrequency(filename, channel)
[filename, isPl2] = internalPL2ResolveFilenamePlx( filename );
plx_channel = 1 + plx_ad_resolve_channel(filename, ['FP', num2str(channel)]);
if isPl2
    pl2 = PL2GetFileIndex(filename);
    samplingFrequency = pl2.AnalogChannels{plx_channel}.SamplesPerSecond;
    return
end

[n, freqs] = plx_adchan_freqs(filename);
samplingFrequency = freqs(plx_channel);

function filteredSignal = EMGfilter(Fc, high_low, Fs, signal)

% Filter order
if strcmpi( 'high', high_low)
    N = 1;
elseif strcmpi( 'low', high_low)
    N = 4;
else
    error( 'Second argument must be either high or low')
end

% Sampling Frequency
% Fs = 2000;

% Calculate the zeros, poles, and gain of the transfer function using an 
% IIR Butterworth filter
[z,p,k] = butter(N, Fc/(Fs/2), high_low);

% To avoid round-off errors, do not use the transfer function.  Instead
% get the zero-pole-gain representation and convert it to second-order 
% sections.
[sos_var,g] = zp2sos(z, p, k);
Hd          = dfilt.df2sos(sos_var, g);

% Now convert it back to get the transfer function and filter the signal
[b,a] = sos2tf( Hd.sosMatrix, Hd.ScaleValues);
filteredSignal = filtfilt( b, a, signal);
