%%
clc
clear
close all

%%
load /home/scott/Scott_UPitt/Schwartz/rgm/data/Human_Experiment/KingKong.RGM.00411/KingKong.00411.mat
% load /home/scott/Scott_UPitt/Schwartz/rgm/data/Ivan/Ivan.RGM.00380/Ivan.00380.mat

%%
rampMask = Data.TaskStateMasks.ForceRamp;
moveMask = Data.TaskStateMasks.Move;
holdMask = Data.TaskStateMasks.Hold;
reachMask = false(size(holdMask));

TrialNo = Data.TrialNo;
allTrials = unique(TrialNo);
allTrials(allTrials == 0) = [];

Position = getMarkerPos('HNDL', Data);
Force = Data.Force.data(2,:);

%%
T = size(allTrials,2);
fprintf('\n\n')
for t = 1:T
    oneTrial = allTrials(t);
    fprintf('%i, ', T-t)
    trialMask = TrialNo == oneTrial;
    N = sum(trialMask);

    trialF = Force(trialMask);
    trialP = Position(1,trialMask);
    trialRamp = rampMask(trialMask);
    trialMove = moveMask(trialMask);
    trialHold = holdMask(trialMask);

    rampF = trialF(trialRamp);
    if isempty(rampF)
        continue;
    end
    f = rampF(1:20);

    fm = mean(f);
    fHigh = max(f) - fm;
    threshold = 3;
    high = fm + threshold*fHigh;
    graspIdx = find(rampF < high, 1, 'last') + 1;
    
    threshold = getTrialThreshold(oneTrial, Data);
    thresholdIdx = find(trialF > threshold, 1, 'first');
    
    target = getTrialTarget(oneTrial, Data)*10;
    targetIdx = find(trialP > target(1), 1, 'first');

    reachStart = find(trialRamp, 1, 'first');
    trialReach = false(1,N);
    trialReach(reachStart:graspIdx-1) = true;
    trialRamp = false(1,N);
    trialRamp(graspIdx:thresholdIdx-1) = true;
    trialMove = false(1,N);
    trialMove(thresholdIdx:targetIdx-1) = true;
    trialHold = false(1,N);
    trialHold(targetIdx:targetIdx+30) = true;
end

%%
close('all')
hold on
plot(trialReach, 'r.-')
plot(trialRamp+0.1, 'g.-')
plot(trialMove+0.2, 'b.-')
plot(trialHold+0.3, 'k.-')
hold off