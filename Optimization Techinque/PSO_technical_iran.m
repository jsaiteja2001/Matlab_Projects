clear all
close all
clc
%% Problem definition
%hade bala
C=1.5;%cost
W=0.11;%lose of load probability%
K=0.99;%renewable energy factor%
nvars=1;%only one system
LB=[0 0 1 0 0]; % Lower bound of problem
UB=[45 6 20 10 4]; % Upper bound of problem
%%
max_it=40;%100;% Maximum number of iterations
NPOP=5;%20;% Number of population
% Determine the maximum step for velocity
for d=1:5
    if LB(d)>-1e20 && UB(d)<1e20
        velmax=(UB(d)-LB(d))/NPOP;
    else
        velmax=inf;
    end
end
%% PSO initial parameters

% w=0.5;                        % Inertia weight
% wdamp=0.99;                   % Inertia weight damping ratio
% c1=2;                         % Personal learning coefficient
% c2=2;                         % Global learning coefficient
phi1=2.05;
phi2=2.05;
phi=phi1+phi2;
chi=2/(phi-2+sqrt(phi^2-4*phi));

w1=chi;                                 % Inertia weight
%wdamp=1;                               % Inertia weight damping ratio
c1=chi*phi1;                           % Personal learning coefficient
c2=chi*phi2;                           % Global learning coefficient

%% Initialization
tic
empty_particle.position=[];
empty_particle.velocity=[];
empty_particle.dump=[];
empty_particle.renewable_factor=[];

empty_particle.best.position=[];
empty_particle.best.dump=[];
empty_particle.best.renewable_factor=[];
%---------
particle=repmat(empty_particle,NPOP,1);
globalbest.dump=inf;
globalbest.renewable_factor=inf;
globalbest.position=[];
%rnwfct_best=inf;
for i=1:NPOP
    ccc=2;%a value for cost
    ww=0.3;% a value for lose of load probability%
    kkk=2;%renewable energy factor%
    ff=0;
%C=0.9;%price of electricity
%W=0.2;%lose of load probability%
%K=0.99;%renewable energy factor%
while  ww>=W%kkk>=K % LOLP/REfactor
        particle(i).position(1,:)=unifrnd(0,45,1,nvars);%pv kW
        particle(i).position(2,:)=unifrnd(0,6,1,nvars);%autonomy days
        particle(i).position(3,:)=unifrnd(1,20,1,nvars);%number of houses
        particle(i).position(4,:)=unifrnd(0,10,1,nvars);%number of wind turbine
        particle(i).position(5,:)=unifrnd(0,4,1,nvars);%number of diesel generators
        for g=1:5
            particle(i).velocity(g,:)=rand(1,nvars);
        end
        %----convert------------
        p_npv=particle(i).position(1);
        ad=particle(i).position(2);
        houses=round(particle(i).position(3));
        nwt=round(particle(i).position(4));
        nPng=round(particle(i).position(5));
        %-----------------------
        [LPSP,price_electricity,renewable_factor,b,ali,Edump]=techno_economic_analysis_pso(houses,p_npv,ad,nwt,nPng);
        ff=ff+1;
        
        ww(i)=LPSP;
        kkk(i)=renewable_factor;
        ccc(i)=price_electricity;
end
    
    particle(i).dump=Edump;
    particle(i).renewable_factor=renewable_factor;
    particle(i).best.position=particle(i).position;
    particle(i).best.dump=particle(i).dump;
    particle(i).best.renewable_factor=particle(i).renewable_factor;
    
    if particle(i).best.dump<globalbest.dump & particle(i).best.renewable_factor<globalbest.renewable_factor
        globalbest=particle(i).best;
        
    end
end
Fminn=zeros(max_it,1);
%% PSO main loop
% disp('Iteration         Reliability');
% disp('-----------------------------');
for u=1:max_it
    vv=0;
    for i=1:NPOP
        price_electricity=2;%price of electricity
        LPSP=0.3;% a value for lose of load probability%
        renewable_factor=2;%
        bb=0;
%C=0.9;%price of electricity
%W=0.2;%lose of load probability%
%K=0.99;%renewable energy factor%

