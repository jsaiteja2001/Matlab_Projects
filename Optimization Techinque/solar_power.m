%% solar power
clear all
close all
clc
%#######inputs##############inputs####################inputs##
%monthly solar radiation Mersing,malaysia
%g=[4.12,4.97,5.02,5.08,4.84,4.66,4.61,4.7,4.83,4.7,4.05,3.62] ;%solar radiation(kW/m^2)
tamb=[25.50 25.70 26.10 26.50 26.60 26.30 26.00 26.00 26.10 26.30 26.10 25.70];%ambient temperature-hararate mohit

a=0;
for i=1:1:12
    for k=1:1:720
    b(k)=tamb(i);
    end 
    a=[a,b];
end
clear b
a(1)=[];
tamb2=a;
p_npv=7.3;%kW >>0.130w each pv,14 pv in string;%rated power at reference condition
%hourly real solar radiation malaysia
load('malaysia_solar_hourly_realdata.mat');
g=hourly_solar_radiation_malaysia';%kW
%############################################################
gref=1 ;%1000kW/m^2
tref=25;%temperature at reference condition
kt=-3.7e-3;% temperature coefficient of the maximum power(1/c0)
tc=tamb2+(0.0256).*g;
p_pvout_hourly=(p_npv.*(g/gref)).*(1+kt.*(tc-tref));%output power(kw)_hourly
clear tc
clear tamb2
clear g
%% battery 
%#######inputs##############inputs####################inputs##
%load demand >> hourly typical rural household load profile Kw
load1=[1.5 1 0.5 0.5 1 2 2 2.5 2.5 3 3 5 4.4 4 3.43 3 1.91 2.48 3 3 3.42 3.44 2.51 2];
%the load curve of a typical complete day's consumption, palestin case study
%load1=[1 1 1 1 1.5 2 2.5 2.5 1.5 1.5 1.5 2 2 2.5 2.5 3 3.5 4 4 3.5 2.5 1.5 1 1];
houses=1;%number of houses in a village
load2=houses.*load1;%total load in a day for the whole village
%hourly load data for one year
a=0;
for i=1:1:360
     a=[a,load2];   
end
a(1)=[];
Pl1=a;

ad=3;%daily autonomy
uinv=0.92;
ub=0.85;
dod=0.8;%depth of discharge 0.5 0.7 in the article 80%
el=mean(load2);
bcap=40;%battery capacity 40 kWh
% ############################################################
cwh=(el*ad)/(uinv*ub*dod);%storage capacity for battery,bmax,kW

%% wind turbine
%#######inputs##############inputs####################inputs##
load('hourly2009_30_2.mat');
load('WindTurbines.mat')
v1=hourly2009_30;
h2=70;
h0=43.6;
MCH=3;%choose the model>>model one
rw=cell2mat(WindTurbines(MCH,2));% rw=6.4;%blades diameter(m)
aw=cell2mat(WindTurbines(MCH,3));% aw=pi*(rw)^2;%Swept Area>>pi x Radius² = Area Swept by the Blades
uw=cell2mat(WindTurbines(MCH,4));% uw=0.95;%
vco=cell2mat(WindTurbines(MCH,5));% vco=40;%cut out
vci=cell2mat(WindTurbines(MCH,6));% vci=2.5;%cut in
vr=cell2mat(WindTurbines(MCH,7));% vr=9.5;%rated speed(m/s)
pr=cell2mat(WindTurbines(MCH,8));% pr=5;%rated power(kW)
 alfa=0.25;%for heavily forested landscape
pmax=cell2mat(WindTurbines(MCH,10));% % pmax=;%maximum output power(kW)
pfurl=cell2mat(WindTurbines(MCH,9));% pfurl=4;%output power at cut-out speed9kW)
% ############################################################
v2=((h2/h0)^(alfa))*v1;

% %weilbull distribution
% f=find(hourly2009_30<=0);
% hourly2009_30(f)=[]; 
% binWidth =0.2;
% binCtrs = 1:binWidth:12;
% h = get(gca,'child');
% set(h,'FaceColor',[.98 .98 .98],'EdgeColor',[.94 .94 .94]);
% counts = hist(hourly2009_30,binCtrs);
% %[parmhat,parmci] = wblfit(data) returns 95% confidence intervals for the 
% %estimates of a and b in the 2-by-2 matrix parmci. 
% %The first row contains the lower bounds of the confidence intervals for
% %the parameters, and the second row contains the upper bounds of the 
% %confidence intervals.
% %[PARMHAT,PARMCI] = WBLFIT(X,ALPHA) returns 100(1-ALPHA) percent
% %confidence intervals for the parameter estimates.
% paramEsts = wblfit(hourly2009_30);
% n = length(hourly2009_30);
% prob = counts / (n * binWidth);
% bar(binCtrs,prob,'hist');
% h = get(gca,'child');
% set(h,'FaceColor',[.9 .9 .9]);
% xlabel('Wind speed(m/s)'); ylabel('Probability Density');xlim([0 10]);
% xgrid = linspace(0,9,1000);
% pdfEst = wblpdf(xgrid,paramEsts(1),paramEsts(2));
% line(xgrid,pdfEst)

