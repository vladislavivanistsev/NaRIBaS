% File:  Uvssigma2capacitance_error.m
%
% Kathleen Kirchner, 21.08.2012
%

function Uvssigma2capacitance_error(ncols)

addpath('SED_dir_scripts_SED');

[labels_capacitance,x_capacitance,y_capacitance] = readColData('SED_plotfile1_SED',ncols);
[labels_potentialdrop,x_potentialdrop,y_potentialdrop] = readColData('SED_plotfile2_SED',ncols);

u_drop_0 = load('SED_replica0_SED');
u_drop_1 = load('SED_replica1_SED');
u_drop_2 = load('SED_replica2_SED');
u_drop_3 = load('SED_replica3_SED');
u_drop_4 = load('SED_replica4_SED');

% Redo the spline fit
sigma_values=y_potentialdrop(:,1);
potential=x_potentialdrop(:,1);

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


%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%% fit the asymptotes to sqrt(pot)

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

templ='(a*sqrt(abs(x))-b)*(1/(1+exp(-C*x) ))';
FT=fittype(templ,'coeff',{'a','b','C'});

fitL = fit(X(LeftTail),Y(LeftTail),FT,'start',[-1,0,1]);
fitR = fit(X(RightTail),Y(RightTail),FT,'start',[1,0,1]);

fnL = subs(templ,{'a','b','C'},{fitL.a,fitL.b,fitL.C});
fnR = subs(templ,{'a','b','C'},{fitR.a,fitR.b,fitR.C});

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
YRem = Y-YSL-YSR;

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


xx = linspace(Xasym(1),Xasym(end),1001);
%pp = splinefit(pot,sigma,10);
pp = splinefit(Xasym,Yasym,17);
yy_splinefit = ppval(pp,xx);

%%%%%%%%%%%%%%% Smoothing without asymptotic extrapolation

xx_noasymp = linspace(X(1),X(end),1001);
pp_noasymp = splinefit(X,Y,5);
yy_noasymp_splinefit = ppval(pp_noasymp,xx_noasymp);

capacitance_noasymp_gradient=gradient(yy_noasymp_splinefit,xx_noasymp);


pp_noasymp_10 = splinefit(X,Y,10);
yy_noasymp_splinefit_10 = ppval(pp_noasymp_10,xx_noasymp);

capacitance_noasymp_gradient_10=gradient(yy_noasymp_splinefit_10,xx_noasymp);

%%%%%%%%%%%%%%%


%Error estimation 

Y_data=[u_drop_0(:,1);u_drop_1(:,1);u_drop_2(:,1);u_drop_3(:,1);u_drop_4(:,1)];
X_data=[u_drop_0(:,2);u_drop_1(:,2);u_drop_2(:,2);u_drop_3(:,2);u_drop_4(:,2)];

total=[X_data , Y_data];
total_sorted=sortrows(total);

X_data=total_sorted(:,1);
Y_data=total_sorted(:,2);

%%%% Delete datapoints that are not reliable
%X_data(end-2:end,:)=[];
%X_data(1:3,:)=[];

%Y_data(end-2:end,:)=[];
%Y_data(1:3,:)=[];
%%%% END: Delete datapoints that are not reliable

[m,Nx] = size(X_data);
[m,N] = size(Y_data);

N=m;

Y_mean=ppval(pp,X_data);

plot(X_data,Y_mean,'r-',X_data,Y_data,'ko');
xlim([X_data(1) X_data(end)]);

% uncertainty of the curve fit

%Mean Value

X_mean=1/N * sum(X_data);

%Deviation

D_X(:,1)=X_data(:,1)-X_mean;

D_Y(:,1)=Y_data(:,1)-Y_mean;

%Standard error

