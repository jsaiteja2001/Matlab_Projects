clear all
clc
houses=15;
p_npv=45;
ad=3;
nwt=10;
nPng=1;
format bank

%% load inputs
shahr=input('select which city you want to analys/n 1.kerman 2.sistan 3.hamedan:')
if shahr==1
%% 3)load inputs RAFSANJAN/KERMAN
load('rafsanjan.mat');
load('WindTurbines.mat');
wind_speed=rafsanjan(:,1);[wind_speed]=min10tohourly(wind_speed);%hourly
temperature=rafsanjan(:,2);[temperature]=min10tohourly(temperature);%hourly
solar_radiation=rafsanjan(:,3)/1000;[solar_radiation]=min10tohourly(solar_radiation);%hourly%kw
clear rafsanjan
elseif shahr==2
%% 2)load inputs KHASH/SISTAN BALOCHESTAN
load('sistan_khash.mat');
load('WindTurbines.mat');
wind_speed=sistan_khash(:,1);[wind_speed]=min10tohourly(wind_speed);%hourly
temperature=sistan_khash(:,2);[temperature]=min10tohourly(temperature);%hourly
solar_radiation=sistan_khash(:,3)/1000;[solar_radiation]=min10tohourly(solar_radiation);%hourly%kw
clear sistan_khash
elseif shahr==3
%% 1)load inputs NAHAVAND
load('nahavand.mat');nahavand = circshift(nahavand,60);
load('WindTurbines.mat');
wind_speed=nahavand(:,1);[wind_speed]=min10tohourly(wind_speed);%hourly
temperature=nahavand(:,2);[temperature]=min10tohourly(temperature);%hourly
solar_radiation=nahavand(:,3)/1000;[solar_radiation]=min10tohourly(solar_radiation);%hourly%kw
clear nahavand
end
%% solar power
%#######inputs##############inputs####################inputs##
%ambient temperature-hararate mohit
tamb2=temperature;%temperature of nahavand on each hour;
%p_npv=7.3;%kW >>0.130w each pv,14 pv in string;%rated power at reference condition
g=solar_radiation;%hourly_solar_radiation_nahavand';%kW
%############################################################
gref=1 ;%1000kW/m^2
tref=25;%temperature at reference condition
kt=-3.7e-3;% temperature coefficient of the maximum power(1/c0)
tc=tamb2+(0.0256).*g;
upv=0.986;%efficiency of pv with tilted angle>>98.6%
p_pvout_hourly=upv*(p_npv.*(g/gref)).*(1+kt.*(tc-tref));%output power(kw)_hourly
clear tc
clear tamb2
clear g
%% battery 
%#######inputs##############inputs####################inputs##
%load demand >> hourly typical rural household load profile Kw
load1=[1.5 1 0.5 0.5 1 2 2 2.5 2.5 3 3 5 4.4 4 3.43 3 1.91 2.48 3 3 3.42 3.44 2.51 2];
load1=load1/5; load1=load1*2;% maximum would be 2kW mean is 1kW
%the load curve of a typical complete day's consumption, palestin case study
%load1=[1 1 1 1 1.5 2 2.5 2.5 1.5 1.5 1.5 2 2 2.5 2.5 3 3.5 4 4 3.5 2.5 1.5 1 1];
%houses=1;%number of houses in a village
load2=houses.*load1;%total load in a day for the whole village
%hourly load data for one year
a=0;
for i=1:1:360
     a=[a,load2];   
end
a(1)=[];
Pl1=a;
%ad=3;%daily autonomy
uinv=0.92;
ub=0.85;
dod=0.8;%depth of discharge 0.5 0.7 in the article 80%
el=mean(load2);
%bcap=40;%battery capacity 40 kWh
% ############################################################
cwh=(el*ad)/(uinv*ub*dod);%storage capacity for battery,bmax,kW

%% wind turbine
%#######inputs##############inputs####################inputs##
MCH=4;%choose the model>>model two
rw=cell2mat(WindTurbines(MCH,2));% rw=4;%blades diameter(m)
aw=cell2mat(WindTurbines(MCH,3));% aw=pi*(rw)^2;%Swept Area>>pi x Radius² = Area Swept by the Blades
uw=cell2mat(WindTurbines(MCH,4));% uw=0.95;%
vco=cell2mat(WindTurbines(MCH,5));% vco=25;%cut out
vci=cell2mat(WindTurbines(MCH,6));% vci=3;%cut in
vr=cell2mat(WindTurbines(MCH,7));% vr=8;%rated speed(m/s)
pr=cell2mat(WindTurbines(MCH,8));% pr=5;%rated power(kW)
pmax=cell2mat(WindTurbines(MCH,10));% % pmax=2.5;%maximum output power(kW)
pfurl=cell2mat(WindTurbines(MCH,9));% pfurl=2.5;%output power at cut-out speed9kW)
% ############################################################
v2=wind_speed;
%% diesel generator
Png=4;Png=nPng*Png;%kW output power of diesel generator
Bg=0.08145;%1/kW
Ag=0.246;%1/kW
Pg=4;Pg=nPng*Pg;%nominal power kW
% %fuel consumption of the diesel generator
Fg=Bg*Pg+Ag*Png;
%% MAIN PROGRAM
contribution=zeros(5,8640);%pv,wind, battery, diesel contribution in each hour
Ebmax=cwh;%40kWh%battery capacity 40 kWh
Ebmin=cwh*(1-dod);%40kWh
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

