% File:  peakheight_rdf.m
%
% Kathleen Kirchner, 18.02.2013
%
% Analysing of rdf files

function peakheight_rdf(ncols)

addpath('SED_dir_scripts_SED');

[labels_rdf,x_rdf,values_rdf] = readColData('SED_rdf-file_SED',ncols,0,0);
[labels_cn,x_cn,values_cn] = readColData('SED_cn-file_SED',ncols,0,0);

% Clear the data
extrema=[];

% Calculate the Maxima and Minima and return them 
xx=x_rdf;
yy=values_rdf;

maxpks=findpeaks(xx,yy,0.000005,1.0,10,30,3)
minpks=findvalleys(xx,yy,0.000005,0.01,10,30,3)

[min_difference, maxlocs1] = min(abs(x_rdf - maxpks(1,2)));
[min_difference, maxlocs2] = min(abs(x_rdf - maxpks(2,2)));
maxpks(1,5)=values_cn(maxlocs1);
maxpks(2,5)=values_cn(maxlocs2);

[min_difference, minlocs1] = min(abs(x_rdf - minpks(1,2)));
[min_difference, minlocs2] = min(abs(x_rdf - minpks(2,2)));
minpks(1,5)=values_cn(minlocs1);
minpks(2,5)=values_cn(minlocs2);

maxpks_text=maxpks(1:2,1); maxpks_text(1:2)=1;
minpks_text=minpks(1:2,1); minpks_text(1:2)=2;

extrema(:,1)=vertcat(maxpks(1:2,2),minpks(1:2,2));
extrema(:,2)=vertcat(maxpks(1:2,3),minpks(1:2,3));
extrema(:,3)=vertcat(maxpks(1:2,4),minpks(1:2,4));
extrema(:,4)=vertcat(maxpks(1:2,5),minpks(1:2,5));
extrema(:,5)=vertcat(maxpks_text,minpks_text);
extrema=sortrows(extrema)

dlmwrite('SED_savename_SED', extrema(1:4,:), 'delimiter', ' ', 'precision', 3);

% Simple plot with extremas for fast visual check
f = figure('XVisual','0x27 (TrueColor, depth 24, RGB mask 0xff0000 0xff00 0x00ff)');

set(gcf,'PaperUnits','centimeters')
xSize = 10; ySize = 7.0; %For APS paper the recomended figure width equals the column width of the paper 8.6 cm (or between 10 cm and 2 times 8.6 cm for long figures)
xLeft = (21-xSize)/2; yTop = (30-ySize)/2;
set(gcf,'PaperPosition',[xLeft yTop xSize ySize]);
set(gcf,'Position',[200 200 xSize*50 ySize*50]);

plot(xx,yy,'k-',maxpks(1:2,2),maxpks(1:2,3),'b^',minpks(1:2,2),minpks(1:2,3),'rs','Linewidth',2)

text_VA={'Bottom' 'Top'};
%for K = 1:size(extrema(:,1))
for K = 1:4
	extremalabel=strcat('(',num2str(extrema(K,1),3));
	extremalabel=strcat(extremalabel,',');
	extremalabel=strcat(extremalabel,num2str(extrema(K,2),3));
	extremalabel=strcat(extremalabel,')');
	a=char(text_VA(extrema(K,5)));
	text(extrema(K,1),extrema(K,2),extremalabel,'VerticalAlignment',a,'HorizontalAlignment','Center','FontSize',10);
end

legend('Raw data','Maxima','Minima','Location','EastOutside');

xlabel('r(nm)','FontSize',12);  % add axis labels and plot title
ylabel('g(r)','FontSize',12);

xlim([0 4]);

set(gca,'FontSize',10);

titlename='SED_title_SED';
tmp = strrep(titlename, '_', ' ');
tmp = strrep(tmp, '/', ' ');
tmp = strrep(tmp, '+', ' ');
titlename = tmp
title(titlename,'FontSize',12);

set(gca, ...
  'Box'         , 'off'     , ...
  'TickLength'  , [.01 .01] , ...
  'LineWidth'   , 1         );
%  'XTick'       , 0:1:4, ...
%  'YTick'       , -4:2:10, ...

set(gcf, 'PaperPositionMode', 'manual');

savename='SED_savename_SED';
savename = strrep(savename, '.dat', '');
iResolution = 600;
print('-depsc2', sprintf('-r%d', iResolution),strcat(savename, '+check.eps'));
fixPSlinestyle(strcat(savename, '+check.eps'),strcat(savename, '+check.eps'));

quit;
