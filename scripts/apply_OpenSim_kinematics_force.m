%%
clear
clc

subject = 'Ivan';
allSessions = {'376'};%, '377', '378', '379', '380'};
for n = 1:length(allSessions)
    oneSession = allSessions{n};
    dataDirectory = fullfile('..', ...
        'data', ...
        subject, ...
        [subject, '.RGM.00', oneSession]);
    dataFile = [subject, '.00' oneSession, '.mat'];
    load(fullfile(dataDirectory, dataFile))
%     scaleOpenSimModel({subject, str2double(oneSession)})
    Data = Postprocess_Joint_Kinematics(Data);
%     Data = Postprocess_Force_Data(Data);
    save(fullfile(dataDirectory, dataFile), 'Data')
    clear Data
end