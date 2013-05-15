% File:  basic_plotting.m
%
% Kathleen Kirchner, 21.08.2012
%
% Basic plotting

function basic_plotting(ncols,electrodeatoms,xbox_nm,ybox_nm)

addpath('SED_dir_scripts_SED');

[labels,x,y] = readColData('SED_plotfile_SED',ncols);

nm2m=10^-9;
cm2m=10^-2;
mu2one=10^-6;
e2C=1.602 * 10^-19;
C2e=1/e2C;

for m = 1:2:ncols
	sigma((m+1)/2)=str2num(labels(m+1,:));
	electronnumber=abs(sigma((m+1)/2)) * xbox_nm * ybox_nm * mu2one * C2e * nm2m^2/cm2m^2 
	y(:,m)=y(:,m)./electronnumber;
end

f = figure('XVisual',...
    '0x27 (TrueColor, depth 24, RGB mask 0xff0000 0xff00 0x00ff)');

set(gcf,'PaperUnits','centimeters')
%This sets the units of the current figure (gcf = get current figure) on paper to centimeters.
xSize = 8.6; ySize = 7.0; %For APS paper the recomended figure width equals the column width of the paper 8.6 cm (or 2 times 8.6 cm for long figures)
%These are my size variables, width of 8 and a height of 12, will be used a lot later.
xLeft = (21-xSize)/2; yTop = (30-ySize)/2;
%Additional coordinates to center the figure on A4-paper
set(gcf,'PaperPosition',[xLeft yTop xSize ySize]);
%This command sets the position and size of the figure on the paper to the desired values.
set(gcf,'Position',[200 200 xSize*50 ySize*50]);

ColorSet = varycolor(ncols/2);

if (ncols<=2*2) % if there are just one or two lines, draw red and blue
%ColorSet(1,:)=[255 0 0]/255;
%ColorSet(2,:)=[0 0 255]/255;
% Red and vermillion for temperatures 450 and 500 K used only for publication
ColorSet(1,:)=[178 10 10]/255;
ColorSet(2,:)=[213 94 0]/255;
elseif (ncols==2*6) % temperature appearance: cold to hot = blue to red
ColorSet(1,:)=[86 180 233]/255;
ColorSet(2,:)=[0 114 178]/255;
ColorSet(3,:)=[20 0 220]/255;
ColorSet(4,:)=[89 17 150]/255;
ColorSet(5,:)=[178 10 10]/255;
ColorSet(6,:)=[213 94 0]/255;
elseif (ncols<=2*10)
ColorSet(1,:)=[0 220 30]/255; % light green to bluish green 
ColorSet(2,:)=[86 180 233]/255; % cyan to light blue
end

ColorSet(4,:)=[0 0 0]/255;
set(gca, 'ColorOrder', ColorSet);

%LineStyleSet = {'-','-.',':'};
%LineStyleSet = {'-.',':','-'};
%LineStyleSet = {'-.','-'};
LineStyleSet = {'-','-.',':','-','-.',':','-.','-'};
%LineStyleSet = {'-','-',':','-','-.',':','-.','-'};

hold all;

%xlim([x(1) x(end)]);
xlim([SED_xlim_SED]);
%ylim([0 2]);

legend_str=[];

for m = 1:2:ncols
%  set(gca,'LineStyleOrder',LineStyleSet{1, mod((m-1)/2,8)+1});
  set(gca,'LineStyleOrder',LineStyleSet{1, mod((m-1)/2,3)+1});
  if (m==1)
    h=plot(x,y(:,m),'Linewidth',1);
  elseif (m==7)
    h=plot(y(:,m-1),y(:,m),'Linewidth',1);
  else
    h=plot(y(:,m-1),y(:,m),'Linewidth',1);
  end
  legend_str=strvcat(legend_str, labels(m+1,:));
end

verticallines=[SED_verticallines_SED];
ylimit=get(gca,'ylim');
line([verticallines;verticallines],ylimit,'linewidth',1,'color','k','linestyle','-.');

if (ncols<=2*5) 
%abc=1
legend(legend_str(:,:),'Location','SouthEast');
elseif (ncols<=2*14) 
lh=legend(legend_str(:,:),'Location','EastOutside');
v = get(lh,'title');
set(v,'string','SED_legend_name_SED');
%xyz=2
%legend(legend_str(:,:),'Location','SouthEast');
else
legend(legend_str(1:14,:),'Location','NorthEastOutside');
ylimit=get(gca,'YLim');
xlimit=get(gca,'XLim');
text(xlimit(2),ylimit(2),'Legend to long','VerticalAlignment','bottom','HorizontalAlignment','left');
%LineHandles = findobj('Type','Line');
end
 
xlabel(labels(3,:),'FontSize',12);  % add axis labels and plot title
ylabel(labels(1,:),'FontSize',12);

set(gca,'FontSize',10);

titlename='SED_title_SED';
tmp = strrep(titlename, '_', ' ');
tmp = strrep(tmp, '/', ' ');
tmp = strrep(tmp, '+', ' ');
tmp = strrep(tmp, 'rdf', 'RDF of');
tmp = strrep(tmp, 'cn', 'CN of');
tmp = strrep(tmp, 'numberdens', '\rho_N');
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
print('-depsc2', sprintf('-r%d', iResolution), strcat(savename, '.eps'));
%fixPSlinestyle(strcat(savename, '.eps'),strcat(savename, '+fixed.eps'));
fixPSlinestyle(strcat(savename, '.eps'),strcat(savename, '.eps'));

quit;
