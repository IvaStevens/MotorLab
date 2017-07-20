function combineSessions(monkey_sessions)
% combineSessions(monkey_sessions)
%
% Combine multiple data sessions. Applies some edits to individual sessions
% and to the combined data. Please check.
%
% Parameters
% ----------
% monkey_sessions : {1x2} cell
%     The first cell is a string of the monkey's name. The second cell is
%     an array of session numbers.
%
% sdk29@pitt.edu 2017-01

monkey = monkey_sessions{1};
Sessions = monkey_sessions{2};
N = length(Sessions);

dataDirectory = fullfile('C:', 'Users', 'scott', 'Scott_UPitt', 'Schwartz', 'rgm', 'data');
addpath(fullfile('C:', 'Users', 'scott', 'Scott_UPitt', 'matlab'))
addpath(fullfile('C:', 'Users', 'scott', 'Scott_UPitt', 'matlab', 'unitID'))

allData = repmat(struct(), N, 1);
for i = 1:N
    oneSession = Sessions(i);
    sk_disp(num2str(oneSession))
    
    matFile = fullfile(dataDirectory, monkey, ...
               [monkey, '.RGM.00', num2str(oneSession)],...
               [monkey, '.00', num2str(oneSession), '.mat']);
    oneData = load(matFile);
    if i == 1
        allData = oneData.Data;
    else
        allData(i) = oneData.Data;
    end
end

% allData(4) = EditData(allData(4));
sk_disp('Combining data...')
Data = CatStructFields(allData, 'horizontal');
Data = EditCombinedData(Data);
sk_disp('done')

output_file = fullfile(dataDirectory, monkey, ...
               [monkey, '.RGM.Combined'], ...
               [monkey, '.00', num2str(Sessions(1)), '_00', num2str(Sessions(end)), '.mat']);
sk_disp(['Saving ', output_file])
save(output_file, 'Data')
sk_disp('done')

function Data = EditData(Data)
    Data.Kinematics.MarkerNames = Data.Kinematics.MarkerNames(13);
    Data.Kinematics.MarkerPos = Data.Kinematics.MarkerPos(37:39,:);
    
function Data = EditCombinedData(Data)
    N = length(Data.SessionNo);
    Data.Dt = Data.Dt(1:length(Data.Dt)/N);
    Data.Version = Data.Version(1:length(Data.Version)/N);
    Data.Build = Data.Build(1:length(Data.Build)/N);
    Data.ConfigName = Data.ConfigName(1:length(Data.ConfigName)/N);
%     Data.Force.JointNames = Data.Force.JointNames(1:length(Data.Force.JointNames)/N);
    Data.Kinematics.MarkerNames = Data.Kinematics.MarkerNames(1:length(Data.Kinematics.MarkerNames)/N);
%     Data.Kinematics.JointNames = Data.Kinematics.JointNames(1:length(Data.Kinematics.JointNames)/N);
    Data.Muscle.MuscleNames = Data.Muscle.MuscleNames(1:length(Data.Muscle.MuscleNames)/N);
