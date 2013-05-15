% File:  potential_drop.m
%
% Kathleen Kirchner, 21.08.2012
%
% Basic plotting

function potential_drop(ncols)

addpath('SED_dir_scripts_SED');

[labelsanode,xanode,yanode] = readColData('SED_anode-file_SED',ncols);
[labelscathode,xcathode,ycathode] = readColData('SED_cathode-file_SED',ncols);

epsilonstar=2; %effective dielectric constant due to the fast electronic polarizability of ions which is not considered explicitly in the simulation only the case in Maxims work
nm2m=10^-9;
A2m=10^-10;
echarge=1.60218*10^-19; %in C=F*V  coulomb=farad*volt
epsilon0=8.854*10^-12; %in F/m

% sigma is given in muC/cm^2
cm2m=10^-2;
mu2one=10^-6;

% charge density rho(z) is given in e/nm^3

%Conversion from cgs to SI
% U_cgs=4*pi/epsilonstar * integral(z *rho_cgs(z))dz
% U_SI*sqrt(4*pi*epsilon0)=4*pi/epsilonstar * integral(z *rho_SI(z)/sqrt(4*pi*epsilon0))dz
% U_SI=4*pi/epsilonstar * 1/(4*pi*epsilon0) * integral(z *rho_SI(z))dz
% U_SI=1/(epsilonstar*epsilon0) * integral(z *rho_SI(z))dz

% z in nm, dz in nm, rho in e/nm^3

u_drop_total=[;];

x=xanode;
y=yanode;
labels=labelsanode;

for m = 1:2:ncols
  sigma_value=str2double(labels(m+1,:)); %The anode is positively charged
  z_times_charge_distr=x(:).*y(:,m);	%calc: z * q
  u_drop=trapz(x,z_times_charge_distr);	% integral(z*q)dr using trapezodial rule
  u_drop=-1*(echarge*nm2m^2/nm2m^3)/(epsilonstar*epsilon0)*u_drop; 
  u_drop_total=[u_drop_total;u_drop,sigma_value];
end

x=xcathode;
y=ycathode;
labels=labelscathode;

for m = 1:2:ncols
  sigma_value=str2double(labels(m+1,:)) * (-1); % The cathode is negatively charged
  z_times_charge_distr=x(:).*y(:,m);	% calc: z * q
  u_drop=trapz(x,z_times_charge_distr);	% integral(z*q)dr using trapezodial rule
  u_drop=-1*(echarge*nm2m^2/nm2m^3)/(epsilonstar*epsilon0)*u_drop; 
  u_drop_total=[u_drop_total;u_drop,sigma_value];
end

u_drop_sorted=sortrows(u_drop_total);
dlmwrite('SED_savename_SED', u_drop_sorted, 'delimiter', ' ', 'precision', 4);

quit;
