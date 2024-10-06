 function [Eb,Edump,diesel,t] = RunDieselGenerator(Pw,Pp,Eb,Ebmax,uinv,Pl,t,Pg,Edump,Edch,Ech,diesel,Ebmin)
%^^^^^^^^^^^^^^^RUN DIESEL GENERATOR ^^^^^^^^^^^^^^
         %LABEL RUN_DIESEL_GENERATOR

        %if Edch(t)<=((Pg*uinv+Pw(t)+Pp(t))-(Pl(t)/uinv))
            
            Eb(t)=Eb(t-1)+(Pg*uinv+Pw(t)+Pp(t)-((Pl(t)/uinv)*1));
            if Eb(t)>Ebmax     
            Edump(t)=Eb(t)-Ebmax;
            Eb(t)=Ebmax;
            end
            if Eb(t)<Ebmin
                Edump(t)=0;
                Eb(t)=Ebmin;
            end
            diesel(t)=Pg*uinv;
            %JUMP TO RUN DIESEL GENERATOR!!!
          %  return
       % end
            
 
 end