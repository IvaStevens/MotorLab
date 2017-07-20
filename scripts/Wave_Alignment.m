raw_filename = '/home/scott/rgm/data/Plexon/Raw/Ivan/Ivan.RGM.00308/Ivan.RGM.00308-01.PLX';
intermediate_filename = '/home/scott/rgm/data/Plexon/Intermediate/Ivan.RGM.00308.mat';

[OpenedFileName, ...
    Version, ...
    Freq, ...
    Comment, ...
    Trodalness, ...
    NPW, ...
    PreTresh, ...
    SpikePeakV, ...
    SpikeADResBits, ...
    SlowPeakV, ...
    SlowADResBits, ...
    Duration, ...
    DateTime] = plx_information(raw_filename);
load(intermediate_filename)

syncFreq = Muscle.Freq;
sync = Muscle.Sync;

B = int32(Duration*syncFreq)+1;
waveAllBins = false(B,1);

oneChannel = SPKC042;

unitMask = oneChannel(:,2) == 1;
unitTS = SPKC042(unitMask,3);
unitBins = int32(unitTS*syncFreq)+1;

waveAllBins(unitBins) = true;


startChannel = plx_event_resolve_channel(OpenedFileName, 'Start');
stopChannel = plx_event_resolve_channel(OpenedFileName, 'Stop');


% [n, startTS, sv] = plx_event_ts(OpenedFileName, startChannel);
% [n, stopTS, sv] = plx_event_ts(OpenedFileName, stopChannel);

startBins = int32(startTS*syncFreq)+1;
stopBins = int32(stopTS*syncFreq)+1;
stopBins = stopBins(1:end-1);

if length(startBins) ~= length(stopBins)
    disp('Error: not the same number of start and stop events')
end

keepMask = false(size(waveAllBins));
for i = 2:length(startBins)
    start = startBins(i);
    stop = stopBins(i);
    keepMask(start:stop) = true;
end

waveBins = waveAllBins(keepMask);


extraBins = Duration*syncFreq - length(sync);
sprintf('%f', extraBins)

removedBins = sum(~keepMask);
sprintf('%f', removedBins)

extraTime = Duration - length(sync)/syncFreq;
sprintf('%f', extraTime)

removedTime = sum(~keepMask)/syncFreq;
sprintf('%f', removedTime)

totalPause = 0;
for i = 1:length(startTS)-1
    pauseTime = startTS(i+1) - stopTS(i);
    totalPause = totalPause + pauseTime;
end
totalPause = totalPause + (stopTS(end) - stopTS(end-1));