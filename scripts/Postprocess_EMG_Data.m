function fData = Postprocess_EMG_Data( fData)
% fData = Postprocess_EMG_Data( fData)
%
% Performs any processing of the EMG data that requires information
% from the formatted data.
%
% INPUTS
% ------
% fData : struct
%     The formatted data.
%
% OUTPUTS
% -------
% fData : struct
%     The formatted data with any EMG postprocessing.
%
% sdk29@pitt.edu 2015-12

% Load data
if ~isfield(fData, 'Muscle')
    return;
end

EMG = fData.Muscle.EMG;
intertrialMask = fData.TaskStateMasks.InterTrial;

% Removed negative EMG that are artifact of filter
zeroedEMG = EMG;
zeroedEMG(zeroedEMG<0) = 0;

% Find max EMG during trials
trialEMG = zeroedEMG(:,~intertrialMask);
maxEMG = quantile(trialEMG, 0.999, 2);
%maxEMG = nanmax(trialEMG, [], 2);

% Normalize EMG
normEMG = bsxfun(@rdivide, zeroedEMG, maxEMG);
fData.Muscle.normEMG = normEMG;
