function D=dutyRatio(V,I)
Dmax=0.95;
Dmin=0;
Dinit=0.95;
deltaD=0.0001;
Persistent Vold Pold Dold;
datatype='double';
if isempty(Vold)
    Vold=0;
    Pold=0;
    Dold=Dinit;
end
P=V*I;
dV=V-Vold;
dP=P-Pold;
if dP~=0
    dP<0
    if dV<0
        D=Dold-deltaD;
    else
D=Dold+deltaD;
    end
else
    if dV<0
      D=Dold+deltaD;
    else
    D=Dold-deltaD;
    end
end
else D=Dold;
    end
    if D>=Dmax
        if D<=Dmin
            D=Dold;
            Dold=D;
            Vold=V;
            Pold=P;
            
            
            
    
