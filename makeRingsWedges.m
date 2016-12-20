function [rings, wedges] = makeRingsWedges(params)

% Makes ring and wedge stimuli
%
%   Usage:
%       [rings, wedges] = makeRingsWedges(params)
%
%   Defaults:
%       params.resolution   = [1920 1080]; % screen resolution
%       params.horRad       = 72; % horizontal visual field radius (degrees)
%       params.verRad       = 20; % vertical visual field radius (degrees)
%       params.circRad      = 72; % radius of circular visual field (degrees)
%       params.numSteps     = 12; % number of ring/wedge steps / cycle
%       params.ringSize     = 18; % ring width (degrees)
%       params.ringStep     = 6; % ring step size (degrees)
%       params.wedgeSize    = 30; % wedge width (degrees)
%       params.wedgeStep    = 15; % wedge step size (degrees)
%       params.halfField    = 1; % 1 - half visual field, 0 - full field
%
%   Written by Andrew S Bock Dec 2016

%% Set Defaults
if ~exist('params','var')
    params              = [];
end
if ~isfield(params,'resolution')
    params.resolution   = [1920 1080];
end
if ~isfield(params,'horRad')
    params.horRad       = 72;
end
if ~isfield(params,'verRad')
    params.verRad       = 20;
end
if ~isfield(params,'circRad')
    params.circRad      = 72;
end
if ~isfield(params,'numSteps')
    params.numSteps     = 12;
end
if ~isfield(params,'ringSize')
    params.ringSize     = 18;
end
if ~isfield(params,'ringStep')
    params.ringStep     = 6;
end
if ~isfield(params,'wedgeSize')
    params.wedgeSize    = 30;
end
if ~isfield(params,'wedgeStep')
    params.wedgeStep    = 15.5;
end
if ~isfield(params,'halfField')
    params.halfField    = 1;
end
%% Set variables
minDim                  = min(params.resolution);
blankIms                = 128*ones(minDim,minDim,params.numSteps);
rings                   = blankIms;
ringSize                = nan(params.numSteps,4);
wedges                  = blankIms;
wedgeSize               = nan(params.numSteps,4);
%% Make blank images, calculate radius
[x,y]                   = meshgrid(...
    linspace(-minDim/2,minDim/2,minDim),...
    linspace(-minDim/2,minDim/2,minDim));
r                       = sqrt (x.^2  + y.^2);
p                       = cart2pol(x,y);
p                       = p - pi/2;
p                       = wrapToPi(p);
%% Make rings
ringSize(1,:)           = [0,params.ringSize,0,0];
for i = 2:params.numSteps
    tmp                 = rem([ringSize(i-1,1:2) + params.ringStep,0,0],params.horRad);
    if tmp(2) > tmp(1)
        % non-split rings
        ringSize(i,:)   = tmp;
    else
        % split rings
        ringSize(i,1)   = tmp(1);
        ringSize(i,2)   = params.horRad;
        ringSize(i,3)   = 0;
        ringSize(i,4)   = tmp(2) + ringSize(i-1,4);
    end
end
% Convert to pixel units
ringSize = ((ringSize / params.horRad)  * minDim) / 2; % divide by 2 for radius
for i = 1:params.numSteps
    thesePix            = ...
        ((r > ringSize(i,1) & r < ringSize(i,2)) | ...
        (r > ringSize(i,3) & r < ringSize(i,4))) & ...
        r < ((params.circRad / params.horRad)  * minDim) / 2; % divide by 2 for radius;
    tmp = squeeze(rings(:,:,i));
    tmp(thesePix)       = 255;
    rings(:,:,i)        = tmp;
end
% Crop hemifield (if true)
if params.halfField
    % trim hemifield
    rings(:,size(rings,2)/2 + 1:end,:) = 128;
    % trim upper/lower portions
    trimSize            = round((params.verRad/params.horRad)*size(rings,1)/2);
    top                 = 1:trimSize;
    bot                 = (size(rings,1) - trimSize) + 1:size(rings,1);
    rings([top,bot],:,:) = 128;
end
%% Make wedges
wedgeSize(1,:)          = [0,params.wedgeSize,0,0];
for i = 2:params.numSteps
    tmp                 = rem([wedgeSize(i-1,1:2) + params.wedgeStep,0,0],180);
    if tmp(2) > tmp(1)
        % non-split rings
        wedgeSize(i,:)  = tmp;
    else
        % split rings
        wedgeSize(i,1)  = tmp(1);
        wedgeSize(i,2)  = 180;
        wedgeSize(i,3)  = 0;
        wedgeSize(i,4)  = tmp(2) + wedgeSize(i-1,4);
    end
end
wedgeSize = deg2rad(wedgeSize);
for i = 1:params.numSteps
    thesePix            = ...
        ((p > wedgeSize(i,1) & p < wedgeSize(i,2)) | ...
        (p > wedgeSize(i,3) & p < wedgeSize(i,4))) & ...
        r < ((params.circRad / params.horRad)  * minDim) / 2; % divide by 2 for radius;
    tmp = squeeze(wedges(:,:,i));
    tmp(thesePix)       = 255;
    wedges(:,:,i)       = tmp;
end

% Crop hemifield (if true)
if params.halfField
    % trim hemifield
    wedges(:,size(wedges,2)/2 + 1:end,:) = 128;
    % trim upper/lower portions
    trimSize            = round((params.verRad/params.horRad)*size(wedges,1)/2);
    top                 = 1:trimSize;
    bot                 = (size(wedges,1) - trimSize) + 1:size(wedges,1);
    wedges([top,bot],:,:) = 128;
end