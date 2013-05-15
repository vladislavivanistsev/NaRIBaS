% File:  numberdens2chargedens2cn.m
%
% Kathleen Kirchner, 21.08.2012
%
% Basic plotting

function numberdens2chargedens2cn(ncols,deltaz,xbox_nm,ybox_nm)

[labelscation,zcation,numdens_cation] = readColData('SED_numberdenscation_SED',ncols,0,0);
[labelsanion,zanion,numdens_anion] = readColData('SED_numberdensanion_SED',ncols,0,0);

% Estimate the positions of the electrodes

GZ_vec=zcation(:);

posGl1=SED_posanode_SED; %in nm
posGr1=SED_poscathode_SED; %in nm

GZ_vec_left=GZ_vec-posGl1; %the origin of the vector is set to the electrodes (increasing when going into the bulk)
GZ_vec_right=-(GZ_vec-posGr1); 

posGl1_N=round(posGl1/GZ_vec(2))+1;
posGr1_N=round(posGr1/GZ_vec(2))+1;

GZ_vec_left=GZ_vec_left;
GZ_vec_right=GZ_vec_right-GZ_vec_right(posGr1_N)+GZ_vec_left(posGl1_N);

Nz= round((posGr1-posGl1)/GZ_vec(2));
middle=round(posGl1_N+Nz/2);
%NOTE: In case of an error message: "Error using horzcat CAT arguments dimensions are not consistent." the total number of data points might not be equal for Cathode and anode. A wrok around would be to add 1 or substract 1 value from one of the electrodes by substituting (posGr1_N:-1:middle) with (posGr1_N:-1:middle+1) or (posGr1_N:-1:middle-1).

% Calculating the charge density

chargedens=numdens_cation.*(1.0)+numdens_anion.*(-1.0);

chargedensityprofile = [zcation,chargedens];
dlmwrite('SED_savename-chargedens_SED', chargedensityprofile, 'delimiter', ' ', 'precision', 4);

% Calculating the cumulative number of number densities

[nr,nc]=size(zcation); %rows and columns count of zcation

cum_numdens_cation=zcation;
cum_numdens_cation=0;
cum_numdens_anion=zanion;
cum_numdens_anion=0;

cum_numdens_cation(1)=numdens_cation(1);
cum_numdens_anion(1)=numdens_anion(1);

for n = 2:nr
  cum_numdens_cation(n)=cum_numdens_cation(n-1)+numdens_cation(n);
  cum_numdens_anion(n)=cum_numdens_anion(n-1)+numdens_anion(n);
end

cum_numdens_cation(:)=cum_numdens_cation(:) .* deltaz .* xbox_nm .* ybox_nm;
cum_numdens_anion(:)=cum_numdens_anion(:) .* deltaz .* xbox_nm .* ybox_nm;


% Calculating the cumulative number of charge densities

[nr,nc]=size(zcation); %rows and columns count of zcation

cum_chargedens=zcation;
cum_chargedens=0;

cum_chargedens(1)=chargedens(1);

for n = 2:nr
  cum_chargedens(n)=cum_chargedens(n-1)+chargedens(n);
end

cum_chargedens(:)=cum_chargedens(:) .* deltaz .* xbox_nm .* ybox_nm;

%%%% printing everything

[size_left_vector,aaa]=size(GZ_vec_left(posGl1_N:1:middle));
[size_right_vector,aaa]=size(GZ_vec_right(posGr1_N:-1:middle));

if size_left_vector == size_right_vector+1
% Print the number densities (Cation-Anode, Anion-Anode, Cation-Cathode, Anion-Cathode)

numberdens = [GZ_vec_left(posGl1_N:1:middle), numdens_cation(posGl1_N:1:middle),GZ_vec_left(posGl1_N:1:middle),numdens_anion(posGl1_N:1:middle),GZ_vec_right(posGr1_N:-1:middle-1),numdens_cation(posGr1_N:-1:middle-1),GZ_vec_right(posGr1_N:-1:middle-1),numdens_anion(posGr1_N:-1:middle-1)];

