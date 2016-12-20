function extremeRetinotopyDicoms(params)

% Take the dicoms from the Bassler extremeRetinotopy project and put them
% in a more 'standard' format
%
%   Required:
%       params.inDir        = '/path/to/original/dicomDir'
%       params.outDir       = '/path/to/output/dicomDir'
%
%   Written by Andrew S Bock Dec 2016

%% Handle the directories
inD = listdir(params.inDir,'dirs');
if ~exist(params.outDir,'dir')
    mkdir(params.outDir);
end
%% Update the dicom names
for i = 1:length(inD)
    inF = listdir(fullfile(params.inDir,inD{i}),'files');
    for j = 1:length(inF)
        system(['mv ' fullfile(params.inDir,inD{i},inF{j}) ' ' ...
            fullfile(params.outDir,sprintf('001_%06d_%06d.dcm',i,j))]);
    end
    system(['rm -rf ' fullfile(params.inDir,inD{i})]);
end
%% Sort the dicoms
dicom_sort(params.outDir);

%% Remove spaces from the output dicom directory names
d = listdir(params.outDir,'dirs');
for i = 1:length(d)
    outDir = strrep(d{i},' ','');
    if ~strcmp(d{i},outDir)
        movefile(fullfile(params.outDir,d{i}),fullfile(params.outDir,outDir));
    end
end
%% Adjust the directory names
d = listdir(params.outDir,'dirs');
for i = 1:length(d)
    outDir = strrep(d{i},'Exp_rng','bold_Exp_rng');
    if ~strcmp(d{i},outDir)
        movefile(fullfile(params.outDir,d{i}),fullfile(params.outDir,outDir));
    end
    outDir = strrep(d{i},'Rot_wed','bold_Rot_wed');
    if ~strcmp(d{i},outDir)
        movefile(fullfile(params.outDir,d{i}),fullfile(params.outDir,outDir));
    end
    outDir = strrep(d{i},'T1','T1w');
    if ~strcmp(d{i},outDir)
        movefile(fullfile(params.outDir,d{i}),fullfile(params.outDir,outDir));
    end
end