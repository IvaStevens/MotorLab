clear
clc
close all

addpath('C:/Users/scott/Scott_UPitt/matlab/osimTools/')

% sessionFolder = 'C:/Users/scott/Scott_UPitt/Schwartz/rgm/data/Human_Experiment/KingKong.RGM.00411/';
sessionFolder = pwd;
sessionFile = 'KingKong.00411.mat';
load(sessionFile)

oneCombo = 1;
ikFile = [sessionFile(1:end-4), sprintf('%02i', oneCombo), '_IK.mot'];
idFile = [sessionFile(1:end-4), sprintf('%02i', oneCombo), '_JointTorques.sto'];

ikFilePath = [sessionFolder, '/OpenSim/InverseKinematics/', ikFile];
[ikData, ikColumnLabels] = readStorageFile(ikFilePath);

idFilePath = [sessionFolder, '/OpenSim/InverseDynamics/', idFile];
[idData, idColumnLabels] = readStorageFile(idFilePath);

