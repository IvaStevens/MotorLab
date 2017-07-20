function Preprocess_Plexon_Neural(monkey_session)
% Preprocess_Plexon_Neural(monkey_session)
%
% Converts the spike timestamps to time bins and saves in the intermediate
% directory.
%
% INPUTS
% ------
%
% OUTPUTS
% -------
%
% sdk29@pitt.edu 2016-09

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
output_filename = [DataPath, '/Plexon/Intermediate/Neural/',...
                   monkey, '.RGM.00', session '.mat'];
config_filename = [DataPath, '/', monkey, '/Raw/',...
                   monkey, '.RGM.00', session, '/',...
                   'PlexonNeural.config'];

if ~exist(config_filename, 'file')
    return;
end

sk_disp('Preprocess_Plexon_Neural')

if ~exist( input_filename, 'file')              
    sk_disp(['Input filename does not exist: ', input_filename])
    input_filename = [input_filename(1:end-1), 'x'];
    if ~exist(input_filename, 'file')
        return;
    end
    sk_disp(['Using plx file as input: ', input_filename])
end
               
if exist( output_filename, 'file')
    sk_disp( ['\nFile ', output_filename, ' already exists. '])
    sk_disp( 'To overwrite, first delete existing file.')
    return
end

LoadTextData(config_filename)
arrayNames = config.names;
startStopNums = config.channelNum;

% Get header information from pl file
[OpenedFileName, ...
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
    ~] = plx_information(input_filename);

% --------------------------------------------------------
% Extract sync pulses
% --------------------------------------------------------

% sk_disp('Extracting sync pulses...')
% sync_struct = PL2AdBySource(OpenedFileName, 'AI', 1);
% syncFreq = sync_struct.ADFreq;
% syncDt = 1/syncFreq;
% syncValues = sync_struct.Values;
% syncBool = syncValues > 2500;
% sk_disp('done')

sk_disp('Extracting sync pulses...')
syncValues = getPaddedAdData(OpenedFileName, 'AI', 1);
allSync = syncValues > 2500;
syncFreq = getSamplingFrequency(OpenedFileName, 1);
dfFreq = 100;
dsRate = int32(syncFreq/dfFreq);
Sync = downsample(allSync, dsRate);
% syncDt = 1/syncFreq;
sk_disp('done')

% --------------------------------------------------------
% Extract neural data
% --------------------------------------------------------

sk_disp('Extracting timestamps...')
nchannels = startStopNums(end);
nunits = 5; % Empirically, no channel has more than 5 units

[tscounts, ~, ~, ~] = plx_info(OpenedFileName,1);

% Loop over all the units and create a cell array of timestamps
allTS = cell(nchannels, nunits);
allWaves = cell(nchannels, nunits);
for ich = 1:nchannels
    for iunit = 1:nunits
        if (tscounts(iunit,ich+1) > 0)
            wave = PL2Waves(OpenedFileName, ich, iunit-1);
            [allTS{ich,iunit}] = wave.Ts;
            [allWaves{ich,iunit}] = wave.Waves;
%             [allTS{ich,iunit}] = PL2Ts(OpenedFileName, ich, iunit-1);
        end
    end
end
sk_disp('done')

% Initialize array variables to convert timestamps to time bins
% B = ts2bin(Duration, syncFreq);
B = length(Sync);
U = nchannels*nunits;
spikeData = nan(U,B);
waveAvg = nan(U,B);

% Loop over all the units and convert timestamps to time bins
sk_disp('Converting timestamps to time bins...')
Channel = nan(size(spikeData, 1),1);
Unit = nan(size(spikeData, 1),1);
for u = 1:nunits
    sk_disp(num2str(u))
    for c = 1:nchannels
        channel = c;
        unit = u;
        
        waveTS = allTS{channel,unit};
%         waveBins = ts2bin(waveTS, syncFreq);
        [waveFR, ~] = SpikeTimes2FractIntRates(waveTS', .01, [0, Duration-.01]);
        
        idx = nchannels*(unit-1) + channel;
%         spikeData(idx,waveBins) = true;
        spikeData(idx,:) = waveFR;
        waveAvg(idx,:) = mean(allWaves{channel,unit},1);
        Channel(idx) = channel;
        Unit(idx) = unit;
    end
end
sk_disp('done')

% --------------------------------------------------------
% Pad sync to fit duration of file
% --------------------------------------------------------

% sk_disp('Padding data to fit file duration...')
% Sync = nan(1,B);
% 
% syncFirstTimestamp = sync_struct.FragTs(1);
% syncFirstBin = ts2bin(syncFirstTimestamp, syncFreq);
% syncCounts = sum(sync_struct.FragCounts);
% start = syncFirstBin;
% stop = syncFirstBin + syncCounts - 1;
% Sync(1,start:stop) = syncBool;
% 
% sk_disp('done')

% ------------------------------------------------------------
% Check to see if the sync pulse was an event instead of analog input
% ------------------------------------------------------------

if ~any(Sync)
    sk_disp('Sync pulse was an event, recalculating...')
    emgFreq = 2000;
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
                    [nevs{iev}, tsevs{iev}, ~] = plx_event_ts(OpenedFileName, evch); 
                else
                    [nevs{iev}, tsevs{iev}, ~] = plx_event_ts(OpenedFileName, evch);
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

    sk_disp('done')
end

% --------------------------------------------------------
% Format according to RGM
% --------------------------------------------------------

Spikes.Channel = Channel;
Spikes.Unit = Unit;
% Spikes.SpikeCount = spikeData;
Spikes.FiringRate = spikeData;
Spikes.AverageWaveform = waveAvg;
Spikes.Sync = Sync;
% Spikes.Freq = syncFreq;
Spikes.Freq = 100;
Spikes.ArrayNames = arrayNames;
Spikes.StartStopArrayChannelNums = startStopNums;

sk_disp(['Saving intermediate data ', output_filename])
save(output_filename, 'Spikes', '-v7.3')
sk_disp('done')

function samplingFrequency = getSamplingFrequency(filename, channel)
    [filename, isPl2] = internalPL2ResolveFilenamePlx( filename );
    plx_channel = 1 + plx_ad_resolve_channel(filename, ['AI', sprintf('%02i', channel)]);
    if isPl2
        pl2 = PL2GetFileIndex(filename);
        samplingFrequency = pl2.AnalogChannels{plx_channel}.SamplesPerSecond;
        return
    end

    [~, freqs] = plx_adchan_freqs(filename);
    samplingFrequency = freqs(plx_channel);

function paddedValues = getPaddedAdData(filename, source, channel)
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
        values = dataStruct.Values;
        values = values';
    else
        [freq, ~, ts, counts, values] = plx_ad(filename, [source, sprintf('%02i', channel)]);    
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
    
function syncBins = apply_removeFalseSyncs(syncBins, raw_folder)
    fname = [raw_folder, '/removeFalseSyncs.m'];
    if exist(fname, 'file')
        sk_disp('Removing false syncs...')
        addpath(raw_folder)
        syncBins = removeFalseSyncs(syncBins);
        rmpath(raw_folder)
        sk_disp('done')
    end
