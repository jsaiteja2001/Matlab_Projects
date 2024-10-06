%sensivity analysis on pv
%% solar power
clear all
close all
clc
for p_npv=4:1:12
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
%p_npv=7.3;%kW >>0.130w each pv,14 pv in string;%rated power at reference condition
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
%% diesel generator
Png=4;%nominal power kW
Bg=0.08145;%1/kW
Ag=0.246;%1/kW
Pg=4;%kW output power of diesel generator
% %fuel consumption of the diesel generator
Fg=Bg*Png+Ag*Pg;
%% MAIN PROGRAM
contribution=zeros(4,8640);%pv,wind, battery, diesel contribution in each hour
Ebmax=40;%40kWh%battery capacity 40 kWh
Ebmin=40*(1-dod);%40kWh
SOCb=0.2;%state of charge of the battery>>20%
Eb=zeros(1,8640);
time1=zeros(1,8640);
diesel=zeros(1,8640);
Edump=zeros(1,8640);
Edch=zeros(1,8640);
Ech=zeros(1,8640);
diesel_power=zeros(1,8640);
Eb(1,1)=SOCb*Ebmax;%state of charge for starting time
%^^^^^^^^^^^^^^START^^^^^^^^^^^^^^^^^^^^^^^^
Pl=Pl1;
clear Pl1;
%^^^^^^^^^^Out put power calculation^^^^^^^^
%solar power calculation
Pp=p_pvout_hourly;%output power(kw)_hourly
for i=1:1:8640
    if Pp(i)>p_npv
        Pp(i)=p_npv;%if the power output of pv  exceed the maximum
    end
end
Pp_mean=mean(Pp);
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
Pw_mean=mean(Pw);

 
for t=2:1:8640
%^^^^^^^^^^^^^^READ INPUTS^^^^^^^^^^^^^^^^^^

%^^^^^^^^^^^^^^COMPARISON^^^^^^^^^^^^^^^^^^^
if Pw(t)+Pp(t)>=(Pl(t)/uinv)
    %^^^^^^RUN LOAD WITH WIND TURBINE AND PV^^^^^^
     
    if Pw(t)+Pp(t)>Pl(t)
        %^^^^^^^^^^^^^^CHARGE^^^^^^^^^^^^^^^^^^^^^^^^^^
       [Edump,Eb,Ech] = charge(Pw,Pp,Eb,Ebmax,uinv,Pl,t,Edump,Ech); 
       time1(t)=1;
      contribution(1,t)=Pp(t);contribution(2,t)=Pw(t);contribution(3,t)=Edch(t);contribution(4,t)=diesel(t);
    else
        Eb(t)=Eb(t-1);
        contribution(1,t)=Pp(t);contribution(2,t)=Pw(t);contribution(3,t)=Edch(t);contribution(4,t)=diesel(t);
        return
    end
    
else
   %^^^^^^^^^^^^^^DISCHARGE^^^^^^^^^^^^^^^^^^^
   [Eb,Edump,Edch,diesel,time1,t] = dicharge(Pw,Pp,Eb,Ebmax,uinv,Pl,t,Pg,Ebmin,Edump,Edch,Ech,diesel,time1);
    contribution(1,t)=Pp(t);contribution(2,t)=Pw(t);contribution(3,t)=Edch(t);contribution(4,t)=diesel(t);
end



end
%% plotting

%         figure
%         plot(Eb,'DisplayName','Eb','YDataSource','Eb');figure(gcf)
% 
%         figure
%         plot(Edump,'DisplayName','Edump','YDataSource','Edump');figure(gcf)
% 
%         figure
%         plot(diesel,'DisplayName','diesel','YDataSource','diesel');figure(gcf)
% 
%         figure
%         %mean solar power output during the day
%         [averagedaysolar]=HourlytoDaily(Pp);
%         x=0.5:1:24.5;
%         bar(averagedaysolar);figure(gcf);xlim([0.5 24.5]);ylabel('Power(kW)');title('average daily output power from pv');

% figure
% %mean solar power output during the months
% [averagedaysolar]=Hourlytomonthly(Pp);
% x=0.5:1:12.5;
% bar(averagedaysolar);figure(gcf);xlim([0.5 12.5]);ylabel('Power(kW)');title('average daily output power from pv');
% colormap winter
%         figure
%         %mean solar power output during the day
%         [averagedaywind]=HourlytoDaily(Pw);
%         x=0.5:1:24.5;
%         bar(averagedaywind);figure(gcf);xlim([0.5 24.5]);xlabel('hours');ylabel('Power(kW)');title('average daily output power from wind turbine');

%         figure
%         hist(time1);figure(gcf);
% 
%         figure
         a=contribution';
         b=sum(a);
%         h=pie(b);
%         colormap jet;
%         legend('PV','WIND','BATTERY','DIESEL');

%reliability
k=0;
for t=1:1:8640

    if Pl(t)>(Pp(t)+Pw(t)+Edch(t)+diesel(t))
        k=k+1;
    end
    
end
reliability=k/8640;
%[price_electricity] = economic(diesel,Pl,Fg,p_npv);
[price_electricity] = economic_fast(diesel,Pl,Fg,cwh,p_npv);
prc(p_npv,1)=price_electricity;
prc(p_npv,2)=reliability;
prc(p_npv,3)=b(1);%pv contribution
prc(p_npv,4)=b(2);%wind contribution
prc(p_npv,5)=b(3);%battery contribution
prc(p_npv,6)=b(4);%diesel contribution

 ali=[Pp(1:168)',Pw(1:168)',Edch(1:168)',diesel(1:168)'];
end

