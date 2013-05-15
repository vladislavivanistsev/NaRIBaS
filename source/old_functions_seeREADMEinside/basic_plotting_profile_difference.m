% File:  basic_plotting.m
%
% Kathleen Kirchner, 21.08.2012
%
% Basic plotting

function basic_plotting(ncols)

addpath('SED_dir_scripts_SED');

[labels,x,y] = readColData('SED_plotfile_SED',ncols);

f = figure('XVisual',...
    '0x27 (TrueColor, depth 24, RGB mask 0xff0000 0xff00 0x00ff)');

set(gcf,'PaperUnits','centimeters')
%This sets the units of the current figure (gcf = get current figure) on paper to centimeters.
xSize = 8.6; ySize = 7.0; %For APS paper the recomended figure width equals the column width of the paper 8.6 cm (or 2 times 8.6 cm for long figures) % xSize =  changed from 10.0 to 8.6 for a plotting reason, change back afterwards
%These are my size variables, width of 8 and a height of 12, will be used a lot later.
xLeft = (21-xSize)/2; yTop = (30-ySize)/2;
%Additional coordinates to center the figure on A4-paper
set(gcf,'PaperPosition',[xLeft yTop xSize ySize]);
%This command sets the position and size of the figure on the paper to the desired values.
set(gcf,'Position',[200 200 xSize*50 ySize*50]);

ColorSet = varycolor(ncols/2);

if (ncols<=2*2) % if there are just one or two lines, draw red and blue
ColorSet(1,:)=[255 0 0]/255;
ColorSet(2,:)=[0 0 255]/255;
elseif (ncols==2*4) % temperature appearance: cold to hot = blue to red
ColorSet(1,:)=[0 220 30]/255;
ColorSet(2,:)=[86 180 233]/255;
ColorSet(3,:)=[0 114 178]/255;
ColorSet(4,:)=[20 0 220]/255;
%ColorSet(2,:)=[89 17 150]/255;
%ColorSet(3,:)=[178 10 10]/255;
%ColorSet(4,:)=[213 94 0]/255;
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

set(gca, 'ColorOrder', ColorSet);

LineStyleSet = {'-','-.',':'};

%xlim([x(1) x(end)]);
xlim([SED_xlim_SED]);
ylim([SED_ylim_SED]);

hold all;

legend_str=[];

for m = 1:2:ncols
  set(gca,'LineStyleOrder',LineStyleSet{1, mod(m-1,3)+1});
  if (m==1)
    h((m+1)/2)=plot(x,y(:,m)-y(:,1),'Linewidth',2);
  else
    h((m+1)/2)=plot(y(:,m-1),y(:,m)-y(:,1),'Linewidth',2);
  end
  legend_str=strvcat(legend_str, labels(m+1,:));
end

verticallines=[SED_verticallines_SED];
ylimit=get(gca,'ylim');
line([verticallines;verticallines],ylimit,'linewidth',1,'color','k','linestyle','-.');

if (ncols<=2*5) 
xyz='no legend'
%legend(legend_str(:,:),'Location','NorthEast');
elseif (ncols<=2*14) 

legend_str(1,:)=[];
legend_str=strvcat('PZC',legend_str);

order=[8 7 6 5 4 3 2 1]

%h_axes = gca;
%h_plot = get(h_axes,'Children')
%h_plot = findobj(gca,'type','line');

lh=legend(h(order),legend_str(order,:),'Location','EastOutside');
%lh=legend(legend_str(:,:),'Location','EastOutside');

v = get(lh,'title');
set(v,'string','SED_legend_name_SED');
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