dlmwrite(strrep('SED_savename-numberdens_SED','.dat','+Cation-Anode.dat'), numberdens(:,1:2), 'delimiter', ' ', 'precision', 4);
dlmwrite(strrep('SED_savename-numberdens_SED','.dat','+Anion-Anode.dat'), numberdens(:,3:4), 'delimiter', ' ', 'precision', 4);
dlmwrite(strrep('SED_savename-numberdens_SED','.dat','+Cation-Cathode.dat'), numberdens(:,5:6), 'delimiter', ' ', 'precision', 4);
dlmwrite(strrep('SED_savename-numberdens_SED','.dat','+Anion-Cathode.dat'), numberdens(:,7:8), 'delimiter', ' ', 'precision', 4);

% Print the charge densities (Anode, Cathode)

chargedensityprofile2 = [GZ_vec_left(posGl1_N:1:middle), chargedens(posGl1_N:1:middle),GZ_vec_right(posGr1_N:-1:middle-1),chargedens(posGr1_N:-1:middle-1)];

dlmwrite(strrep('SED_savename-chargedens_SED','.dat','+Anode.dat'), chargedensityprofile2(:,1:2), 'delimiter', ' ', 'precision', 4);
dlmwrite(strrep('SED_savename-chargedens_SED','.dat','+Cathode.dat'), chargedensityprofile2(:,3:4), 'delimiter', ' ', 'precision', 4);

% Print the cumulative number of number densities (Cation-Anode, Anion-Anode, Cation-Cathode, Anion-Cathode)

cn_numberdens = [GZ_vec_left(posGl1_N:1:middle), cum_numdens_cation(posGl1_N:1:middle)',GZ_vec_left(posGl1_N:1:middle),cum_numdens_anion(posGl1_N:1:middle)',GZ_vec_right(posGr1_N:-1:middle-1),(cum_numdens_cation(end)-cum_numdens_cation(posGr1_N:-1:middle-1))',GZ_vec_right(posGr1_N:-1:middle-1),(cum_numdens_anion(end)-cum_numdens_anion(posGr1_N:-1:middle-1))'];

dlmwrite(strrep('SED_savename-cn-numberdens_SED','.dat','+Cation-Anode.dat'), cn_numberdens(:,1:2), 'delimiter', ' ', 'precision', 4);
dlmwrite(strrep('SED_savename-cn-numberdens_SED','.dat','+Anion-Anode.dat'), cn_numberdens(:,3:4), 'delimiter', ' ', 'precision', 4);
dlmwrite(strrep('SED_savename-cn-numberdens_SED','.dat','+Cation-Cathode.dat'), cn_numberdens(:,5:6), 'delimiter', ' ', 'precision', 4);
dlmwrite(strrep('SED_savename-cn-numberdens_SED','.dat','+Anion-Cathode.dat'), cn_numberdens(:,7:8), 'delimiter', ' ', 'precision', 4);

% Print the cumulative number of charge densities (Anode, Cathode)

cn_chargedens = [GZ_vec_left(posGl1_N:1:middle), cum_chargedens(posGl1_N:1:middle)',GZ_vec_right(posGr1_N:-1:middle-1),(cum_chargedens(end)-cum_chargedens(posGr1_N:-1:middle-1))'];

dlmwrite(strrep('SED_savename-cn-chargedens_SED','.dat','+Anode.dat'), cn_chargedens(:,1:2), 'delimiter', ' ', 'precision', 4);
dlmwrite(strrep('SED_savename-cn-chargedens_SED','.dat','+Cathode.dat'), cn_chargedens(:,3:4), 'delimiter', ' ', 'precision', 4);

elseif size_left_vector == size_right_vector-1
% Print the number densities (Cation-Anode, Anion-Anode, Cation-Cathode, Anion-Cathode)

