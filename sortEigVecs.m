function [mevcs, mevls] = sortEigVecs(evcs,evls,type)
% Input:
% evls: not sorted eigenvalues (row vector)
% evs: not sorted eigenvactors (columns)
%
% Output:
% sorted eigenvalues and eigenvectors

if nargin < 3,  type = 'descend';  end
 
evls(imag(evls)~=0) = 0; 
evcs(imag(evcs)~=0) = real(evcs(imag(evcs)~=0));    

evls(isinf(evls))=0.0; 
evls(isnan(evls))=0.0; 
evcs(isinf(evcs))=0.0; 
evcs(isnan(evcs))=0.0;

%Round near-zero eigenvalues to zero
evls(evls<10^-6) = 0.0;

%Sort eigenvalues and remove zeros
[auxv, auxi] = sort(evls,type);
mevls = auxv;
mevcs = evcs(:,auxi);
mevcs = mevcs(:,mevls > 0);
mevls = mevls(mevls > 0);
end
