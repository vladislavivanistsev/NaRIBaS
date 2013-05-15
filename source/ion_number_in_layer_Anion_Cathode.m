% File:  ion_number_in_layer.m
%
% Kathleen Kirchner, 21.08.2012
%

function ion_number_in_layer(ncols,electrodeatoms,xbox_nm,ybox_nm)

addpath('SED_dir_scripts_SED');

[labels,x,y] = readColData('SED_cnfile_SED',ncols);
[labels_numberdens,x_numberdens,y_numberdens] = readColData('SED_numberdensfile_SED',ncols);
[labels2,potential,surfcharge] = readColData('SED_potentialdropfile_SED',2,0,0);

for m = 1:2:ncols
	% Clear the data
	extrema=[];

	% Calculate the Maxima and Minima and return them 
	xx=x_numberdens;
	yy=y_numberdens(:,m);

% Anions at Cathode
%%{
	maxpks=findpeaks(xx,yy,0.00005,0.0,10,30,3);
	minpks=findvalleys(xx,yy,0.00005,0.0,10,30,3);
	firstmaxpk=findpeaks(xx,yy,0.00005,0.0,10,15,3);
	maxpks(1,:)=firstmaxpk(1,:);
%}

	maxpks_text=maxpks(:,1); maxpks_text(:)=1;
	minpks_text=minpks(:,1); minpks_text(:)=2;

	extrema(:,1)=vertcat(maxpks(:,2),minpks(:,2));
	extrema(:,2)=vertcat(maxpks(:,3),minpks(:,3));
	extrema(:,3)=vertcat(maxpks_text,minpks_text);
	extrema=sortrows(extrema);

	% Simple plot with extremas for fast visual check
	f = figure('XVisual',...
		'0x27 (TrueColor, depth 24, RGB mask 0xff0000 0xff00 0x00ff)');

	set(gcf,'PaperUnits','centimeters')
	xSize = 8.6; ySize = 5.0; %For APS paper the recomended figure width equals the column width of the paper 8.6 cm (or between 10 cm and 2 times 8.6 cm for long figures)
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
		a=char(text_VA(extrema(K,3)));
		text(extrema(K,1),extrema(K,2),extremalabel,'VerticalAlignment',a,'HorizontalAlignment','Center','FontSize',10);
	end

	legend('Raw data','Maxima','Minima','Location','EastOutside');

	xlabel('z(nm)','FontSize',12);  % add axis labels and plot title
	ylabel('\rho_N(nm^{-3})','FontSize',12);

	xlim([0 4]);

	set(gca,'FontSize',10);

	titlename='SED_title_SED';
	titlename = strcat(titlename,strrep(labels(m+1,:),'-','+'));
	titlename = strcat(titlename,'\muC cm^{-2}');
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
	savename = strcat(savename,'+');
	savename = strcat(savename,labels(m+1,:));
	iResolution = 600;
	print('-depsc2', sprintf('-r%d', iResolution),strcat(savename, '+check.eps'));
	fixPSlinestyle(strcat(savename, '+check.eps'),strcat(savename, '+check.eps'));
	%%%%%%%%%%

	[min_difference, minlocs1] = min(abs(x - minpks(1,2)));
	[min_difference, minlocs2] = min(abs(x - minpks(2,2)));

	ionnumber_firstlayer((m+1)/2)= y(minlocs1,m);
	if (y(minlocs1,m)<0)
		ionnumber_firstlayer((m+1)/2)=NaN
	end

	minposition_firstlayer((m+1)/2)= minpks(1,2);
	minheight_firstlayer((m+1)/2)= minpks(1,3);

%	if numel(minlocs)==1
%	warn='There is only one minimum. Second minimum will be set as eual to the first minimum.'
%	ionnumber_secondlayer((m+1)/2)= y(minlocs1,m)-y(minlocs1,m);
%	minposition_secondlayer((m+1)/2)= minpks(1,2);
%	minheight_secondlayer((m+1)/2)= minpks(1,3);
%	else
	ionnumber_secondlayer((m+1)/2)= y(minlocs2,m)-y(minlocs1,m);

	if ( y(minlocs2,m)-y(minlocs1,m)<0 )
		ionnumber_secondlayer((m+1)/2)=NaN
	end

	minposition_secondlayer((m+1)/2)= minpks(2,2);
	minheight_secondlayer((m+1)/2)= minpks(2,3);