%         ww=0.3*100;% a value for lose of load probability%
%         kkk=2*100;%renewable energy factor%
        while LPSP>=W %(renewable_factor)>=K 
            
            for y=1:5
                particle(i).velocity(y,:)=w1*particle(i).velocity(y,:)+c1*rand*...
                    (particle(i).best.position(y,:)-particle(i).position(y,:))...
                    +c2*rand*(globalbest.position(y,:)-particle(i).position(y,:));
                
                %particle(i).velocity(y,:)=min(max(particle(i).velocity(y,:),-velmax),velmax);
                
                particle(i).position(y,:)=particle(i).position(y,:)+particle(i).velocity(y,:);
                
                % flag=(particle(i).position(kk,:)<LB(kk) | particle(i).position(kk,:)>UB(kk));
                % particle(i).velocity(flag)=-particle(i).velocity(flag);
                particle(i).position(y,:)=min(max(particle(i).position(y,:),LB(y)),UB(y));
                
            end
            %p_npv(i,:)=round(particle(i).position(1,:));
            oo=0;
            %ad(i,:)=round(particle(i).position(2,:));
            p_npv=round(particle(i).position(1));
            ad=round(particle(i).position(2));
            houses=round(particle(i).position(3));
            nwt=round(particle(i).position(4));
            nPng=round(particle(i).position(5));
            %[cc ww]=constraints(c,w,nnn(i,:),zz(i,:),zmax,nmax,N);
            [LPSP,price_electricity,renewable_factor,b,ali,Edump]=techno_economic_analysis_pso(houses,p_npv,ad,nwt,nPng);

            bb=bb+1;
            
        end
        %----convert------------
%         az(i,:)=round(particle(i).position(1,:));
%         z(i,:)=round(particle(i).position(2,:));
%         n(i,:)=round(particle(i).position(3,:));
        %         sol(i).pos(1,:)=round(particle(i).position(1,:));
        %         sol(i).pos(2,:)=round(particle(i).position(2,:));
%         sol(i).pos(3,:)=round(particle(i).position(3,:));
            
        %-----------------------
        %[LPSP,price_electricity,renewable_factor]=techno_economic_analysis_pso(houses,p_npv,ad,nwt);
        particle(i).dump=Edump;
        particle(i).renewable_factor=renewable_factor;
        %rnwfct=renewable_factor;
        %particle(i).cost=objective_function(sol(i).pos);
        vv=vv+1;
        if particle(i).renewable_factor<particle(i).best.renewable_factor & particle(i).dump<particle(i).best.dump 
            particle(i).best.dump=particle(i).dump;
            particle(i).best.renewable_factor=particle(i).renewable_factor;
            particle(i).best.position=particle(i).position;
            if particle(i).best.dump<globalbest.dump & particle(i).best.renewable_factor<globalbest.renewable_factor %& rnwfct<rnwfct_best
                globalbest=particle(i).best;
               % rnwfct_best=rnwfct;
            end
        end
        
    end
    
    Fminn(u)=globalbest.dump;
    Xmin=globalbest.position;
    p_npv=round(globalbest.position(1));
    ad=round(globalbest.position(2));
    houses=round(globalbest.position(3));
    nwt=round(globalbest.position(4));
    nPng=round(globalbest.position(5));
    % w=wdamp*w;
  % disp(['Iteration ',num2str(u),': Best cost= ',num2str(Fminn(u))]);
end
Time=toc;

%% Results
close all;
% figure;
% plot(Fminn,'Linewidth',3);
% ylabel('price of electricity');
% xlabel('Number of iterations');
% ylim([0 0.4])
% xlim([1 max_it ])
Fmin=min(Fminn);
Xmin;
[LPSP,price_electricity,renewable_factor,b,ali,Edump]=techno_economic_analysis_pso(houses,p_npv,ad,nwt,nPng);
format long
result=[p_npv,ad,houses,nwt,LPSP,price_electricity,renewable_factor,b(1),b(2),b(3),b(4),b(5)];
 %bar(result)
% legend('pv(kW)','days of autonomy','number of houses','number of wind turbines','PV','WIND','BATTERY','DIESEL','loss of load probability','price of electricity($/kW)','renewable factor')

 figure,subplot(2,1,1),x=1:168;bar(x,ali(:,1:4),'group');colormap jet,subplot(2,1,2),x=1:168;bar(x,ali(:,5:6),'group');colormap jet
p_npv
ad
houses
nwt
nPng
LPSP
price_electricity
renewable_factor
contribution=0
PV=b(1)
WIND=b(2)
BATTERY=b(3)
DIESEL=b(4)
load=b(5)