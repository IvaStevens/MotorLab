clear
clc
close all

addpath('C:/Users/scott/Scott_UPitt/matlab/unitID')
monkey_session = {'Ivan', [377, 378]};%, 378, 379, 380]};
monkey = monkey_session{1};
allSessions = monkey_session{2};
S = length(allSessions);

Data_src = 'C:/Users/scott/Scott_UPitt/Schwartz/rgm/data/Ivan/';

CHANNEL = cell(S,1);
UNIT = cell(S,1);
SPIKETIMES = cell(S,1);
WMEAN = cell(S,1);
for s = 1:S
    sessionDirectory = sprintf('%s.RGM.%05i/', monkey, allSessions(s));
    sessionFile = sprintf('%s.%05i.mat', monkey, allSessions(s));
    sk_disp(sessionFile)
    load([Data_src, sessionDirectory, sessionFile]);
    
%     C = 256;
%     allChannels = nan(1,C);
%     N = 0;
%     for c = 1:256
%         channel = c;
%         channelStr = sprintf('SPK%03i', channel);
%         channelData = sessionData.(channelStr);
%         allUnits = unique(channelData(:,2));
%         N = N + length(allUnits);
%         if ~isempty(allUnits)
%             allChannels(c) = c;
%         end
%     end
%     allChannels = allChannels(~isnan(allChannels));
%     C = length(allChannels);
%     Channel = nan(N, 1);
%     Unit = nan(N, 1);
%     Spiketimes = cell(N, 1);
%     Wmean = cell(N, 1);
% 
%     n = 1;
%     for c = 1:C
%         channel = allChannels(c);
%         channelStr = sprintf('SPK%03i', channel);
%         channelData = sessionData.(channelStr);
%         allUnits = unique(channelData(:,2));
%         U = length(allUnits);
%         for u = 1:U
%             unit = allUnits(u);
%             mask = channelData(:,2) == unit;
%             unitData = channelData(mask,3:end);
%             spiketimes = unitData(:,1);
%             wmean = mean(unitData(:,2:end),1);
% 
%             Channel(n) = channel;
%             Unit(n) = unit;
%             Spiketimes{n} = spiketimes;
%             Wmean{n} = wmean;
%             n = n + 1;
%         end
%     end
    CHANNEL{s} = Data.Spikes.Channel;
    UNIT{s} = Data.Spikes.Unit;
    SPIKETIMES{s} = Data.Spikes.SpikeTS;
    WMEAN{s} = Data.Spikes.AverageWaveform;
    clear sessionData
end

[survival, ...
    score, ...
    corrscore, ...
    wavescore, ...
    autoscore, ...
    basescore, ...
    correlations] = unitIdentification(CHANNEL, UNIT, SPIKETIMES, WMEAN);