%	end

	maxwidth_firstlayer((m+1)/2)= maxpks(1,4);
	maxwidth_secondlayer((m+1)/2)= maxpks(2,4);

	sigma((m+1)/2)=str2num(labels(m+1,:));
	voltage((m+1)/2)=potential(find(surfcharge-sigma((m+1)/2)==0, 1, 'first'));
end

%[min_difference, array_position] = min(abs(x - cutoff));

%ionnumber=ionnumber./(xbox_nm*ybox_nm*(cutoff-r_ion-r_wall_nm)*currentdens);
%ionnumber=ionnumber./(xbox_nm*ybox_nm*(cutoff-r_ion/2)*currentdens);

printionnumber=[voltage',ionnumber_firstlayer'];
printionnumber_sorted=sortrows(printionnumber);
dlmwrite(strrep('SED_savename_SED','.dat','+firstlayer.dat'), printionnumber_sorted, 'delimiter', ' ', 'precision', 4);

printionnumber=[voltage',ionnumber_secondlayer'];
printionnumber_sorted=sortrows(printionnumber);
dlmwrite(strrep('SED_savename_SED','.dat','+secondlayer.dat'), printionnumber_sorted, 'delimiter', ' ', 'precision', 4);

ionnumber_thirdlayer=ionnumber_secondlayer;
ionnumber_thirdlayer(:)=NaN;

printionnumber=[voltage',ionnumber_thirdlayer'];
printionnumber_sorted=sortrows(printionnumber);
dlmwrite(strrep('SED_savename_SED','.dat','+thirdlayer.dat'), printionnumber_sorted, 'delimiter', ' ', 'precision', 4);


nm2m=10^-9;
cm2m=10^-2;
mu2one=10^-6;
e2C=1.602 * 10^-19;
C2e=1/e2C;
electronnumber=abs(sigma) .* xbox_nm * ybox_nm * mu2one * C2e * nm2m^2/cm2m^2 %(10^-6 ./ (1.602 .* 10^-19  .* 10^14))

printionnumber=[voltage',(ionnumber_firstlayer./electronnumber)'];
printionnumber_sorted=sortrows(printionnumber);
dlmwrite(strrep('SED_savename_SED','.dat','+firstlayer+normalized.dat'), printionnumber_sorted, 'delimiter', ' ', 'precision', 4);

printionnumber=[voltage',(ionnumber_secondlayer./electronnumber)'];
printionnumber_sorted=sortrows(printionnumber);
dlmwrite(strrep('SED_savename_SED','.dat','+secondlayer+normalized.dat'), printionnumber_sorted, 'delimiter', ' ', 'precision', 4);

printionnumber=[voltage',(ionnumber_thirdlayer./electronnumber)'];
printionnumber_sorted=sortrows(printionnumber);
dlmwrite(strrep('SED_savename_SED','.dat','+thirdlayer+normalized.dat'), printionnumber_sorted, 'delimiter', ' ', 'precision', 4);


electronnumber=sigma .* xbox_nm * ybox_nm * mu2one * C2e * nm2m^2/cm2m^2 

printionnumber=[electronnumber',(ionnumber_firstlayer)'];
printionnumber_sorted=sortrows(printionnumber);
dlmwrite(strrep('SED_savename_SED','.dat','+firstlayer+overelectrons.dat'), printionnumber_sorted, 'delimiter', ' ', 'precision', 4);

printionnumber=[electronnumber',(ionnumber_secondlayer)'];
printionnumber_sorted=sortrows(printionnumber);
dlmwrite(strrep('SED_savename_SED','.dat','+secondlayer+overelectrons.dat'), printionnumber_sorted, 'delimiter', ' ', 'precision', 4);

printionnumber=[electronnumber',(ionnumber_thirdlayer)'];
printionnumber_sorted=sortrows(printionnumber);
dlmwrite(strrep('SED_savename_SED','.dat','+thirdlayer+overelectrons.dat'), printionnumber_sorted, 'delimiter', ' ', 'precision', 4);



printionnumber=[sigma',(ionnumber_firstlayer)'];
printionnumber_sorted=sortrows(printionnumber);
dlmwrite(strrep('SED_savename_SED','.dat','+firstlayer+sigma.dat'), printionnumber_sorted, 'delimiter', ' ', 'precision', 4);

