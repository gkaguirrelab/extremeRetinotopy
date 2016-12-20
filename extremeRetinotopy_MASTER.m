% MASTER script for processing extreme retinotopy data
%
%   Written by Andrew S Bock Dec 2016

%% Set defaults
dataDir                         = '/data/jag/TOME/extremeRetinotopy/';
logDir                          = '/data/jag/TOME/LOGS';

%% Unzip files
zipDirs                         = listdir(fullfile(dataDir,'*.zip'),'files');
cd(dataDir);
for i = 1:length(zipDirs)
    system(['unzip ' fullfile(dataDir,zipDirs{i})]);
    system(['rm -rf ' fullfile(dataDir,zipDirs{i})]);
end
%% Clean up dicoms, put into more 'standard' format
sessionDirs                     = listdir(dataDir,'dirs');
for i = 1:length(sessionDirs)
    dcmParams.inDir             = fullfile(dataDir,sessionDirs{i});
    dcmParams.outDir            = fullfile(dataDir,sessionDirs{i},'DICOMS');
    extremeRetinotopyDicoms(dcmParams);
end
%% Create preprocessing scripts
sessionDirs                     = listdir(dataDir,'dirs');
for i = 1:length(sessionDirs)
    preParams.sessionDir        = fullfile(dataDir,sessionDirs{i});
    preParams.subjectName       = sessionDirs{i};
    preParams.dicomDir          = fullfile(preParams.sessionDir,'DICOMS');
    preParams.useMRIcron        = 1;
    preParams.isGE              = 1;
    preParams.outDir            = fullfile(preParams.sessionDir,'preprocessing_scripts');
    preParams.logDir            = logDir;
    preParams.jobName           = preParams.subjectName;
    preParams.numRuns           = 4; % number of bold runs
    preParams.reconall          = 1;
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
end

%%% Run the preprocessing scripts %%%

%% Concatenate the retinotopy runs
sessionDirs             = listdir(dataDir,'dirs');
for i = 1:length(sessionDirs)
    sessionDir          = fullfile(dataDir,sessionDirs{i});
    b                   = find_bold(sessionDir);
    % left hemisphere
    lhRing              = load_nifti(fullfile(sessionDir,b{1},'wdrf.tf.surf.lh.nii.gz'));
    lhWedge             = load_nifti(fullfile(sessionDir,b{2},'wdrf.tf.surf.lh.nii.gz'));
    out                 = lhRing;
    out.dim(5)          = out.dim(5)*2;
    tmp1                = convert_to_psc(squeeze(lhRing.vol));
    tmp2                = convert_to_psc(squeeze(lhWedge.vol));
    out.vol             = [tmp1,tmp2];
    save_nifti(out,fullfile(sessionDir,'pRFs','lh.surf.tcs.nii.gz'));
    % right hemisphere
    rhRing              = load_nifti(fullfile(sessionDir,b{3},'wdrf.tf.surf.rh.nii.gz'));
    rhWedge             = load_nifti(fullfile(sessionDir,b{4},'wdrf.tf.surf.rh.nii.gz'));
    out                 = rhRing;
    out.dim(5)          = out.dim(5)*2;
    tmp1                = convert_to_psc(squeeze(rhRing.vol));
    tmp2                = convert_to_psc(squeeze(rhWedge.vol));
    out.vol             = [tmp1,tmp2];
    save_nifti(out,fullfile(sessionDir,'pRFs','rh.surf.tcs.nii.gz'));
end
%% Make retinotopy stimuli

clear params;

params.horRad       = 73.5;
params.circRad      = 72;
[~,wedges] = makeRingsWedges(params);
params.circRad      = 73.5;
[rings] = makeRingsWedges(params);
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
% Save stimuli in .mat file
sessionDirs             = listdir(dataDir,'dirs');
for i = 1:length(sessionDirs)
    sessionDir          = fullfile(dataDir,sessionDirs{i});
    outDir              = fullfile(sessionDir,'Stimuli');
    if ~exist(outDir,'dir')
        mkdir(outDir);
    end
    params.stimParams.imagesFull = cat(3,ringsLeft,wedgesLeft);
    save(fullfile(outDir,'rh.ringWedge.mat'),'params');
    params.stimParams.imagesFull = cat(3,ringsRight,wedgesRight);
    save(fullfile(outDir,'lh.ringWedge.mat'),'params');
end
%% Make pRF maps
hemis                   = {'lh' 'rh'};
sessionDirs             = listdir(dataDir,'dirs');
for i = 1:length(sessionDirs)
    sessionDir          = fullfile(dataDir,sessionDirs{i});
    b                   = find_bold(sessionDir);
    params.fieldSize    = 73.5;
    params.padFactor    = 0.25;
    params.framesPerTR  = 1;
    params.gridPoints   = 101;
    params.sigList      = 1:0.5:10;
    params.TR           = 3;
    for hh = 1:2
        params.stimFile = fullfile(outDir,[hemis{hh} '.ringWedge.mat']);
        params.inVol    = fullfile(sessionDir,'pRFs',[hemis{hh} '.surf.tcs.nii.gz']);
        params.outDir   = fullfile(sessionDir,'pRFs');
        params.baseName = hemis{hh};
        % Calculate pRFs, save maps
        pRFs            = makePRFmaps(params);
    end
end