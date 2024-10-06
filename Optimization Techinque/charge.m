function [Edump,Eb,Ech] = charge(Pw,Pp,Eb,Ebmax,uinv,Pl,t,Edump,Ech)
 %^^^^^^^^^^^^^^CHARGE^^^^^^^^^^^^^^^^^^^^^^^^^^
        Pch(t)=(Pw(t)+Pp(t))-(Pl(t)/uinv);
        Ech(t)=Pch(t);%*1;%one hour iteration time
        if Ech(t)<=Ebmax-Eb(t)
            Eb(t)=Eb(t-1)+Ech(t);
            
            if Eb(t)>Ebmax%khodam
                    Eb(t)=Ebmax;
                    Edump(t)=Ech(t)-(Ebmax-Eb(t));
            else
                    Edump(t)=0;
            end%khodam
            return
        else
            Eb(t)=Ebmax;
            Edump(t)=Ech(t)-(Ebmax-Eb(t));
            return
        
        end
end