function [rings, wedges] = makeRingsWedges(params)

% Make ring and wedge stimuli
%
%   Usage:
%       [rings, wedges] = makeRingsWedges(params)
%
%   Written by Andrew S Bock Dec 2016

%% Set Defaults
if ~exist('params','var')
    params              = [];
end
if ~isfield(params,'resolution')
    params.resolution   = [1920 1080];
end
if ~isfield(params,'outerRad')
    params.outerRad     = 72;
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
    params.wedgeStep    = 15;
end
if ~isfield(params,'halfField')
    params.halfField    = 1;
end
%% Set variables
if params.halfField
    params.outerRad     = params.outerRad*2;
    params.resolution   = params.resolution*2;
    params.ringStep     = params.ringStep*2;
    params.ringSize     = params.ringSize*2;
end
squareDim               = min(params.resolution);
blankIms                = zeros(squareDim,squareDim,params.numSteps);
rings                   = blankIms;
ringSize                = nan(params.numSteps,4);
wedges                  = blankIms;
wedgeSize               = nan(params.numSteps,4);
%% Make blank images, calculate radius
[x,y]                   = meshgrid(...
    linspace(-squareDim/2,squareDim/2,squareDim),...
    linspace(-squareDim/2,squareDim/2,squareDim));
r                       = sqrt (x.^2  + y.^2);
p                       = cart2pol(x,y);
p                       = p - pi/2;
p                       = wrapToPi(p);
%% Make rings
ringSize(1,:)           = [0,params.ringSize,0,0];
for i = 2:params.numSteps
    tmp                 = rem([ringSize(i-1,1:2) + params.ringStep,0,0],params.outerRad);
    if tmp(2) > tmp(1)
        % non-split rings
        ringSize(i,:)   = tmp;
    else
        % split rings
        ringSize(i,1)   = tmp(1);
        ringSize(i,2)   = params.outerRad;
        ringSize(i,3)   = 0;
        ringSize(i,4)   = tmp(2) + ringSize(i-1,4);
    end
end
% Convert to pixel units
ringSize = ((ringSize / params.outerRad)  * squareDim) / 2; % divide by 2 for radius
for i = 1:params.numSteps
    thesePix            = ...
        (r > ringSize(i,1) & r < ringSize(i,2)) | ...
        (r > ringSize(i,3) & r < ringSize(i,4));
    tmp = squeeze(rings(:,:,i));
    tmp(thesePix)       = 1;
    rings(:,:,i)        = tmp;
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
        (p > wedgeSize(i,1) & p < wedgeSize(i,2)) | ...
        (p > wedgeSize(i,3) & p < wedgeSize(i,4));
    tmp = squeeze(wedges(:,:,i));
    tmp(thesePix)       = 1;
    wedges(:,:,i)       = tmp;
end
%% Crop out field if 'halfField'
if params.halfField
    width               = 1:size(rings,2)/2;
    tmp                 = (1:size(rings,1)*0.5);
    height              = tmp + (size(rings,1)/2 - length(tmp)/2);
    rings               = rings(height,width,:);
    wedges              = wedges(height,width,:);
end