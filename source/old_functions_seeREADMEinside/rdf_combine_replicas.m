% File:  rdf_combine_replicas.m
%
% Kathleen Kirchner, 22.03.2012
%
% Analysing of rdf files

function rdf_combine_replicas(ncols)

addpath('SED_dir_scripts_SED');

[labels_rdf,x_rdf,values_rdf] = readColData('SED_rdf-file_SED',ncols);
[labels_cn,x_cn,values_cn] = readColData('SED_cn-file_SED',ncols);

%n = 1;
%while n < ncols+1
%labels(n,:) = strrep(labels(n,:), '_', '-');
%n = n + 1;
%end

values_rdf_total=values_rdf(:,1);
values_cn_total=values_cn(:,1);

% Loop through all columns and sum them up
for i = 3:2:ncols
values_rdf_total=values_rdf_total+values_rdf(:,i);
values_cn_total=values_cn_total+values_cn(:,i);
end

% Calculate mean
values_rdf_total=values_rdf_total/(ncols/2);
values_cn_total=values_cn_total/(ncols/2);

%NOTE: only y values are printed, not x TODO
% Print the rdf and cn values
print_rdf(:,1)=x_rdf;
print_rdf(:,2)=values_rdf_total;
print_cn(:,1)=x_cn;
print_cn(:,2)=values_cn_total;
dlmwrite('SED_rdf_savename_SED', print_rdf, 'delimiter', ' ', 'precision', 4);
dlmwrite('SED_cn_savename_SED', print_cn, 'delimiter', ' ', 'precision', 4);

% Calculate the Maxima and Minima and return them 
xx=x_rdf;
pp=splinefit(x_rdf,values_rdf_total,100); %be careful about the last number, it defines how many data points are considered for one spline
yy=ppval(pp,xx);

findpeaks(yy,'MINPEAKHEIGHT',0.1,'MINPEAKDISTANCE',200)
%[maxpks_y,maxlocs]=findpeaks(yy,'MINPEAKHEIGHT',1.03,'MINPEAKDISTANCE',10);
[maxpks_y,maxlocs]=findpeaks(yy,'MINPEAKHEIGHT',0.1,'MINPEAKDISTANCE',200);
[firstmaxy,firstmaxi] = max(yy);

% delete all maximas that are positioned before the global maximum, but only if the global maximum is not the last entry
% Considering OMI Cl - The interaction between tail and anion are very week, therefore the global maximum was one in the end of the list and all Minimas have been deleted
if maxlocs(end)~=firstmaxi(1) %not equal
while maxlocs(1) < firstmaxi(1)
	maxlocs(1)=[];
	maxpks_y(1)=[];
end
end
maxpks_x=xx(maxlocs);
maxpks_text=maxlocs; maxpks_text(:)=1;

[minpks_y,minlocs]=findpeaks(-yy,'MINPEAKDISTANCE',200);
minpks_y=-minpks_y;
while minlocs(1) < maxlocs(1)
	minlocs(1)=[];
	minpks_y(1)=[];
end
minpks_x=xx(minlocs);
minpks_text=minlocs;minpks_text(:)=2;

extrema(:,1)=vertcat(maxpks_x,minpks_x);
extrema(:,2)=vertcat(maxpks_y,minpks_y);
extrema(:,3)=vertcat(values_cn_total(maxlocs),values_cn_total(minlocs)); %this is only true if xx=x_rdf
extrema(:,4)=vertcat(maxpks_text,minpks_text);
extrema=sortrows(extrema);

dlmwrite('tmp', extrema, 'delimiter', ' ', 'precision', 3);

% Simple plot with extremas for fast visual check
f = figure('XVisual','0x27 (TrueColor, depth 24, RGB mask 0xff0000 0xff00 0x00ff)');

plot(x_rdf,values_rdf_total,'b.',xx,yy,'r-',extrema(:,1),extrema(:,2),'k^','Linewidth',2)

text_VA={'Bottom' 'Top'};
%for K = 1:size(extrema(:,1))
for K = 1:8
	extremalabel=strcat('(',num2str(extrema(K,1),3));
	extremalabel=strcat(extremalabel,',');
	extremalabel=strcat(extremalabel,num2str(extrema(K,2),3));
	extremalabel=strcat(extremalabel,')');
	a=char(text_VA(extrema(K,4)));
	text(extrema(K,1),extrema(K,2),extremalabel,'VerticalAlignment',a,'HorizontalAlignment','Center','FontSize',14);
end

legend('Raw data','Fit','Extrema','Location','South');

xlabel('r (nm)','FontSize',18);  % add axis labels and plot title
ylabel('g(r)','FontSize',18);

titlename='SED_title_SED';
tmp = strrep(titlename, '_', ' ');
tmp = strrep(tmp, '/', ' ');
tmp = strrep(tmp, '+', ' ');
tmp = strrep(tmp, 'rdf', 'RDF of');
titlename = tmp
title(titlename,'FontSize',18);

set(gca,'FontSize',18);

xlim([0 x_rdf(end)]);

savename='SED_rdf_savename_SED';
savename = strrep(savename, '.dat', '');
strFilePath = savename;
iResolution = 150;
print('-depsc2', sprintf('-r%d', iResolution), strcat(strFilePath, '.eps'));

quit;