numberdens = [GZ_vec_left(posGl1_N:1:middle), numdens_cation(posGl1_N:1:middle),GZ_vec_left(posGl1_N:1:middle),numdens_anion(posGl1_N:1:middle),GZ_vec_right(posGr1_N:-1:middle+1),numdens_cation(posGr1_N:-1:middle+1),GZ_vec_right(posGr1_N:-1:middle+1),numdens_anion(posGr1_N:-1:middle+1)];

dlmwrite(strrep('SED_savename-numberdens_SED','.dat','+Cation-Anode.dat'), numberdens(:,1:2), 'delimiter', ' ', 'precision', 4);
dlmwrite(strrep('SED_savename-numberdens_SED','.dat','+Anion-Anode.dat'), numberdens(:,3:4), 'delimiter', ' ', 'precision', 4);
dlmwrite(strrep('SED_savename-numberdens_SED','.dat','+Cation-Cathode.dat'), numberdens(:,5:6), 'delimiter', ' ', 'precision', 4);
dlmwrite(strrep('SED_savename-numberdens_SED','.dat','+Anion-Cathode.dat'), numberdens(:,7:8), 'delimiter', ' ', 'precision', 4);

% Print the charge densities (Anode, Cathode)

chargedensityprofile2 = [GZ_vec_left(posGl1_N:1:middle), chargedens(posGl1_N:1:middle),GZ_vec_right(posGr1_N:-1:middle+1),chargedens(posGr1_N:-1:middle+1)];

dlmwrite(strrep('SED_savename-chargedens_SED','.dat','+Anode.dat'), chargedensityprofile2(:,1:2), 'delimiter', ' ', 'precision', 4);
dlmwrite(strrep('SED_savename-chargedens_SED','.dat','+Cathode.dat'), chargedensityprofile2(:,3:4), 'delimiter', ' ', 'precision', 4);

% Print the cumulative number of number densities (Cation-Anode, Anion-Anode, Cation-Cathode, Anion-Cathode)

cn_numberdens = [GZ_vec_left(posGl1_N:1:middle), cum_numdens_cation(posGl1_N:1:middle)',GZ_vec_left(posGl1_N:1:middle),cum_numdens_anion(posGl1_N:1:middle)',GZ_vec_right(posGr1_N:-1:middle+1),(cum_numdens_cation(end)-cum_numdens_cation(posGr1_N:-1:middle+1))',GZ_vec_right(posGr1_N:-1:middle+1),(cum_numdens_anion(end)-cum_numdens_anion(posGr1_N:-1:middle+1))'];

dlmwrite(strrep('SED_savename-cn-numberdens_SED','.dat','+Cation-Anode.dat'), cn_numberdens(:,1:2), 'delimiter', ' ', 'precision', 4);
dlmwrite(strrep('SED_savename-cn-numberdens_SED','.dat','+Anion-Anode.dat'), cn_numberdens(:,3:4), 'delimiter', ' ', 'precision', 4);
dlmwrite(strrep('SED_savename-cn-numberdens_SED','.dat','+Cation-Cathode.dat'), cn_numberdens(:,5:6), 'delimiter', ' ', 'precision', 4);
dlmwrite(strrep('SED_savename-cn-numberdens_SED','.dat','+Anion-Cathode.dat'), cn_numberdens(:,7:8), 'delimiter', ' ', 'precision', 4);

% Print the cumulative number of charge densities (Anode, Cathode)

cn_chargedens = [GZ_vec_left(posGl1_N:1:middle), cum_chargedens(posGl1_N:1:middle)',GZ_vec_right(posGr1_N:-1:middle+1),(cum_chargedens(end)-cum_chargedens(posGr1_N:-1:middle+1))'];

dlmwrite(strrep('SED_savename-cn-chargedens_SED','.dat','+Anode.dat'), cn_chargedens(:,1:2), 'delimiter', ' ', 'precision', 4);
dlmwrite(strrep('SED_savename-cn-chargedens_SED','.dat','+Cathode.dat'), cn_chargedens(:,3:4), 'delimiter', ' ', 'precision', 4);


else
% Print the number densities (Cation-Anode, Anion-Anode, Cation-Cathode, Anion-Cathode)

