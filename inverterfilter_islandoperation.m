%Inverter filter calculation
Tss=2.5e-6;
P=10e3;
U=380;
f=50;
fsw=5e3;
Cfmax=(0.05*P)/(2*pi*f*U^2); %11uF
Lf=(0.1*U^2)/(2*pi*f*P);%4.6mH
RLf=Lf*100;

