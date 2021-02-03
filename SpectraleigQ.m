function [Q]=SpectraleigQ(Traindata,J_sepctral,eta,d,L,maxmin)

[evcs, evls] = eig(J_sepctral,L);

if(maxmin==0)%Minimise
    sort_type = 'ascend';
else %Maximise
    sort_type = 'descend';
end

evls = diag(evls);     if isreal(evls)==0,    evcs = abs(evcs);  evls = abs(evls);end
evls(isinf(evls))=0.0; evls(isnan(evls))=0.0; evcs(isinf(evcs))=0.0; evcs(isnan(evcs))=0.0;
evls(evls<10^-6) = 0.0;
evls = nonzeros(evls);
[~,I] = sort(evls,sort_type);  s_evcs = evcs(:,I);
T=s_evcs(:,1:d);
etaI=eta*eye(size(Traindata*Traindata',2));
W = pinv((Traindata*Traindata')+etaI)*(Traindata*T);
Q = W';
end
