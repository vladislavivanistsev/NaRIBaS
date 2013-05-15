% File:  basic_plotting_alloptions.m
%
% Kathleen Kirchner, 18.02.2013
%
% Basic plotting with several options

function basic_plotting_alloptions(ncols,setdifference,setxlim,setylim,setcolorstyle,setlegendloc,setxsize,setysize,setverticallines,sethorizontallines,setspecificplot)

%  Input:
%     ncols  = number of columns in the data file
%     setdifference = Boolean to define, if the plot functions should be substracted. Default = 0 - no substraction.
%     setxlim = Boolean to adjust x axis limits. Default = 0 - auto size.
%     setylim = Boolean to adjust y axis limits. Default = 0 - auto size.
%     setcolorstyle = Boolean to adjust color style. Default = 0 - colors defined by varycolor.m.
%     setlegendloc = Boolean to adjust legend location. Default = 0 - EastOutside with title.
%     setxsize = Boolean to adjust figure width. Default = 0 - 10 cm.
%     setysize = Boolean to adjust figure height. Default = 0 - 7 cm.
%     setverticallines = Boolean to define, if vertical lines should be drawn. Default = 0 - no lines.
%     sethorizontallines = Boolean to define, if horizontal lines should be drawn. Default = 0 - no lines.
%     setspecificplot = Boolean to define a specific plotting style like dots instead of lines. Default = 0 - standard.

%Process optional arguments
if nargin < 11
setspecificplot = 0;      % default
if nargin < 10
sethorizontallines = 0;      % default
if nargin < 9
setverticallines = 0;      % default
if nargin < 8
setysize = 0;      % default
if nargin < 7
setxsize = 0;     % default
if nargin < 6
setlegendloc = 0;   % default
if nargin < 5
setcolorstyle = 0;   % default
if nargin < 4
setylim = 0;   % default
if nargin < 3
setxlim = 0;   % default
if nargin < 2
setdifference = 0;   % default
end
end
end
end
end
end
end
end
end
end


% Add scripts in library to the Matlab path
addpath('SED_dir_scripts_SED');

% Load data using the function readColData.m
[labels,x,y] = readColData('SED_plotfile_SED',ncols);

%Create a figure
f = figure('XVisual','0x27 (TrueColor, depth 24, RGB mask 0xff0000 0xff00 0x00ff)');

set(gcf,'PaperUnits','centimeters');

%This sets the units of the current figure (gcf = get current figure) on paper to centimeters. For APS paper the recomended figure width equals the column width of the paper 8.6 cm (or between 10 cm and 2 times 8.6 cm for long figures)

if (setxsize == 1)
xSize=SED_xsize_SED;
else
xSize = 10;
end

if (setysize == 1)
xSize=SED_ysize_SED;
else
ySize = 7.0; 
end

%These are size variables.
xLeft = (21-xSize)/2; yTop = (30-ySize)/2;
%Additional coordinates to center the figure on A4-paper
set(gcf,'PaperPosition',[xLeft yTop xSize ySize]);

%This command sets the position and size of the figure on the paper to the desired values.
set(gcf,'Position',[200 200 xSize*50 ySize*50]);


%Define color sets to use. Matlab has only 8 colors predefined, this might be not enough, thus use varycolor.m
ColorSet = varycolor(ncols/2); 

if (ncols<=2*2) % if there are just one or two lines, draw red and blue
ColorSet(1,:)=[255 0 0]/255;
ColorSet(2,:)=[0 0 255]/255;
elseif (ncols<=2*10)
ColorSet(1,:)=[0 220 30]/255; % light green to bluish green 
ColorSet(2,:)=[86 180 233]/255; % cyan to light blue
end

if (setcolorstyle == 6) % temperature appearance: cold to hot = blue to red
ColorSet(1,:)=[86 180 233]/255;
ColorSet(2,:)=[0 114 178]/255;
ColorSet(3,:)=[20 0 220]/255;
ColorSet(4,:)=[89 17 150]/255;
ColorSet(5,:)=[178 10 10]/255;
ColorSet(6,:)=[213 94 0]/255;
end

set(gca, 'ColorOrder', ColorSet);

%Define line style
LineStyleSet = {'-','-.',':'}; numLineStyles=3;

%Define axis limits
if (setxlim == 1)
xlim([SED_xlim_SED]);
else
xlim([x(1) x(end)]);
end

if (setylim == 1)
ylim([SED_ylim_SED]);
end

