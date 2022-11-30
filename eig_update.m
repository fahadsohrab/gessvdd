function Q = eig_update(S, params)

[evcs, evls] = eig(S); evls = diag(evls);
if strcmp(params.minmax, 'min'),type = 'ascend';
else, type = 'descend';
end

[s_evcs, ~] = sortEigVecs( evcs, evls, type );
Q = s_evcs(:,1:min(params.d,end))';

end
