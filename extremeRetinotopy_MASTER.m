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

%% RUN QA after preprocessing
% YORK_analysis will be the output folder

%% Concatenate the retinotopy runs
sessionDirs             = listdir(dataDir,'dirs');
for i = 1%:length(sessionDirs)
    sessionDir          = fullfile(dataDir,sessionDirs{i});
    outDir              = fullfile(sessionDir,'pRFs');
    if ~exist(outDir,'dir')
        mkdir(outDir);
    end
    lhRingDir           = listdir(fullfile(sessionDir,'*rng_lt'),'dirs');
    if isempty(lhRingDir)
        lhRingDir       = listdir(fullfile(sessionDir,'*rng_left'),'dirs');
    end
    lhWedgeDir          = listdir(fullfile(sessionDir,'*wed_lt'),'dirs');
    if isempty(lhWedgeDir)
        lhWedgeDir      = listdir(fullfile(sessionDir,'*wed_left'),'dirs');
    end
    rhRingDir           = listdir(fullfile(sessionDir,'*rng_rt'),'dirs');
    if isempty(rhRingDir)
        rhRingDir       = listdir(fullfile(sessionDir,'*rng_right'),'dirs');
    end
    rhWedgeDir          = listdir(fullfile(sessionDir,'*wed_rt'),'dirs');
    if isempty(rhWedgeDir)
        rhWedgeDir      = listdir(fullfile(sessionDir,'*wed_right'),'dirs');
    end
    % left hemisphere
    lhRing              = load_nifti(fullfile(sessionDir,rhRingDir{1},'wdrf.tf.surf.lh.nii.gz'));
    lhWedge             = load_nifti(fullfile(sessionDir,rhWedgeDir{1},'wdrf.tf.surf.lh.nii.gz'));
    out                 = lhRing;
    out.dim(5)          = out.dim(5)*2;
    tmp1                = convert_to_psc(squeeze(lhRing.vol));
    tmp2                = convert_to_psc(squeeze(lhWedge.vol));
    out.vol             = [tmp1,tmp2];
    save_nifti(out,fullfile(outDir,'lh.surf.tcs.nii.gz'));
    % right hemisphere
    rhRing              = load_nifti(fullfile(sessionDir,lhRingDir{1},'wdrf.tf.surf.rh.nii.gz'));
    rhWedge             = load_nifti(fullfile(sessionDir,lhWedgeDir{1},'wdrf.tf.surf.rh.nii.gz'));
    out                 = rhRing;
    out.dim(5)          = out.dim(5)*2;
    tmp1                = convert_to_psc(squeeze(rhRing.vol));
    tmp2                = convert_to_psc(squeeze(rhWedge.vol));
    out.vol             = [tmp1,tmp2];
    save_nifti(out,fullfile(outDir,'rh.surf.tcs.nii.gz'));
end
%% Make retinotopy stimuli

clear params;

% note, for the .mat file saved below, the structure must be named 'params'
% for later code (i.e. the 'makePRFmaps' function) to work

params.horRad           = 73.5;
params.circRad          = 72;
[~,wedges] = makeRingsWedges(params);
params.circRad          = 73.5;
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
for i = 1%:length(sessionDirs)
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
hemis                       = {'lh' 'rh'};
sessionDirs                 = listdir(dataDir,'dirs');
for i = 1%:length(sessionDirs)
    sessionDir              = fullfile(dataDir,sessionDirs{i});
    pRFparams.fieldSize     = 73.5;
    pRFparams.padFactor     = 0.25;
    pRFparams.framesPerTR   = 1;
    pRFparams.gridPoints    = 101;
    pRFparams.sigList       = 1:0.5:10;
    pRFparams.TR            = 3;
    for hh = 1:2
        pRFparams.stimFile  = fullfile(outDir,[hemis{hh} '.ringWedge.mat']);
        pRFparams.inVol     = fullfile(sessionDir,'pRFs',[hemis{hh} '.surf.tcs.nii.gz']);
        pRFparams.outDir    = fullfile(sessionDir,'pRFs');
        pRFparams.baseName  = hemis{hh};
        % Calculate pRFs, save maps
        pRFs                = makePRFmaps(pRFparams);
    end
end


%% Below is not ready


%%% Andrew will update %%%



%% Project pRF to fsaverage_sym space (all project to left hemisphere)
srcROI = 'cortex';
for ss = 1:length(sessions)
    session_dir = sessions{ss};
    subject_name = subjects{ss};
    boldDirs = find_bold(session_dir);
    for rr = 1:length(pRFfuncs)
        rootName = pRFfuncs{rr};
        for hh = 1:length(hemis)
            hemi = hemis{hh};
            for mm = 1:length(pRFmaps)
                pRFmap = pRFmaps{mm};
                sval = fullfile(session_dir,'pRFs',...
                    [hemi '.' rootName '.' srcROI '.' pRFmap '.avg.prfs.nii.gz']);
                tval = fullfile(session_dir,'pRFs',...
                    [hemi '.' rootName '.' srcROI '.' pRFmap '.avg.prfs.sym.nii.gz']);
                if strcmp(hemi,'lh')
                    mri_surf2surf(subject_name,'fsaverage_sym',sval,tval,hemi);
                else
                    mri_surf2surf([subject_name '/xhemi'],'fsaverage_sym',sval,tval,'lh');
                end
            end
        end
    end
    progBar(ss);
end
% Average maps after pRF scripts have finished
params.inDir            = fullfile(params.sessionDir,'pRFs');
params.outDir           = fullfile(params.sessionDir,'pRFs');
for i = 1:length(hemis)
    params.baseName     = hemis{i};
    avgPRFmaps(params)
end
%% Prepare pRF template for fitting in Mathematica
for ff = 1:length(pRFfuncs);
    for ss = 1:length(sessions)
        session_dir = sessions{ss};
        subject_name = subjects{ss};
        outName = outNames{ss};
        prepare_pRF_Mathematica(session_dir,subject_name,outName,pRFfuncs{ff});
    end
end