%Prepare the substraction if required, otherwise substract zero.
ysubstract=zeros(size(y(:,1)));
if (setdifference == 1) % substract the first column
ysubstract=y(:,1);
elseif (setdifference == 2) % substract the last column
ysubstract=y(:,end);
end


%Draw the lines and create the legend entries
hold all;

legend_str=[];

if (setspecificplot == 0)
	for m = 1:2:ncols
	  set(gca,'LineStyleOrder',LineStyleSet{1, mod((m-1)/2,numLineStyles)+1});
	  if (m==1)
		h((m+1)/2)=plot(x,y(:,m)-ysubstract,'Linewidth',1);
	  else
		h((m+1)/2)=plot(y(:,m-1),y(:,m)-ysubstract,'Linewidth',1);
	  end
	  legend_str=strvcat(legend_str, labels(m+1,:));
	end
elseif (setspecificplot == 1)
	h=plot(x,y(:,1),'ro','Linewidth',1);
	setlegendloc = 1
end

% Draw legend
if (setlegendloc == 0) %EastOutside with title
	lh=legend(legend_str(:,:),'Location','EastOutside');
	v = get(lh,'title');
	set(v,'string','SED_legend_name_SED');

elseif (setlegendloc == 1) %no legend
	Note='No legend.'

elseif (setlegendloc == 2) %NorthEast without title
	legend(legend_str(:,:),'Location','NorthEast');
elseif (setlegendloc == 3) %NorthWest without title
	legend(legend_str(:,:),'Location','NorthWest');
elseif (setlegendloc == 4) %SouthEast without title
	legend(legend_str(:,:),'Location','SouthEast');
elseif (setlegendloc == 5) %SouthWest without title
	legend(legend_str(:,:),'Location','SouthWest');

elseif (setlegendloc == 6) %NorthEastOutside with title 'Legend to long'
	legend(legend_str(1:14,:),'Location','NorthEastOutside');
	ylimit=get(gca,'YLim');
	xlimit=get(gca,'XLim');
	text(xlimit(2),ylimit(2),'Legend to long','VerticalAlignment','bottom','HorizontalAlignment','left');

elseif (setlegendloc == 7) %EastOutside with title, entries inverted
	legend_str(1,:)=[];
	legend_str=strvcat('PZC',legend_str);

	for i=1:ncols/2
	order(i)=ncols/2-i+1;
	end

%	order=[8 7 6 5 4 3 2 1]
	lh=legend(h(order),legend_str(order,:),'Location','EastOutside');
	v = get(lh,'title');
	set(v,'string','SED_legend_name_SED');
end

if (setverticallines == 1)
verticallines=[SED_verticallines_SED];
ylimit=get(gca,'ylim');
line([verticallines;verticallines],ylimit,'linewidth',1,'color','k','linestyle','-.');
end

if (sethorizontallines == 1)
horizontallines=[SED_horizontallines_SED];
xlimit=get(gca,'xlim');
line(xlimit,[horizontallines;horizontallines],'linewidth',1,'color','k','linestyle',':');
end

%Add axis labels and title
if (ncols==2)
xlabel(labels(2,:),'FontSize',12);  
else
xlabel(labels(3,:),'FontSize',12);
end
ylabel(labels(1,:),'FontSize',12);

set(gca,'FontSize',10);

titlename='SED_title_SED';
tmp = strrep(titlename, '_', '_'); %WARNING: Backwarts compatible: '_' to ' '
tmp = strrep(tmp, '/', ' ');
tmp = strrep(tmp, '+', ' ');
titlename = tmp
title(titlename,'FontSize',12);

%Some specific settings
set(gca, ...
  'Box'         , 'off'     , ...
  'TickLength'  , [.01 .01] , ...
  'LineWidth'   , 1         );
%  'XTick'       , 0:1:4, ...
%  'YTick'       , -4:2:10, ...

% Finally "print" the figure with high resolution (600 dpi, adjust if necessary)
set(gcf, 'PaperPositionMode', 'manual');

savename='SED_savename_SED';
savename = strrep(savename, '.dat', '');
iResolution = 600;
print('-depsc2', sprintf('-r%d', iResolution), strcat(savename, '.eps'));

%The function fixPSlinestyle.m converts uggly looking lines and dots in something nice
fixPSlinestyle(strcat(savename, '.eps'),strcat(savename, '.eps'));

quit;
