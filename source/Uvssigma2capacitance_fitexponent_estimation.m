% File:  Uvssigma2capacitance_exponent_estimation.m
%
% Kathleen Kirchner, 21.08.2012
%

function Uvssigma2capacitance_exponent_estimation()

addpath('SED_dir_scripts_SED');

[labels,x,y] = readColData('SED_file_SED',2,0,0);

potential=x;
sigma_values=y;

%%% Clear the data

% Delete data points with a much to high surface charge to be reliable
md = 1;
sigmalowdelete = -40; % in muC/cm^2; 16 muC/cm^2=e/nm^2
while sigma_values(md) < sigmalowdelete
    md = md + 1;
end
sigma_values(1:md-1)=[];
potential(1:md-1)=[];

md = 1;
sigmahighdelete = 40; % in muC/cm^2; 16 muC/cm^2=e/nm^2
while sigma_values(md) < sigmahighdelete
    md = md + 1;
end
sigma_values(md:end)=[];
potential(md:end)=[];

m = 1;
sigmalowlimit = -16; % in muC/cm^2; 16 muC/cm^2=e/nm^2
while sigma_values(m) < sigmalowlimit
    m = m + 1;
end

pzc_index=m;
while sigma_values(pzc_index) < 0
    pzc_index = pzc_index + 1;
end

% Store the potential of zero charge (PZC) and delete from data array for further calculations
PZC=potential(pzc_index:pzc_index+1);
potential(pzc_index:pzc_index+1)=[];
sigma_values(pzc_index:pzc_index+1)=[];

n = pzc_index;
sigmahighlimit = 16; % in muC/cm^2; 16 muC/cm^2=e/nm^2
while sigma_values(n) < sigmahighlimit
    n = n + 1;
end

sigma=sigma_values(m:n);
pot=potential(m:n);

%%% Fit the asymptotes to sqrt(pot)

X = potential;
Y = sigma_values;

% This is volodyas routine for fitting the left and right asymptote
[N,t]=size(X);

x_min=min(X);
x_max=max(X);
x_len = x_max - x_min;

KErf = x_len * 0.15;

KErfStr = '1';

LeftTail = (1: ceil(N * 0.15) );
RightTail = ( N - ceil(N * 0.15) : N );

% In case the fitting exponent should be estimated, choose the following lines
templ='(a*abs(x)^c-b)*(1/(1+exp(-C*x) ))';
FT=fittype(templ,'coeff',{'a','b','c','C'});

fitL = fit(X(LeftTail),Y(LeftTail),FT,'start',[-1,0,0.8,1]);
fitR = fit(X(RightTail),Y(RightTail),FT,'start',[1,0,0.8,1]);

fitL
fitR

dlmwrite(strcat('fitexponent_left+','SED_savename_SED'), fitL.c, 'delimiter', ' ', 'precision', 4);
dlmwrite(strcat('fitexponent_right+','SED_savename_SED'), fitR.c, 'delimiter', ' ', 'precision', 4);

fnL = subs(templ,{'a','b','c','C'},{fitL.a,fitL.b,fitL.c,fitL.C});
fnR = subs(templ,{'a','b','c','C'},{fitR.a,fitR.b,fitL.c,fitR.C});

% Fit routine with correct exponent
templ=strcat('(a*abs(x)^',num2str(fitL.c));
templ=strcat(templ,'-b)*(1/(1+exp(-C*x) ))');
FT=fittype(templ,'coeff',{'a','b','C'});

fitL = fit(X(LeftTail),Y(LeftTail),FT,'start',[-1,0,1]);
fitR = fit(X(RightTail),Y(RightTail),FT,'start',[1,0,1]);

fnL = subs(templ,{'a','b','C'},{fitL.a,fitL.b,fitL.C});
fnR = subs(templ,{'a','b','C'},{fitR.a,fitR.b,fitR.C});

%% Go on
YR = subs(fnR,'x',X);
YL = subs(fnL,'x',X);

sigma_new = ['1-exp(-10/' KErfStr '*x^2)'];
Ysigma = subs(sigma_new,'x',X);

erfL = ['1-(erf((x )/' KErfStr ')+1)/2'];
erfR = ['(erf((x) /' KErfStr ')+1)/2'];

YerfL = subs(erfL,'x',X);
YerfR = subs(erfR,'x',X);

