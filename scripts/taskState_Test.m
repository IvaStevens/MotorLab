%%
myData = fData;

Force = myData.Force.data(2,:);

trialNo = myData.TrialNo;
allTrials = unique(trialNo);
allTrials(allTrials == 0) = [];
T = length(allTrials);

dt = myData.Dt;

reachMask = myData.TaskStateMasks.Adjusted.Reach;
rampMask = myData.TaskStateMasks.Adjusted.ForceRamp;
moveMask = myData.TaskStateMasks.Adjusted.Move;
holdMask = myData.TaskStateMasks.Adjusted.Hold;
time = nan(size(rampMask));

for t = 12
    oneTrial = allTrials(t);
    trialMask = trialNo == oneTrial;
    N = sum(trialMask);
    time(trialMask) = linspace(0, N*dt, N);

%     allBins = find(trialMask & rampMask);
%     B = length(allBins);
%     rms = 1;
%     while (rms > 0.05 && B > 0)
%         oneBin = allBins(B);
%         f = Force(oneBin-10:oneBin);
%         fm = mean(f);
%         rms = sqrt(mean((f-fm).^2));
%         fprintf('%i = %f\n', [oneBin, rms])
%         
%         plot(allBins, Force(trialMask & rampMask), '.-')
%         hold on        
%         plot(oneBin-10:oneBin, f, 'r.-')
%         hold off
%         
%         B = B - 1;
%         waitforbuttonpress
%     end
        
    
    rampF = Force(trialMask & rampMask);
    if isempty(rampF)
        continue
    end
%     
%     mask = trialMask & rampMask;
%     subplot(2,1,1)
%     plot(time(mask), Force(mask), '.-')
%     subplot(2,1,2)
%     plot(time(mask), [diff(Force(mask)), nan])
    
    reachF = Force(trialMask & reachMask);
    moveF = Force(trialMask & moveMask);
    holdF = Force(trialMask & holdMask);
    
    plot(time(trialMask & reachMask), reachF, 'r.-')
    hold on
    plot(time(trialMask & rampMask), rampF, 'g.-')
    plot(time(trialMask & moveMask), moveF, 'b.-')
    plot(time(trialMask & holdMask), holdF, 'k.-')
    threshold = getTrialThreshold(oneTrial, Data);
    line([0,nanmax(time(trialMask & holdMask))], [threshold, threshold])
    hold off
    
    waitforbuttonpress
end