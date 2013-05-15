% File:  combine_replicas.m
%
% Kathleen Kirchner, 17.09.2012
%
% Combine any data files from replicas by calculating the mean value

function combine_replicas(ncols)

addpath('SED_dir_scripts_SED');

[labels,x,values] = readColData('SED_file_SED',ncols);

values_total=values(:,1);

% Loop through all columns and sum them up
for i = 3:2:ncols
values_total=values_total+values(:,i);
end

% Calculate mean
values_total=values_total/(ncols/2);

% Print the values
print_all(:,1)=x;
print_all(:,2)=values_total;
dlmwrite('SED_savename_SED', print_all, 'delimiter', ' ', 'precision', 4);

quit;
