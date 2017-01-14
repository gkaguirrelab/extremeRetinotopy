function [x,y,dx,dy] = calcScreenVisualAngle(params)

% Calculates the visual angle of stimuli presented on a flat screen
%
%   Usage:
%       [x,y,dx,dy] = calcScreenVisualAngle(params)
%
%   Defaults:
%       params.viewDist     = 27.5; % viewing distance (eye to mirror + mirror to screen)
%       params.screenX      = 51.8; % width of screen (cm)
%       params.screenY      = 29.1; % height of screen (cm)
%       params.screenRes    = [1920 1080]; % screen resolution (pixels)
%       params.fixX         = -19.9799; % x position of the fixation cross
%       params.fixY         = 0; % y position of the fixation cross
%       params.x0           = -19.9799/2; % x position of the eye in screen coordinates
%       params.y0           = 0; % y position of the eye in screen coordinates
%       [params.x,params.y] = meshgrid(...
%           linspace(-params.screenX/2,params.screenX/2,params.screenRes(1)),...
%           linspace(-params.screenY/2,params.screenY/2,params.screenRes(2)));
%
%   Outputs:
%       x                   = x position of pixels (visual angle - radians)
%       y                   = y position of pixels (visual angle - radians)
%       dx                  = x position of pixels (visual angle - degrees)
%       dy                  = y position of pixels (visual angle - degrees)
%
%   Note:
%       Center of screen is [0,0]
%
%   Written by Andrew S Bock Dec 2016

%% set defaults
if ~exist('params','var')
    params              = [];
end
if ~isfield(params,'viewDist');
    params.viewDist     = 27.5; % viewing distance
end
if ~isfield(params,'screenX');
    params.screenX      = 51.8; % width of screen (cm)
end
if ~isfield(params,'screenY');
    params.screenY      = 29.1; % height of screen (cm)
end
if ~isfield(params,'screenRes');
    params.screenRes    = [1920 1080]; % screen resolution (pixels)
end
if ~isfield(params,'fixX');
    params.fixX         = -19.9799; % x position of the fixation cross
end
if ~isfield(params,'fixY');
    params.fixY         = 0; % y position of the fixation cross
end
if ~isfield(params,'x0');
    params.x0           = 0; % x position of the eye in screen coordinates
end
if ~isfield(params,'y0');
    params.y0           = 0; % y position of the eye in screen coordinates
end
if ~isfield(params,'x');
    [params.x,params.y] = meshgrid(...
        linspace(-params.screenX/2,params.screenX/2,params.screenRes),...
        linspace(-params.screenY/2,params.screenY/2,params.screenRes));
end
%% Calculate angles between each pixel and x0, y0
% all pixels
px = atan( (params.x - params.x0) ./ params.viewDist);
py = atan( (params.y - params.y0) ./ params.viewDist);
% fixation point
fx = atan( (params.fixX - params.x0) ./ params.viewDist);
fy = atan( (params.fixY - params.y0) ./ params.viewDist);
%% Calculate the angles between the fixation point and each pixel
x = -(fx - px);
y = -(fy - py);
dx = rad2deg(x);
dy = rad2deg(y);