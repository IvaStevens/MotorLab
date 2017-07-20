function fData = Postprocess_TaskStateMasks(fData)
% fData = Postprocess_TaskStateMasks(fData)
%
% Performs any processing of the task state masks that requires 
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
%     The formatted data with any task state masks postprocessing.
%
% sdk29@pitt.edu 2015-12

if ~isfield(fData, 'Kinematics') || ~isfield(fData, 'Force')
    return;
end
if ~ismember('HNDL', fData.Kinematics.MarkerNames)
    return;
end

sk_disp('Postprocess_TaskStateMasks')

%-----------%
% Load data %
%-----------%
Position = getMarkerPos('HNDL', fData);
Force = fData.Force.data(2,:);

TrialNo = fData.TrialNo;
allTrials = unique(TrialNo);
allTrials(allTrials == 0) = [];

rampMask = fData.TaskStateMasks.ForceRamp;
moveMask = fData.TaskStateMasks.Move;
holdMask = fData.TaskStateMasks.Hold;
rewardMask = fData.TaskStateMasks.Reward;
returnMask = fData.TaskStateMasks.Return;

%-------------------------------------%
% Initialize correct task state masks %
%-------------------------------------%
new_reach = false(size(rampMask));
new_ramp = false(size(rampMask));
new_move = false(size(rampMask));
new_hold = false(size(rampMask));
new_reward = false(size(rampMask));
new_return = false(size(rampMask));

fData.TaskStateMasks.Adjusted.Reach = false(size(rampMask));
fData.TaskStateMasks.Adjusted.ForceRamp = false(size(rampMask));
fData.TaskStateMasks.Adjusted.Move = false(size(rampMask));
fData.TaskStateMasks.Adjusted.Hold = false(size(rampMask));
fData.TaskStateMasks.Adjusted.Reward = false(size(rampMask));
fData.TaskStateMasks.Adjusted.Return = false(size(rampMask));

% allTrials = [155];
T = size(allTrials,2);
for t = 1:T
    oneTrial = allTrials(t);
    trialMask = TrialNo == oneTrial;
    N = sum(trialMask);
    
    threshold = getTrialThreshold(oneTrial, fData);
    target = getTrialTarget(oneTrial, fData);
    if any(isnan(target)) || isnan(threshold)
        continue
    end
    target = target(1);
    
    trialRamp = rampMask(trialMask);
    trialMove = moveMask(trialMask);
    trialHold = holdMask(trialMask);
    trialReturn = returnMask(trialMask);
    
    startReach = find(trialRamp, 1, 'first');
    stopReturn = find(trialReturn, 1, 'last');
    
    trialF = Force(trialMask);
    trialP = Position(trialMask);
    
    %---------------------%
    % Find index of grasp %
    %---------------------%
    % The last time that force exceeds 1 N
    rampF = trialF;
    rampF(~trialRamp) = nan;
    startRamp = find(rampF < 1, 1, 'last');
    
    %----------------------------------%
    % Find index of threshold crossing %
    %----------------------------------%
    rampF = trialF;
    rampF(~(trialRamp | trialMove)) = nan;
    startMove = find(rampF > threshold, 1, 'first');
    
    %----------------------------%
    % Find index of target enter %
    %----------------------------%
%     moveP = trialP;
%     moveP(~(trialRamp | trialMove | trialHold)) = nan;
%     startHold = find(moveP > target, 1, 'first');
    startHold = find(trialHold, 1, 'first');
    
    %------------------------------------------------------------%
    % Fill in the rest of the states based on the config timeout %
    %------------------------------------------------------------%
    startReward = min([startHold + 30, N]);
    startReturn = min([startReward + 30, N]);
    
    %---------------------------------%
    % Initialize new task state masks %
    %---------------------------------%
    trialReach = false(1,N);
    trialRamp = false(1,N);
    trialMove = false(1,N);
    trialHold = false(1,N);
    trialReward = false(1,N);
    trialReturn = false(1,N);
    
    %--------------------------%
    % Correct task state masks %
    %--------------------------%
    trialReach(startReach:startRamp-1) = true;
    trialRamp(startRamp:startMove-1) = true;
    trialMove(startMove:startHold-1) = true;
    if ~isempty(startHold)
        trialHold(startHold:startReward-1) = true;
        trialReward(startReward:startReturn-1) = true;
        trialReturn(startReturn:stopReturn) = true;
    end

    %-----------------------------------%
    % Insert corrected task state masks %
    %-----------------------------------%
    new_reach(trialMask) = trialReach;
    new_ramp(trialMask) = trialRamp;
    new_move(trialMask) = trialMove;
    new_hold(trialMask) = trialHold;
    new_reward(trialMask) = trialReward;
    new_return(trialMask) = trialReturn;
end

fData.TaskStateMasks.Adjusted.Reach = new_reach;
fData.TaskStateMasks.Adjusted.ForceRamp = new_ramp;
fData.TaskStateMasks.Adjusted.Move = new_move;
fData.TaskStateMasks.Adjusted.Hold = new_hold;
fData.TaskStateMasks.Adjusted.Reward = new_reward;
fData.TaskStateMasks.Adjusted.Return = new_return;