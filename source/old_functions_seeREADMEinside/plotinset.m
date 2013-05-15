% PLOTINSET(X, Y, POSITION, WINDOWSIZE, 'xlimit', xlimit, 'ylimit, ylimit) 
% creates a plot of vector Y versus vector X, and on top of it, creates an 
% inset plot of size specified by WINDOWSIZE in the current figure, 
% positioned at the location specified by POSITION.
%
% Bottom left corner is the starting position for placement. Both size and
% position are scaled to accept values in range 0-1, which is the
% fraction size of the current plot. For example, WINDOWSIZE [.3 .3]
% indicates a size of the inset about one-third of the current figure
%
% Use parameter 'xlimit' or 'ylimit' followed by a vector containing limits
% for the x and y axes. Passing appropriate values for 'xlimit' and
% 'ylimit' will cause the inset plot to be shown as a mganification of a
% portion of the larger plot
%
% Example
%   

% Name: plotinset.m
% Desc: Function to plot a figure as an inset on current figure
% Author: Vinaya L Shrestha
% version: 1.0.0

function plotinset(xdata, ydata, position, windowsize, xlimtoken, xlimit, ylimtoken, ylimit)
    
    if nargin < 4 || mod(nargin, 2) == 1
       disp('invalid number of arguments. please follow the function documentation');
       return;
    end

    if nargin == 6
        if ~strcmp(xlimtoken, 'xlimit') && ~strcmp(xlimtoken, 'ylimit')
            disp('Invalid identifiers for axis limit.');
            return;
        end

        if strcmp(xlimtoken, 'xlimit') || strcmp(xlimtoken, 'ylimit')
            if length(xlimit) > 2
                disp('Invalid array for limit.');
                return;
            end
        end
        if xlimit(1) > xlimit(2)
            disp('Limit values must be increasing.');
            return;
        end
    end
    
    if nargin == 8
        if strcmp(xlimtoken, ylimtoken)
            disp('Use unique indentifiers for limits.'); 
            return;
        end
        
        if strcmp(xlimtoken, 'xlimit') || strcmp(xlimtoken, 'ylimit')
            if length(xlimit) > 2
                disp('Invalid array for limit.');
                return;
            end
        end
        
        if strcmp(ylimtoken, 'xlimit') || strcmp(ylimtoken, 'ylimit')
            if length(ylimit) > 2
                disp('Invalid array for limit.');
                return;
            end
        end
        
        if (xlimit(1) > xlimit(2)) || (ylimit(1) > ylimit(2))
            disp('Limit values must be increasing.');
            return;
        end
    end

    figure;
    plot(xdata, ydata);
    hax = axes('position', [position(1), position(2), windowsize(1), windowsize(2)]);
    plot(hax, xdata, ydata);

    if nargin == 6
        if strcmp(xlimtoken, 'xlimit')
            xlim([xlimit(1) xlimit(2)]);
        elseif strcmp(xlimtoken, 'ylimit')
            ylim([xlimit(1) xlimit(2)]);            
        end
    end
    
    if nargin == 8
        if strcmp(xlimtoken, 'xlimit')
            xlim([xlimit(1) xlimit(2)]);
            ylim([ylimit(1) ylimit(2)]);
        elseif strcmp(xlimtoken, 'ylimit')
            xlim([ylimit(1) ylimit(2)]);
            ylim([xlimit(1) xlimit(2)]);
        end
    end
    