printionnumber=[sigma',(ionnumber_secondlayer)'];
printionnumber_sorted=sortrows(printionnumber);
dlmwrite(strrep('SED_savename_SED','.dat','+secondlayer+sigma.dat'), printionnumber_sorted, 'delimiter', ' ', 'precision', 4);

printionnumber=[sigma',(ionnumber_thirdlayer)'];
printionnumber_sorted=sortrows(printionnumber);
dlmwrite(strrep('SED_savename_SED','.dat','+thirdlayer+sigma.dat'), printionnumber_sorted, 'delimiter', ' ', 'precision', 4);


printionnumber=[sigma',minposition_firstlayer'];
printionnumber_sorted=sortrows(printionnumber);
dlmwrite(strrep('SED_savename_SED','.dat','+minposition+firstlayer+sigma.dat'), printionnumber_sorted, 'delimiter', ' ', 'precision', 4);

printionnumber=[sigma',minposition_secondlayer'];
printionnumber_sorted=sortrows(printionnumber);
dlmwrite(strrep('SED_savename_SED','.dat','+minposition+secondlayer+sigma.dat'), printionnumber_sorted, 'delimiter', ' ', 'precision', 4);

printionnumber=[sigma',minheight_firstlayer'];
printionnumber_sorted=sortrows(printionnumber);
dlmwrite(strrep('SED_savename_SED','.dat','+minheight+firstlayer+sigma.dat'), printionnumber_sorted, 'delimiter', ' ', 'precision', 4);

printionnumber=[sigma',minheight_secondlayer'];
printionnumber_sorted=sortrows(printionnumber);
dlmwrite(strrep('SED_savename_SED','.dat','+minheight+secondlayer+sigma.dat'), printionnumber_sorted, 'delimiter', ' ', 'precision', 4);

printionnumber=[sigma',maxwidth_firstlayer'];
printionnumber_sorted=sortrows(printionnumber);
dlmwrite(strrep('SED_savename_SED','.dat','+maxwidth+firstlayer+sigma.dat'), printionnumber_sorted, 'delimiter', ' ', 'precision', 4);

printionnumber=[sigma',maxwidth_secondlayer'];
printionnumber_sorted=sortrows(printionnumber);
dlmwrite(strrep('SED_savename_SED','.dat','+maxwidth+secondlayer+sigma.dat'), printionnumber_sorted, 'delimiter', ' ', 'precision', 4);




printionnumber=[voltage',minposition_firstlayer'];
printionnumber_sorted=sortrows(printionnumber);
dlmwrite(strrep('SED_savename_SED','.dat','+minposition+firstlayer.dat'), printionnumber_sorted, 'delimiter', ' ', 'precision', 4);

printionnumber=[voltage',minposition_secondlayer'];
printionnumber_sorted=sortrows(printionnumber);
dlmwrite(strrep('SED_savename_SED','.dat','+minposition+secondlayer.dat'), printionnumber_sorted, 'delimiter', ' ', 'precision', 4);


printionnumber=[sigma',minposition_firstlayer',minposition_secondlayer'];
printionnumber_sorted=sortrows(printionnumber);
dlmwrite(strrep('SED_savename_SED','.dat','+minposition+oversigma.dat'), printionnumber_sorted, 'delimiter', ' ', 'precision', 4);


printionnumber=[voltage',minheight_firstlayer'];
printionnumber_sorted=sortrows(printionnumber);
dlmwrite(strrep('SED_savename_SED','.dat','+minheight+firstlayer.dat'), printionnumber_sorted, 'delimiter', ' ', 'precision', 4);

printionnumber=[voltage',minheight_secondlayer'];
printionnumber_sorted=sortrows(printionnumber);
dlmwrite(strrep('SED_savename_SED','.dat','+minheight+secondlayer.dat'), printionnumber_sorted, 'delimiter', ' ', 'precision', 4);

printionnumber=[voltage',maxwidth_firstlayer'];
printionnumber_sorted=sortrows(printionnumber);
dlmwrite(strrep('SED_savename_SED','.dat','+maxwidth+firstlayer.dat'), printionnumber_sorted, 'delimiter', ' ', 'precision', 4);

printionnumber=[voltage',maxwidth_secondlayer'];
printionnumber_sorted=sortrows(printionnumber);
dlmwrite(strrep('SED_savename_SED','.dat','+maxwidth+secondlayer.dat'), printionnumber_sorted, 'delimiter', ' ', 'precision', 4);


quit;
