function L = laplacianselect(Traindata, params)

N = size( Traindata, 2 );
switch params.variant
    case 'ellipsoid'
        L = eye(N);
    case 'pca'
        L =  (1/N)*(eye(N) - 1/N *(ones(N,1)*ones(N,1)'));  
    case 'kNN'
        Dtrain = ((sum(Traindata'.^2,2)*ones(1,N))+(sum(Traindata'.^2,2)*ones(1,N))'-(2*(Traindata'*Traindata)));
        W = zeros(N);
        for ii=1:N
            [~, ind] = sort(Dtrain(ii,:),'descend');
            W(ii,ind(1:params.K)) = 1.0;
        end
        W=(W+W'); %Make symmetric
        W(W~=0)=1.0;
        D = sum(W')'; 
        L = diag(D) - W;
    case 'Sw'
        idx = kmeans(Traindata',params.K);
        A = zeros(N);
        for c=1:params.K
            Nc = sum(idx==c);
            A = A + double(idx==c)*double(idx==c)'/Nc;
        end
        L=eye(N)-A;
    case 'Sb'
        idx = kmeans(Traindata',params.K);
        L = 0 ;
        for c=1:params.K
            Nc = sum(idx==c);
            L = L + Nc*(double(idx==c)/Nc - ones(N)/N)*(double(idx==c)/Nc - ones(N)/N)';
        end
end