for i=1:1:8640
    if Pp(i)>p_npv
        Pp(i)=p_npv;%if the power output of pv  exceed the maximum
    end
end
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
Pw(t)=pwtg(t)*uw*nwt;%electric power from wind turbine
end
 
for t=2:1:8640
%^^^^^^^^^^^^^^READ INPUTS^^^^^^^^^^^^^^^^^^

%^^^^^^^^^^^^^^COMPARISON^^^^^^^^^^^^^^^^^^^
if Pw(t)+Pp(t)>=(Pl(t)/uinv)
    %^^^^^^RUN LOAD WITH WIND TURBINE AND PV^^^^^^
     
    if Pw(t)+Pp(t)>Pl(t)
        %^^^^^^^^^^^^^^CHARGE^^^^^^^^^^^^^^^^^^^^^^^^^^
        
       [Edump,Eb,Ech] = charge(Pw,Pp,Eb,Ebmax,uinv,Pl,t,Edump,Ech); 
       time1(t)=1;
      contribution(1,t)=Pp(t);contribution(2,t)=Pw(t);contribution(3,t)=Edch(t);contribution(4,t)=diesel(t);contribution(5,t)=Edump(t);
    else
        Eb(t)=Eb(t-1);
        return
    end
    
else
   %^^^^^^^^^^^^^^DISCHARGE^^^^^^^^^^^^^^^^^^^
   [Eb,Edump,Edch,diesel,time1,t] = dicharge(Pw,Pp,Eb,Ebmax,uinv,Pl,t,Pg,Ebmin,Edump,Edch,Ech,diesel,time1);
    contribution(1,t)=Pp(t);contribution(2,t)=Pw(t);contribution(3,t)=Edch(t);contribution(4,t)=diesel(t);contribution(5,t)=Edump(t);

end



end
%% plotting

% figure
a=contribution';
b=sum(a);
renewable_factor=b(4)/(b(1)+b(2)+b(3));
% h=pie(b);
% colormap jet;
% legend('PV','WIND','BATTERY','DIESEL');

%reliability
%lose of load probability=sum(load-pv-wind+battery)/sum(load)
total_loss=0;
for t=1:1:8640
%     aa(t)=Pl(t)-Pp(t)-Pw(t)+Eb(t);
    if Pl(t)>(Pp(t)+Pw(t)+(Eb(t)-Ebmin)+diesel(t))
       total_loss=total_loss+(Pl(t)-(Pp(t)+Pw(t)+(Eb(t)-Ebmin)+diesel(t)));
    end
    
end
LPSP=total_loss/(sum(Pl));
% reliability=sum(aa)/sum(Pl);
% [price_electricity] = economic(diesel,Pl,Fg,cwh);
 timming=720;
  ali=[Pp(1:timming)',Pw(1:timming)',Eb(1:timming)',diesel(1:timming)',Pl(1:timming)',Edump(1:timming)'];
 Edump=sum(Edump);
 [price_electricity] = economic_fast_iran(diesel,Pl,Fg,cwh,p_npv,nwt);
  
format bank
result=[p_npv,ad,houses,nwt,LPSP,price_electricity,renewable_factor,b(1),b(2),b(3),b(4),b(5)];
%bar(result)
%legend('pv(kW)','days of autonomy','number of houses','number of wind turbines','PV','WIND','BATTERY','DIESEL','loss of load probability','price of electricity($/kW)','renewable factor')

 figure,subplot(2,1,1),x=1:timming;bar(ali(:,1:4),'stacked');colormap jet,legend('PV','WIND','BATTERY','DIESEL');
 subplot(2,1,2),x=1:timming;bar(ali(:,5:6),'stacked');colormap jet,legend('Demanded LOAD','DUMP LOAD');
  

  LPSP_matrix(houses,p_npv)=LPSP;
price_electricity_matrix(houses,p_npv)=price_electricity;  
  
    
%     end
% end

 
%  p_npv
% ad
% houses
% nwt
% LPSP
% price_electricity
% renewable_factor