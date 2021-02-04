function [Q]=SpectraleigQ(Traindata,J_sepctral,eta,d,L,maxmin)
L=L+(0.0001.*eyes(size(L)));%Regularization
[evcs, evls] = eig(J_sepctral,L);

if(maxmin==0)%Minimise
    factor=+1; %Ascending
else %Maximise
    factor =-1; %Descending
end

evls = diag(evls);     if isreal(evls)==0,    evcs = abs(evcs);  evls = abs(evls);end
evls(isinf(evls))=0.0; evls(isnan(evls))=0.0; evcs(isinf(evcs))=0.0; evcs(isnan(evcs))=0.0;

index = evls<10^-6;
evls(index)=[];
evcs(:,index)=[];
[~, index] = sort(factor*evls);
evls = evls(index);%Just for future debugging
s_evcs = evcs(:,index);%

T=s_evcs(:,1:d);
etaI=eta*eye(size(Traindata*Traindata',2));
W = pinv((Traindata*Traindata')+etaI)*(Traindata*T);
Q = W';
end
