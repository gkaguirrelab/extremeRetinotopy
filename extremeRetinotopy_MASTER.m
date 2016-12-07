% MASTER script for processing extreme retinotopy data
%
%   Written by Andrew S Bock Dec 2016

%% Clean up dicoms, put into more 'standard' format
dataDir             = '/Users/abock/data/extremeRetinotopy/testSubject';
params.inDir        = fullfile(dataDir,'originalDICOMS');
params.outDir       = fullfile(dataDir,'DICOMS');
extremeRetinotopyDicoms(params);
%% Sort the dicoms, convert to nifti
session_dir         = dataDir;
dicom_dir           = fullfile(dataDir,'DICOMS');
useMRIcron          = 1;
isGE                = 1;
sort_nifti(session_dir,dicom_dir,useMRIcron,isGE);
%% Create preprocessing scripts
params.sessionDir       = dataDir;
params.subjectName      = 'extremeRetino';
params.dicomDir         = fullfile(params.sessionDir,'DICOMS');
params.useMRIcron       = 1;
params.isGE             = 1;
params.outDir           = fullfile(params.sessionDir,'preprocessing_scripts');
params.logDir           = '/data/jet/abock/LOGS';
params.jobName          = params.subjectName;
params.numRuns          = 4; % number of bold runs
params.reconall         = 0;
params.despike          = 1;
params.slicetiming      = 0;
params.topup            = 0;
params.refvol           = 1;
params.regFirst         = 1;
params.filtType         = 'high';
params.lowHz            = 0.01;
params.highHz           = 0.10;
params.physio           = 0;
params.motion           = 1;
params.task             = 0;
params.localWM          = 1;
params.anat             = 1;
params.amem             = 20;
params.fmem             = 50;
create_preprocessing_scripts(params);