function [Q]=eigQ(S_alpha,St,d,maxmin)
[evcs, evls] = eig(S_alpha,St,'qz');
if(maxmin==0)%Minimise
    sort_type = 'ascend';
else %Maximise
    sort_type = 'descend';
end
%check eigenvalues and eigenvectors
evls = diag(evls);     if isreal(evls)==0,    evcs = abs(evcs);  evls = abs(evls);     end
evls(isinf(evls))=0.0; evls(isnan(evls))=0.0; evcs(isinf(evcs))=0.0; evcs(isnan(evcs))=0.0;
%select positive and remove small ones
evls(evls<10^-6) = 0.0;
evls = nonzeros(evls);
[~,I] = sort(evls,sort_type);  s_evcs = evcs(:,I);
if d<=size(s_evcs,1)
    Q = s_evcs(:,1:d)';
else
    Q = s_evcs(:,:)';
end
end