numberdens = [GZ_vec_left(posGl1_N:1:middle), numdens_cation(posGl1_N:1:middle),GZ_vec_left(posGl1_N:1:middle),numdens_anion(posGl1_N:1:middle),GZ_vec_right(posGr1_N:-1:middle),numdens_cation(posGr1_N:-1:middle),GZ_vec_right(posGr1_N:-1:middle),numdens_anion(posGr1_N:-1:middle)];

dlmwrite(strrep('SED_savename-numberdens_SED','.dat','+Cation-Anode.dat'), numberdens(:,1:2), 'delimiter', ' ', 'precision', 4);
dlmwrite(strrep('SED_savename-numberdens_SED','.dat','+Anion-Anode.dat'), numberdens(:,3:4), 'delimiter', ' ', 'precision', 4);
dlmwrite(strrep('SED_savename-numberdens_SED','.dat','+Cation-Cathode.dat'), numberdens(:,5:6), 'delimiter', ' ', 'precision', 4);
dlmwrite(strrep('SED_savename-numberdens_SED','.dat','+Anion-Cathode.dat'), numberdens(:,7:8), 'delimiter', ' ', 'precision', 4);

% Print the charge densities (Anode, Cathode)

chargedensityprofile2 = [GZ_vec_left(posGl1_N:1:middle), chargedens(posGl1_N:1:middle),GZ_vec_right(posGr1_N:-1:middle),chargedens(posGr1_N:-1:middle)];

dlmwrite(strrep('SED_savename-chargedens_SED','.dat','+Anode.dat'), chargedensityprofile2(:,1:2), 'delimiter', ' ', 'precision', 4);
dlmwrite(strrep('SED_savename-chargedens_SED','.dat','+Cathode.dat'), chargedensityprofile2(:,3:4), 'delimiter', ' ', 'precision', 4);

% Print the cumulative number of number densities (Cation-Anode, Anion-Anode, Cation-Cathode, Anion-Cathode)

cn_numberdens = [GZ_vec_left(posGl1_N:1:middle), cum_numdens_cation(posGl1_N:1:middle)',GZ_vec_left(posGl1_N:1:middle),cum_numdens_anion(posGl1_N:1:middle)',GZ_vec_right(posGr1_N:-1:middle),(cum_numdens_cation(end)-cum_numdens_cation(posGr1_N:-1:middle))',GZ_vec_right(posGr1_N:-1:middle),(cum_numdens_anion(end)-cum_numdens_anion(posGr1_N:-1:middle))'];

dlmwrite(strrep('SED_savename-cn-numberdens_SED','.dat','+Cation-Anode.dat'), cn_numberdens(:,1:2), 'delimiter', ' ', 'precision', 4);
dlmwrite(strrep('SED_savename-cn-numberdens_SED','.dat','+Anion-Anode.dat'), cn_numberdens(:,3:4), 'delimiter', ' ', 'precision', 4);
dlmwrite(strrep('SED_savename-cn-numberdens_SED','.dat','+Cation-Cathode.dat'), cn_numberdens(:,5:6), 'delimiter', ' ', 'precision', 4);
dlmwrite(strrep('SED_savename-cn-numberdens_SED','.dat','+Anion-Cathode.dat'), cn_numberdens(:,7:8), 'delimiter', ' ', 'precision', 4);

% Print the cumulative number of charge densities (Anode, Cathode)

cn_chargedens = [GZ_vec_left(posGl1_N:1:middle), cum_chargedens(posGl1_N:1:middle)',GZ_vec_right(posGr1_N:-1:middle),(cum_chargedens(end)-cum_chargedens(posGr1_N:-1:middle))'];

dlmwrite(strrep('SED_savename-cn-chargedens_SED','.dat','+Anode.dat'), cn_chargedens(:,1:2), 'delimiter', ' ', 'precision', 4);
dlmwrite(strrep('SED_savename-cn-chargedens_SED','.dat','+Cathode.dat'), cn_chargedens(:,3:4), 'delimiter', ' ', 'precision', 4);
end

quit;

