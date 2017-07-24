%%
allTrials = unique(Data.TrialNo);
allTrials(allTrials == 0) = [];
T = length(allTrials);

FiringRate = Data.Spikes.FiringRate;
S = size(FiringRate,1);

%%
comboNo = Data.ComboNo;
allCombos = unique(comboNo);
allCombos(allCombos == 0) = [];
C = length(allCombos);

%%
FR = nan(S,T);
Combo = nan(1,T);

for t = 1:T
    oneTrial = allTrials(t);
    trialMask = Data.TrialNo == oneTrial;
    
    combo = unique(comboNo(trialMask));
    combo(combo == 0) = [];
    
    rampMask = Data.TaskStateMasks.Adjusted.ForceRamp;
    moveMask = Data.TaskStateMasks.Adjusted.Move;
    holdMask = Data.TaskStateMasks.Adjusted.Hold;
    
    ramp = rampMask & trialMask;
    move = moveMask & trialMask;
    hold = holdMask & trialMask;
    
    mask = ramp | move | hold;
    
    FR(:,t) = mean(FiringRate(:,mask), 2);
    Combo(t) = combo;
end

%%
fr = nan(S,C);

for c = 1:C
    oneCombo = allCombos(c);
    mask = oneCombo == Combo;
    fr(:,c) = nanmean(FR(:,mask), 2);
end