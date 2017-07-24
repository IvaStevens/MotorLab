function trialThreshold = getTrialThreshold(oneTrial, Data)
trialNo = Data.TrialNo;
thresholds = Data.Force.threshold.lower(2,:);

trialMask = oneTrial == trialNo;
nanMask = isnan(thresholds);
mask = trialMask & ~nanMask;

trialThreshold = unique(thresholds(mask));
if isempty(trialThreshold)
    trialThreshold = nan;
end