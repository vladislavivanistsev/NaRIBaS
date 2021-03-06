% File:  basic_plotting.m
%
% Kathleen Kirchner, 21.08.2012
%
% Basic plotting

function basic_plotting(ncols,colornum)

addpath('SED_dir_scripts_SED');

[labels,x,y] = readColData('SED_plotfile_SED',ncols);

f = figure('XVisual',...
    '0x27 (TrueColor, depth 24, RGB mask 0xff0000 0xff00 0x00ff)');

set(gcf,'PaperUnits','centimeters')
%This sets the units of the current figure (gcf = get current figure) on paper to centimeters.
xSize = 8.6; ySize = 8.6; %For APS paper the recomended figure width equals the column width of the paper 8.6 cm (or between 10 cm and 2 times 8.6 cm for long figures)
%These are my size variables, width of 8 and a height of 12, will be used a lot later.
xLeft = (21-xSize)/2; yTop = (30-ySize)/2;
%Additional coordinates to center the figure on A4-paper
set(gcf,'PaperPosition',[xLeft yTop xSize ySize]);
%This command sets the position and size of the figure on the paper to the desired values.
set(gcf,'Position',[200 200 xSize*50 ySize*50]);

if (ncols<=2*2) % if there are just one or two lines, draw red and blue
ColorSet(1,:)=[255 0 0]/255;
ColorSet(2,:)=[0 0 255]/255;
elseif (ncols<=2*10)
ColorSet = varycolor(ncols/2); %setup the color scheme to use. Matlab has only 8 colors predefined, this might be not enough, thus use varycolor.m
ColorSet(1,:)=[0 220 30]/255; % light green to bluish green 
ColorSet(2,:)=[86 180 233]/255; % cyan to light blue
end

set(gca, 'ColorOrder', ColorSet);

LineStyleSet = {'-','-.',':'};

xlim([0 11]);
ylim([0 11]);

hold all;

legend_str=[];

if (ncols <= 3)

	if (colornum ==1)
	h=plot(x,y(:,1),'o','MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'MarkerSize', 10); %,'Linewidth',1
	elseif (colornum ==2)
	h=plot(x,y(:,1),'o','MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k', 'MarkerSize', 5); %,'Linewidth',1
	else
	h=plot3 (  x,  y(:,1), y(:,2), 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k', 'MarkerSize', 10 )
	end

else
for m = 1:2:ncols
  set(gca,'LineStyleOrder',LineStyleSet{1, mod(m-1,3)+1});
  if (m==1)
    h=plot(x,y(:,m),'Linewidth',1);
  else
    h=plot(y(:,m-1),y(:,m),'Linewidth',1);
  end
  legend_str=strvcat(legend_str, labels(m+1,:));
end
end

if (ncols<=3)
Note='No legend, only one column to plot.'
elseif (ncols<=2*8) 
legend(legend_str(:,:),'Location','NorthEast');
elseif (ncols<=2*14) 
legend(legend_str(:,:),'Location','EastOutside');
else
legend(legend_str(1:14,:),'Location','NorthEastOutside');
ylimit=get(gca,'YLim');
xlimit=get(gca,'XLim');
text(xlimit(2),ylimit(2),'Legend to long','VerticalAlignment','bottom','HorizontalAlignment','left');
%LineHandles = findobj('Type','Line');
end

if (ncols<=3)
xlabel(labels(1,:),'FontSize',12);  % add axis labels and plot title
ylabel(labels(2,:),'FontSize',12);
else
xlabel(labels(3,:),'FontSize',12);  % add axis labels and plot title
ylabel(labels(1,:),'FontSize',12);
end


set(gca,'FontSize',10);

titlename='SED_title_SED';
tmp = strrep(titlename, '_', ' ');
tmp = strrep(tmp, '/', ' ');
tmp = strrep(tmp, '+', ' ');
tmp = strrep(tmp, 'rdf', 'RDF of');
tmp = strrep(tmp, 'cn', 'CN of');
tmp = strrep(tmp, 'numberdens', '\rho_N');
titlename = tmp
title(titlename,'FontSize',10);

set(gca, ...
  'Box'         , 'on'     , ...
  'TickLength'  , [.01 .01] , ...
  'LineWidth'   , 1         );
%  'XTick'       , 0:1:4, ...
%  'YTick'       , -4:2:10, ...

set(gcf, 'PaperPositionMode', 'manual');

savename='SED_savename_SED';
savename = strrep(savename, '.dat', '');
iResolution = 600;
print('-depsc2', sprintf('-r%d', iResolution), strcat(savename, '.eps'));
fixPSlinestyle(strcat(savename, '.eps'),strcat(savename, '.eps'));

quit;
