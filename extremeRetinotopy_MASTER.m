% MASTER script for processing extreme retinotopy data
%
%   Written by Andrew S Bock Dec 2016

%% Clean up dicoms, put into more 'standard' format
dataDir                     = '/Users/abock/data/extremeRetinotopy/testSubject';
dcmParams.inDir             = fullfile(dataDir,'originalDICOMS');
dcmParams.outDir            = fullfile(dataDir,'DICOMS');
extremeRetinotopyDicoms(dcmParams);
%% Sort the dicoms, convert to nifti
session_dir                 = dataDir;
dicom_dir                   = fullfile(dataDir,'DICOMS');
useMRIcron                  = 1;
isGE                        = 1;
sort_nifti(session_dir,dicom_dir,useMRIcron,isGE);
%% Create preprocessing scripts
preParams.sessionDir        = dataDir;
preParams.subjectName       = 'extremeRetino';
preParams.dicomDir          = fullfile(preParams.sessionDir,'DICOMS');
preParams.useMRIcron        = 1;
preParams.isGE              = 1;
preParams.outDir            = fullfile(preParams.sessionDir,'preprocessing_scripts');
preParams.logDir            = '/data/jet/abock/LOGS';
preParams.jobName           = preParams.subjectName;
preParams.numRuns           = 4; % number of bold runs
preParams.reconall          = 0;
preParams.despike           = 1;
preParams.slicetiming       = 0;
preParams.topup             = 0;
preParams.refvol            = 1;
preParams.regFirst          = 1;
preParams.filtType          = 'high';
preParams.lowHz             = 0.01;
preParams.highHz            = 0.10;
preParams.physio            = 0;
preParams.motion            = 1;
preParams.task              = 0;
preParams.localWM           = 1;
preParams.anat              = 1;
preParams.amem              = 20;
preParams.fmem              = 50;
create_preprocessing_scripts(preParams);

%%% Run the preprocessing scripts %%%

%% Concatenate the retinotopy runs
b                           = find_bold(preParams.sessionDir);
% left hemisphere
lhRing                      = load_nifti(fullfile(preParams.sessionDir,b{1},'wdrf.tf.surf.lh.nii.gz'));
lhWedge                     = load_nifti(fullfile(preParams.sessionDir,b{2},'wdrf.tf.surf.lh.nii.gz'));
out                         = lhRing;
out.dim(5)                  = out.dim(5)*2;
tmp1                        = convert_to_psc(squeeze(lhRing.vol));
tmp2                        = convert_to_psc(squeeze(lhWedge.vol));
out.vol                     = [tmp1,tmp2];
save_nifti(out,fullfile(preParams.sessionDir,'pRFs','lh.surf.tcs.nii.gz'));
% right hemisphere
rhRing                      = load_nifti(fullfile(preParams.sessionDir,b{3},'wdrf.tf.surf.rh.nii.gz'));
rhWedge                     = load_nifti(fullfile(preParams.sessionDir,b{4},'wdrf.tf.surf.rh.nii.gz'));
out                         = rhRing;
out.dim(5)                  = out.dim(5)*2;
tmp1                        = convert_to_psc(squeeze(rhRing.vol));
tmp2                        = convert_to_psc(squeeze(rhWedge.vol));
out.vol                     = [tmp1,tmp2];
save_nifti(out,fullfile(preParams.sessionDir,'pRFs','rh.surf.tcs.nii.gz'));
%% Make retinotopy stimuli
[rings,wedges] = makeRingsWedges;
% Rings - left hemifield
ringsLeft = repmat(rings,1,1,8);
ringsLeft = cat(3,128*ones(size(ringsLeft,1),size(ringsLeft,2),3),ringsLeft);
% Rings - right hemifield
ringsRight = fliplr(ringsLeft);
% Wedges - left hemifield
wedgesLeft = repmat(wedges,1,1,8);
wedgesLeft = cat(3,128*ones(size(wedgesLeft,1),size(wedgesLeft,2),3),wedgesLeft);
% Wedges - right hemifield
wedgesRight = rot90(wedgesLeft,2);
%% Save stimuli in .mat file
outDir                  = fullfile(preParams.sessionDir,'Stimuli');
if ~exist(outDir,'dir')
    mkdir(outDir);
end
params.framesPerTR          = 1;
params.fieldSize            = 72;
params.TR                   = 3;
params.stimParams.imagesFull = cat(3,ringsLeft,wedgesLeft);
save(fullfile(outDir,'rh.ringWedge.mat'),'params');
params.stimParams.imagesFull = cat(3,ringsRight,wedgesRight);
save(fullfile(outDir,'lh.ringWedge.mat'),'params');
%% Make pRF maps
hemis           = {'lh' 'rh'};
b               = find_bold(preParams.sessionDir);
for hh = 1:2
    params.stimFile = fullfile(outDir,[hemis{hh} '.ringWedge.mat']);
    params.inVol    = fullfile(preParams.sessionDir,'pRFs',[hemis{hh} '.surf.tcs.nii.gz']);
    params.outDir   = fullfile(preParams.sessionDir,'pRFs');
    params.baseName = hemis{hh};
    % Calculate pRFs, save maps
    pRFs            = makePRFmaps(params);
end