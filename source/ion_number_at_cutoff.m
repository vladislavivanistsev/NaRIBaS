% File:  ion_number_at_cutoff.m
%
% Kathleen Kirchner, 21.08.2012
%

function ion_number_at_cutoff(ncols,cutoff,r_ion,r_wall_nm,xbox_nm,ybox_nm,currentdens)

addpath('SED_dir_scripts_SED');

[labels,x,y] = readColData('SED_cnfile_SED',ncols);
[labels2,potential,surfcharge] = readColData('SED_potentialdropfile_SED',2,0,0);

[min_difference, array_position] = min(abs(x - cutoff));

for m = 1:2:ncols
  ionnumber((m+1)/2)= y(array_position,m);
  sigma((m+1)/2)=str2num(labels(m+1,:));
  voltage((m+1)/2)=potential(find(surfcharge-sigma((m+1)/2)==0, 1, 'first'));
end

%ionnumber=ionnumber./(xbox_nm*ybox_nm*(cutoff-r_ion-r_wall_nm)*currentdens);
ionnumber=ionnumber./(xbox_nm*ybox_nm*(cutoff-r_ion)*currentdens);


printionnumber=[voltage',ionnumber'];
printionnumber_sorted=sortrows(printionnumber);
dlmwrite('SED_savename_SED', printionnumber_sorted, 'delimiter', ' ', 'precision', 4);

quit;
