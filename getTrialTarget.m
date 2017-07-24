function trialTarget = getTrialTarget(oneTrial, Data)
trialNo = Data.TrialNo;
targets = Data.Kinematics.TargetWindows;

trialMask = oneTrial == trialNo;
nanMask = any(isnan(targets), 1);
mask = trialMask & ~nanMask;

trialTarget = unique(targets(:,mask));
trialTarget(trialTarget == 0) = [];
trialTarget(trialTarget == 0.625) = [];
if isempty(trialTarget)
    trialTarget = nan;
end