%[D_Y , (D_Y'.^2)', sum(D_Y'.^2)' ]

S_Y=sqrt(1/(N-2) *sum(D_Y'.^2)');

S_xx=sum(X_data.^2) -(1/N) .* (sum(X_data)).^2
S_yy=sum(Y_data.^2) -(1/N) .* (sum(Y_data)).^2
S_xy=sum(X_data.*Y_data) -(1/N) .* (sum(X_data)).* (sum(Y_data))
%S_xx=(sum(Y_data'.^2) -(1/N) .* (sum(Y_data')).^2)' %not X_data

%Precision uncertainty 

s=sqrt(1/(N-2) * (S_yy - S_xy.^2/S_xx))

%Confidence interval 95 %
P_Y_mean= 1.967*s* sqrt(((1/N) + D_X.^2./S_xx ) );

%Prediction interval 95 %
P_Y= 1.967*s* sqrt( (1 + (1/N) + D_X.^2./S_xx ) );

Err_negative_upper=Y_mean(1)+P_Y_mean(1);
Err_negative_lower=Y_mean(1)-P_Y_mean(1);

Err_positive_upper=Y_mean(end)+P_Y_mean(end);
Err_positive_lower=Y_mean(end)-P_Y_mean(end);

%%%%%%%%%% Plot the potential drop

f = figure('XVisual',...
    '0x27 (TrueColor, depth 24, RGB mask 0xff0000 0xff00 0x00ff)');

set(gcf,'PaperUnits','centimeters')
%This sets the units of the current figure (gcf = get current figure) on paper to centimeters.
xSize = 8.6*2; ySize = 7.0; %For APS paper the recomended figure width equals the column width of the paper 8.6 cm (or 2 times 8.6 cm for long figures)
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

hold all;

%xlim([x(1) x(end)]);
xlim([SED_xlim_SED]);

legend_str=[];

hold on;

h2=plot(X_data(:,1),Y_data(:,1),'k.','Linewidth',0.5);
h1=plot(X_data,Y_mean,'r-','Linewidth',1);
h3=plot(X_data,Y_mean+P_Y_mean,'b-.','Linewidth',1);
h4=plot(X_data,Y_mean-P_Y_mean,'b-.','Linewidth',1);
%h5=plot(X_data,Y_mean+P_Y,'g-.','Linewidth',1);
%h6=plot(X_data,Y_mean-P_Y,'g-.','Linewidth',1);
h7=plot(y_potentialdrop(:,2),y_potentialdrop(:,3),'Color',[0 220 30]/255,'Linestyle',':','Linewidth',1);

hold off;

%legend([h2 h1 h3 h5],'Data points','Fit','CI (95 %)','PI (95 %)','Location','NorthWest');
legend([h2 h1 h3 h7],'Data points','Fit with theo. exp.','CI (95 %)','Fit with meas. exp.','Location','NorthWest');

xlabel(labels_potentialdrop(3,:),'FontSize',12);  % add axis labels and plot title
ylabel(labels_potentialdrop(1,:),'FontSize',12);

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

savename='SED_savename2_SED';
savename = strrep(savename, '.dat', '');
iResolution = 600;
print('-depsc2', sprintf('-r%d', iResolution), strcat(savename, '.eps'));
%fixPSlinestyle(strcat(savename, '.eps'),strcat(savename, '+fixed.eps'));
fixPSlinestyle(strcat(savename, '.eps'),strcat(savename, '.eps'));


%%%%%%%%%%%%%%%%%%%% Plot the capacitance curve

f = figure('XVisual',...
    '0x27 (TrueColor, depth 24, RGB mask 0xff0000 0xff00 0x00ff)');

set(gcf,'PaperUnits','centimeters')
%This sets the units of the current figure (gcf = get current figure) on paper to centimeters.
xSize = 8.6*2; ySize = 10.0; %For APS paper the recomended figure width equals the column width of the paper 8.6 cm (or 2 times 8.6 cm for long figures)
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

hold all;

%xlim([x(1) x(end)]);
xlim([SED_xlim_SED]);
ylim([0 14])

legend_str=[];

hold on;

xx=X_data(1:5:end,1);

h8=plot(xx_noasymp,capacitance_noasymp_gradient,'Color',[230 159 0]/255,'Linewidth',1);
h9=plot(xx_noasymp,capacitance_noasymp_gradient_10,'Color',[213 94 0]/255,'Linestyle','-.','Linewidth',1);
h1=plot(x_capacitance(:,1),y_capacitance(:,1),'r-','Linewidth',2);
%size(xx(1:end-1)+diff(xx)/2)
%size(diff(Y_mean(1:5:end,1)+P_Y_mean(1:5:end,1)))
%size(diff(xx))
%size(diff(Y_mean(1:5:end,1)+P_Y_mean(1:5:end,1))./diff(xx))
h5=plot(xx(1:end-1)+diff(xx)/2,diff(Y_mean(1:5:end,1)+P_Y_mean(1:5:end,1))./diff(xx),'b-.','Linewidth',1);
h6=plot(xx(1:end-1)+diff(xx)/2,diff(Y_mean(1:5:end,1)-P_Y_mean(1:5:end,1))./diff(xx),'b-.','Linewidth',1);
h7=plot(y_capacitance(:,2),y_capacitance(:,3),'Color',[0 220 30]/255,'Linestyle',':','Linewidth',1);

hold off;

%legend([h1 h5 h7 h8 h9],'Fit with theo. exp.','CI (95 %)','Fit with meas. exp.','No asymp. extrap. (5 interv. smoothing)','No asymp. extrap. (10 interv. smoothing)','Location','NorthOutside');

legend([h1 h5 h7 h8 h9],'Fit with theoretical exponent \lambda=0.5','Confidence interval (95 %)','Fit with measured exponent \lambda({\itT})','No asymptotic extrapolation (smoothing over 5 intervals)','No asymptotic extrapolation (smoothing over 10 intervals)','Location','NorthOutside');

xlabel(labels_capacitance(3,:),'FontSize',12);  % add axis labels and plot title
ylabel(labels_capacitance(1,:),'FontSize',12);

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

savename='SED_savename1_SED';
savename = strrep(savename, '.dat', '');
iResolution = 600;
print('-depsc2', sprintf('-r%d', iResolution), strcat(savename, '.eps'));
%fixPSlinestyle(strcat(savename, '.eps'),strcat(savename, '+fixed.eps'));
fixPSlinestyle(strcat(savename, '.eps'),strcat(savename, '.eps'));


quit;
