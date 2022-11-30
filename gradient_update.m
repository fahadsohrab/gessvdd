function Q = gradient_update(Q, Sa, St, params)

if strcmp(params.variant, 'basic')
    Grad = 2*Q*Sa;
else
    Sinv=pinv(Q*St*Q'); %L is assumed symmetric
    Grad = 2*Sinv*Q*Sa - 2*Sinv*Q*Sa*Q'*Sinv*Q*St;
end

if strcmp(params.minmax, 'min')
    eta = params.eta;
else
    eta = - params.eta;
end

Q = Q - eta*Grad;
end