YSR = Ysigma.*YR.*YerfR;
YSL = Ysigma.*YL.*YerfL;

% Volodya then delted the result from the original data and fitted the remains
%YRem = Y-YSL-YSR;

% I will follow another route: I will extend the original data by the asymptotic behaviour and will process the result further
numpointsasym=20;
Xasym = zeros(N+2*numpointsasym,1);
Yasym = zeros(N+2*numpointsasym,1);

Xasym(1:numpointsasym) = (x_min-x_len:x_len/numpointsasym:x_min-x_len/numpointsasym)';
Xasym(numpointsasym+1:numpointsasym+N) = X;
Xasym(numpointsasym+1+N:numpointsasym*2+N) = (x_max+x_len/numpointsasym:x_len/numpointsasym:x_max+x_len)';

Ysigma = subs(sigma_new,'x',Xasym);

YR = subs(fnR,'x',Xasym);
YerfR = subs(erfR,'x',Xasym);
YSR = Ysigma.*YR.*YerfR;

YL = subs(fnL,'x',Xasym);
YerfL = subs(erfL,'x',Xasym);
YSL = Ysigma.*YL.*YerfL;

Yasym(1:numpointsasym) = YL(1:numpointsasym);
Yasym(numpointsasym+1:numpointsasym+N) = Y;
Yasym(numpointsasym+1+N:numpointsasym*2+N) = YR(numpointsasym+1+N:numpointsasym*2+N);

% Visualizing the asymptotic extension
%{
f = figure('XVisual','0x27 (TrueColor, depth 24, RGB mask 0xff0000 0xff00 0x00ff)');
plot(X,Y,'bo',Xasym,YL,'r-',Xasym,YR,'g-',Xasym(1:numpointsasym),Yasym(1:numpointsasym),'ro',Xasym(numpointsasym+1+N:numpointsasym*2+N),Yasym(numpointsasym+1+N:numpointsasym*2+N),'go','Linewidth',0.5);
%xlim([-5 5]);
legend('Raw data','Left asymptotics','Right asymptotics','Location','NorthWest');
xlabel('{\itU}_{drop} (V)','FontSize',18);  % add axis labels and plot title
ylabel('\sigma (\muC/cm^2)','FontSize',18);
title('Asymptotic extension','FontSize',18);
set(gca,'FontSize',18);
iResolution = 150;
print('-depsc2', sprintf('-r%d', iResolution), 'asymptotic_extension.eps');
close(f);
%}

% By asymptotic behaviour extended data set: Xasym, Yasym

%%% Spline fit of the extended data

xx = linspace(Xasym(1),Xasym(end),1001);
pp = splinefit(Xasym,Yasym,17);

% Nice potential drop curve, as there are many datapoints, use for differentiation
yy_splinefit = ppval(pp,xx);

pp_reverse=splinefit(Yasym,Xasym,17);
potential_at_zero_reversespline = ppval(pp_reverse,0);

% Smooth potential drop curve to transfer surface charges in voltages
x_smooth = ppval(pp_reverse,y);

printsmoothpotentialdrop=[x_smooth y];
dlmwrite('SED_savename-smoothpotentialdrop_SED', printsmoothpotentialdrop, 'delimiter', ' ', 'precision', 4);
printsmoothpotentialdrop_reversed=[y x_smooth];
printsmoothpotentialdrop_reversed_sorted=sortrows(printsmoothpotentialdrop_reversed);
dlmwrite(strcat('reversed','SED_savename-smoothpotentialdrop_SED'), printsmoothpotentialdrop_reversed_sorted, 'delimiter', ' ', 'precision', 4);


% Old differentiation routine
%Uxxafterdiff=xx(1:end-1)+diff(xx)/2;
%capacitance_diff=diff(yy_splinefit)./diff(xx); %differenciation took place, z vector is one element shorter

% Differentiating the spline fit
g=gradient(yy_splinefit,xx);
capacitance_gradient=g;

printcapacitance=[xx' capacitance_gradient'];
dlmwrite('SED_savename_SED', printcapacitance, 'delimiter', ' ', 'precision', 4);

printintegralcapacitance=[xx' (yy_splinefit./(xx-potential_at_zero_reversespline))'];
dlmwrite(strcat('integral','SED_savename_SED'), printintegralcapacitance, 'delimiter', ' ', 'precision', 4);

quit;
