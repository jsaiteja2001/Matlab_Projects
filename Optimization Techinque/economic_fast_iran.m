function [price_electricity] = economic_fast(diesel,Pl,Fg,cwh,p_npv,nwt,houses)
% initial cost
WT_C=2000;
PV_C=3400;
BAT_C=280;
DSL_C=1000;
INV_C=2500;
PV_reg=1500;
Wind_reg=1000;
%economic index
REAL_INTREST=12;
%life time
WT_LF=24;
PV_LF=24;
BAT_LF=12;
DSL_LF=24000;
INV_LF=24;
PRJ_LF=24;
%running cost
OM=20;
%rated power
WT_P=2;
%PV_P=7.3;
PV_P=p_npv;%for sensivity analysis for pv
BAT_P=cwh;%for sensivity analysis for autonomy days
DSL_P=4;
%% economic analysis
%diesel*************************A*************************************8
[i,j,k]=find(diesel);
 k=sum(k/4);%4 is because i set diesel on 4 when it will be turn on
 fuel_consumption=Fg*k;%feul consuption in one year for diesel
 k=DSL_LF/k;%year life time
 if k<PRJ_LF
     n=floor(PRJ_LF/k);%n is number of repalcement for diesel in project life time
     price_d=DSL_C*DSL_P*n; 
else
    k_d=PRJ_LF;
    price_d=DSL_C*DSL_P;
 end
 
 %battery************A**************A*********************A************************
k=floor(PRJ_LF/BAT_LF);
price_b=BAT_C*BAT_P*k;
% economic analysis
i=REAL_INTREST/100;%real interest rate=monetary interest rate-rate of inflation
initial_cost=WT_C*WT_P*nwt+PV_C*PV_P+price_b+price_d+INV_C+PV_reg+Wind_reg;
OM=initial_cost*(OM/100);
initial_cost=initial_cost+OM;%addind operation and maintanence cost

Anual_cost=initial_cost*((i*(1+i)^PRJ_LF)/(((1+i)^PRJ_LF)-1));

i=REAL_INTREST/100;%feul real interest rate=monetary interest rate-rate of inflation
Anual_cost_fuel=fuel_consumption*PRJ_LF*((i*(1+i)^PRJ_LF)/(((1+i)^PRJ_LF)-1));
Anual_cost=Anual_cost+Anual_cost_fuel;
Anual_load=sum(Pl);
price_electricity=Anual_cost/Anual_load;
end