%% diesel generator
Png=4;%nominal power kW
Bg=0.08145;%1/kW
Ag=0.246;%1/kW
Pg=4;%kW output power of diesel generator
% %fuel consumption of the diesel generator
Fg=Bg*Png+Ag*Pg;
%% MAIN PROGRAM

Ebmax=40;%40kWh%battery capacity 40 kWh
Ebmin=40*(1-dod);%40kWh
SOCb=0.2;%state of charge of the battery>>20%
Eb=zeros(1,8640);
time1=zeros(1,8640);
diesel=zeros(1,8640);
Edump=zeros(1,8640);
Edch=zeros(1,8640);
Ech=zeros(1,8640);
Eb(1,1)=SOCb*Ebmax;%state of charge for starting time
%^^^^^^^^^^^^^^START^^^^^^^^^^^^^^^^^^^^^^^^
Pl=Pl1;
clear Pl1;
%^^^^^^^^^^Out put power calculation^^^^^^^^
%solar power calculation
Pp=p_pvout_hourly;%output power(kw)_hourly
% wind power calculation
for t=1:1:8640
    %pr *((v2(t)-vci)/(vr-vci))^3pr+(((pfurl-pr)/(vco-vr))*(v2(t)-vr));
if v2(t)<vci %v2>>hourly_wind_speed;
        pwtg(t)=0;
    elseif vci<=v2(t)&& v2(t)<=vr
        pwtg(t)=(pr/(vr^3-vci^3))*(v2(t))^3-(vci^3/(vr^3-vci^3))*(pr);
    elseif vr<=v2(t) &&v2(t)<=vco
        pwtg(t)=pr;
    else 
        pwtg(t)=0;
end
Pw(t)=pwtg(t)*uw;%electric power from wind turbine
end
for t=2:1:8640
%^^^^^^^^^^^^^^READ INPUTS^^^^^^^^^^^^^^^^^^
if Pp(t)>p_npv
    Pp(t)=p_npv;%if the power output of pv  exceed the maximum
end
%^^^^^^^^^^^^^^COMPARISON^^^^^^^^^^^^^^^^^^^
if Pw(t)+Pp(t)>=(Pl(t)/uinv)
    %^^^^^^RUN LOAD WITH WIND TURBINE AND PV^^^^^^
     
    if Pw(t)+Pp(t)>Pl(t)
        %^^^^^^^^^^^^^^CHARGE^^^^^^^^^^^^^^^^^^^^^^^^^^
        
       [Edump,Eb,Ech] = charge(Pw,Pp,Eb,Ebmax,uinv,Pl,t,Edump,Ech); 
       time1(t)=1;
    else
        Eb(t)=Eb(t-1);
        return
    end
    
else
   %^^^^^^^^^^^^^^DISCHARGE^^^^^^^^^^^^^^^^^^^
   [Eb,Edump,Edch,diesel,time1] = dicharge(Pw,Pp,Eb,Ebmax,uinv,Pl,t,Pg,Ebmin,Edump,Edch,Ech,diesel,time1);
    
end



end
% figure
% subplot(2,3,1)
% plot(Eb,'DisplayName','Eb','YDataSource','Eb');figure(gcf)
% subplot(2,3,2)
% plot(Edump,'DisplayName','Edump','YDataSource','Edump');figure(gcf)
% subplot(2,3,3)
% plot(diesel,'DisplayName','diesel','YDataSource','diesel');figure(gcf)
% subplot(2,3,4)
% plot(Pw,'DisplayName','Pw','YDataSource','Pw');figure(gcf)
% subplot(2,3,5)
% plot(Pp,'DisplayName','Pp','YDataSource','Pp');figure(gcf)
% subplot(2,3,6)
% hist(time1);figure(gcf);
figure
plot(Eb,'DisplayName','Eb','YDataSource','Eb');figure(gcf)
figure
plot(Edump,'DisplayName','Edump','YDataSource','Edump');figure(gcf)
figure
plot(diesel,'DisplayName','diesel','YDataSource','diesel');figure(gcf)
figure
plot(Pw,'DisplayName','Pw','YDataSource','Pw');figure(gcf)
figure
plot(Pp,'DisplayName','Pp','YDataSource','Pp');figure(gcf)
figure
hist(time1);figure(gcf);

[price_electricity] = economic(diesel,Pl,Fg);
