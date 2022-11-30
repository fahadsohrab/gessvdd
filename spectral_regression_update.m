function Q = spectral_regression_update(J, params, Traindata )

[evcs, evls] = eig(J);   evls = diag(evls);

if strcmp(params.minmax, 'min'),type = 'ascend';
else, type = 'descend';
end

[s_evcs, ~] = sortEigVecs( evcs, evls, type );

T = s_evcs(:,1:min(params.d,end));
W = pinv(Traindata*Traindata')*(Traindata*T);
Q = W';
end
