X=[100 100 100
   100 100 100
   100 100 100];
% X is the variable the represents the number of Confederate troops
% (rows=zones, columns = troop type (riflemen, artillery, cavalry))
Y=[200 5 0];
% Y is the variable for the number of Union riflemen and Artillery
B=[0 0 0
   1 1 1
   1 1 1];
% B is the maximum flow rate between zones for a given unit. The top row
% for B is zero
C=[0 0 0
   1 1 1
   1 1 1];
% C is the choice variable matrix for the flow rates stated above. Entries
% in C range from -1 to 1. The top row for C is zero. 
D=[.1 .2 .3
   .1 .2 .3
   .1 .2 .3];
% D is the effectiveness of Union riflemen killing Confederate troops
% (row = zone, column = troop type)
E=[1 1 1
   1 1 1
   1 1 1];
% E is the effectiveness of Union Artillery killing Confederate troops
% (row = zone, column = troop type)
F=[.01 .01 .01
   .01 .01 .01
   .01 .01 .01];
% F is the effectiveness of Confederate troops (row = zone, column = troop type) killing Union Riflemen
S=[1 1 1
   1 1 1
   1 1 1];
% S is the survival rate from Transfer of Troops
time=1;
clear Xplot
Xplot(:,:,time)=X;
clear Yplot
Yplot(:,:,time)=Y;
while (Y(1,1)>0 && sum(sum((X))>0))
    % Transfer of Troops
    for ii=2:3
        for jj=1:3
                    if(B(ii,jj)*C(ii,jj)>0)
                        if(X(1,jj)<B(ii,jj)*C(ii,jj))
                            X(ii,jj)=X(ii,jj)+S(ii,jj)*X(1,jj);
                            X(1,jj)=0;
                        else
                           X(1,jj)=X(1,jj)-B(ii,jj)*C(ii,jj);
                           X(ii,jj)=X(ii,jj)+S(ii,jj)*B(ii,jj)*C(ii,jj);
                        end
                    else
                        if(X(ii,jj)<-B(ii,jj)*C(ii,jj))
                            X(1,jj)=X(1,jj)+S(ii,jj)*X(ii,jj);
                            X(ii,jj)=0;
                        else
                           X(1,jj)=X(1,jj)-S(ii,jj)*B(ii,jj)*C(ii,jj);
                           X(ii,jj)=X(ii,jj)+B(ii,jj)*C(ii,jj);
                        end
                    end      
        end
    end

    % Combat (temporary variables for simultaneous battle)
    Xnew=floor(X-D.*(ones(3)*Y(1,1))-E*(ones(3)*Y(1,2)));
    Ynew=floor(Y(1,1)-sum(sum(F*X)));
    % Set values under 0 equal to 0
    for ii=1:3
        for jj=1:3
            if Xnew(ii,jj)<0
                Xnew(ii,jj)=0;
            end
        end
    end
    if Ynew(1,1)<1
           Ynew(1,1)=0;
    end
    % Assign final values
    X=Xnew;
    Y(1,1)=Ynew;
    time=time+1;
    Xplot(:,:,time)=X;
    Yplot(:,:,time)=Y;
end

PlotTotalTroopsAcrossTime(Xplot,1:time);
PlotTroopsAcrossZones(Xplot,1:time);

