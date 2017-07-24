%%
Position = getMarkerPos('HNDL', Data);
Position = Position(1,:)/10;
Force = Data.Force.data(2,:);

TrialNo = Data.TrialNo;
allTrials = unique(TrialNo);
allTrials(allTrials == 0) = [];

%%
successMask = Data.TaskStateOutcomeMasks.Success;

%%
thresholds = Data.Force.threshold.lower(2,:);
allThresholds = unique(thresholds(~isnan(thresholds)));
targets = Data.Kinematics.TargetWindows(1,:);
allTargets = unique(targets(~isnan(targets)));
allTargets(1) = [];
% 
% %%
% % maskRamp = Data.TaskStateMasks.ForceRamp;
% % maskMove = Data.TaskStateMasks.Move;
% % maskHold = Data.TaskStateMasks.Hold;
% % maskReward = Data.TaskStateMasks.Reward;
% % maskReturn = Data.TaskStateMasks.Return;
% 
maskRamp = Data.TaskStateMasks.Adjusted.ForceRamp;
maskMove = Data.TaskStateMasks.Adjusted.Move;
maskHold = Data.TaskStateMasks.Adjusted.Hold;
maskReward = Data.TaskStateMasks.Adjusted.Reward;
maskReturn = Data.TaskStateMasks.Adjusted.Return;

%%
clf
T = size(allTrials, 2);
for t = 1:T
    oneTrial = allTrials(t);
    trialMask = TrialNo == oneTrial;
    
%     if all((successMask & trialMask) == false)
%         continue
%     end
    
    maskThreshold = thresholds == allThresholds(4);
    maskTarget = targets == allTargets(1);
    trialThreshold = maskThreshold & trialMask;
    trialTarget = maskTarget & trialMask;
    oneThreshold = unique(thresholds(trialThreshold));
    oneTarget = unique(targets(trialTarget));
    if isempty(oneThreshold) || isempty(oneTarget)
        continue
    end
    conditionMask = maskThreshold & maskTarget;
    if all(conditionMask == false)
        continue
    end
    disp(oneTrial)
    
    trialRamp = maskRamp & trialMask;
    trialMove = maskMove & trialMask;
    trialHold = maskHold & trialMask;
    trialReward = maskReward & trialMask;
    trialReturn = maskReturn & trialMask;
    trialMask = cat(1, trialRamp, trialMove, trialHold, trialReward);%, trialReturn);
    if any(all(trialMask == false, 2))
        continue
    end
      
    startRamp = find(trialRamp, 1, 'first');
    startMove = find(trialMove, 1, 'first');
    startHold = find(trialHold, 1, 'first');
    startReward = find(trialReward, 1, 'first');
    startReturn = find(trialReturn, 1, 'first');
%     oStart = [startRamp, startMove, startHold, startReward, startReturn];
    
%     rampF = Force;
%     rampF(~trialRamp) = nan;
%     startRamp = find(rampF < 1, 1, 'last') - 1;
%     
%     rampF = Force;
%     rampF(~(trialRamp | trialMove)) = nan;
%     startMove = find(rampF > oneThreshold, 1, 'first');
%     
%     moveP = Position;
%     moveP(~(trialRamp | trialMove | trialHold)) = nan;
%     startHold = find(moveP > oneTarget, 1, 'first');
%     if isempty(startHold)
%         continue
%     end
    
%     startReward = startHold + 30;
%     startReturn = startReward + 30;

    
    start = [startRamp, startMove, startHold, startReward];%, startReturn];
    if length(start) < 3
        sprintf('%s\n', 'short')
        continue
    end
    
    before = 15;
    after = 30;
    
    for i =1:length(start)
        mask = false(length(startRamp));
        mask(start(i)-before:start(i)+after) = true;
        
        subplot(2,length(start),i)
        hold on
        plot(Data.Dt*(-before:after), Force(mask))
        plot(Data.Dt*[-before, after], [oneThreshold, oneThreshold], 'k')
        axis([-Data.Dt*before, Data.Dt*after, -5, 1.5*allThresholds(4)])
        subplot(2,length(start),length(start)+i)
        hold on
        plot(Data.Dt*(-before:after), Position(mask))
        plot(Data.Dt*[-before, after], [oneTarget, oneTarget], 'k')
        axis([-Data.Dt*before, Data.Dt*after, 0, 22.5])
    end
end
hold off