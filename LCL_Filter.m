%Filter system parameters
Pn=50000;%inverter power
En=230;
Vdc=800;
fn=50;
fsw=1000;
wn=2*pi*fn
%Base values
Zb=(En^2)/Pn
Cb=1/(wn*Zb)
%Filter parameters
delta_Ilmax=0.1*((Pn*sqrt(2))/En);
Li=3*Vdc/(16*fsw*delta_Ilmax)
x=0.05;
Cf=x*Cb
%calculation of factor,r, between Linv and Lg
r=0.6;
Lg=3*r*Li
wres=sqrt((Li+Lg)/(Li*Lg*Cf))
fres=wres/(2*pi)
Rd=1/(3*wres*Cf)% damping resistance