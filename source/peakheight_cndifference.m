% File:  peakheight_cndifference.m
%
% Kathleen Kirchner, 21.08.2012
%

function peakheight_cndifference(ncols)

addpath('SED_dir_scripts_SED');

[labels,x,y] = readColData('SED_cnfile_SED',ncols);
[labels2,potential,surfcharge] = readColData('SED_potentialdropfile_SED',2,0,0);

[min_difference, array_position_left] = min(abs(x - 1));
[min_difference, array_position_right] = min(abs(x - 2));

for m = 1:2:ncols
  peakheight((m+1)/2)= max(y(array_position_left: array_position_right,m)-y(array_position_left: array_position_right,1));
  sigma((m+1)/2)=str2num(labels(m+1,:));
  voltage((m+1)/2)=potential(find(surfcharge-sigma((m+1)/2)==0, 1, 'first'));
end

printpeakheight=[voltage',peakheight'];
printpeakheight_sorted=sortrows(printpeakheight);
dlmwrite('SED_savename_SED', printpeakheight_sorted, 'delimiter', ' ', 'precision', 4);

g=gradient(peakheight',voltage');

printpeakheight=[voltage',g];
printpeakheight_sorted=sortrows(printpeakheight);
dlmwrite('SED_savename2_SED', printpeakheight_sorted, 'delimiter', ' ', 'precision', 4);


quit;
