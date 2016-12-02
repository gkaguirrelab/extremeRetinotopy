function extremeRetinotopyDicoms(params)

% Take the dicoms from the Bassler extremeRetinotopy project and put them
% in a more 'standard' format
%
%   Usage:
%       extremeRetinotopyDicoms(params)
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
        movefile(fullfile(params.inDir,inD{i},inF{j}),...
            fullfile(params.outDir,sprintf('001_%06d_%06d.dcm',i,j)));
    end
end