function fData = Postprocess_Force_Data(fData)
% fData = Postprocess_Kinematics_Data( fData)
%
% Performs any processing of the kinematic data that requires 
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
%     The formatted data with any EMG postprocessing.
%
% sdk29@pitt.edu 2015-12

% Load data
if ~isfield(fData, 'Force')
    return;
end
sk_disp('Postprocess_Force_Data')

Force = fData.Force.data(2,:);
forceThreshLower = fData.Force.threshold.lower;
trialRamp = fData.TaskStateMasks.ForceRamp;

maxThreshold = max(forceThreshLower(2,trialRamp));
refF = 2*maxThreshold/100;
normForce = Force/refF;
normThreshLower = forceThreshLower/refF;

fData.Force.normData = normForce;
fData.Force.threshold.normLower = normThreshLower;