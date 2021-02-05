function [Q]=eigQ(S_alpha,St,d,eta,maxmin)
St=St+(eta.*eye(size(St)));%Regularization
[evcs, evls] = eig(S_alpha,St,'qz');
if(maxmin==0)%Ascending
    factor=+1;
else %Maximise
    factor =-1;%Descending
end
%check eigenvalues and eigenvectors
evls = diag(evls);     if isreal(evls)==0,    evcs = abs(evcs);  evls = abs(evls);     end
evls(isinf(evls))=0.0; evls(isnan(evls))=0.0; evcs(isinf(evcs))=0.0; evcs(isnan(evcs))=0.0;
%select positive and remove small ones
% evls(evls<10^-6) = 0.0;
index = evls<10^-6;
evls(index)=[];
evcs(:,index)=[];
[~, index] = sort(factor*evls);
evls = evls(index); %Just for future debugging
s_evcs = evcs(:,index);
if d<=size(s_evcs,1)
    Q = s_evcs(:,1:d)';
else
    Q = s_evcs(:,:)';
end
end
