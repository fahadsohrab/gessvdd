function gessvdd = gessvddtrain(Traindata,params)
%gessvddtrain() is a function for training a model based on "Graph Embedded Subspace Support Vector Data Description"
% Input
%    Traindata = Contains training data from a single (target) class for training a model.
%    params
% params.variant  :Possible options are 'basic', 'ellipsoid', 'pca', 'kNN', 'Sw', 'Sb'. Default= 'pca'
% params.solution :Possible options are 'gradient', 'eig', 'spectral_regression' Default='gradient'
% params.C        :Value of hyperparameter C, Default=0.1.
% params.d        :Data in lower dimension, make sure that params.dim<D, Default=2.
% params.eta      :Needed only with gradient solution, Used as step size for gradient, Default=0.01.
% params.npt      :Used for selecting non-linear data description. Possible options are 1 (for non-linear data description), default=1 (linear data description)
% params.s        :Hyperparameter for the kernel, used in non-linear data description. Default=10.
% params.K        :Number of clusters (S_w,S_b), Number of K-neighbors(knn),Default=5.
% params.minmax   :Possible options are 'max', 'min' ,Default='min'.
% params.maxIter  :Maximim iteraions of the algorithm. Default=10.
%
% Output      :gessvdd.modelparam = Trained model (for every iteration)
%             :gessvdd.Q= Projection matrix (after every iteration)
%             :gessvdd.npt=non-linear train data information, used for testing data

%% Setting Default parameters
default_params.variant = 'pca';
default_params.solution = 'gradient';
default_params.minmax = 'min';
default_params.s = 10;
default_params.eta = 0.01;
default_params.d = 2;
default_params.C = 0.1;
default_params.maxIter = 10;
default_params.K = 5;
default_params.npt = 1;
%%
given = fieldnames(params);
defaults = fieldnames(default_params);
missingIdx = find(~ismember(defaults, given));
% Assign missing fields to params
for i = 1:length(missingIdx)
    params.(defaults{missingIdx(i)}) = default_params.(defaults{missingIdx(i)});
end

if strcmp(params.variant, 'basic') && strcmp( params.solution, 'spectral_regression')
error('Spectral regression solution is not available for basic S-SVDD')
end


if params.d > size(Traindata,1)
    error('d must be <= D')
end

if params.C < 1/size(Traindata,2)
    error( 'C should be larger than 1/N');
end

if params.npt==1
    disp('Non-linear GESSVDD running...')
    %RBF kernel
    N = size(Traindata,2);
    Dtrain = ((sum(Traindata'.^2,2)*ones(1,N))+(sum(Traindata'.^2,2)*ones(1,N))'-(2*(Traindata'*Traindata)));
    sigma = params.s  * mean(mean(Dtrain));  A = 2.0 * sigma;
    Ktrain_exp = exp(-Dtrain/A);
    %center_kernel_matrices
    N = size(Ktrain_exp,2);
    Ktrain = (eye(N,N)-ones(N,N)/N) * Ktrain_exp * (eye(N,N)-ones(N,N)/N);
    [U,S] = eig(Ktrain);        s = diag(S);
    s(s<10^-6) = 0.0;
    [U, s] = sortEigVecs(U,s);  s_acc = cumsum(s)/sum(s);   S = diag(s);
    II = find(s_acc>=0.999);
    LL = II(1);
    Pmat = pinv(( S(1:LL,1:LL)^(0.5) * U(:,1:LL)' )');
    %Phi
    Phi = Pmat*Ktrain;
    %Saving useful variables for non-linear testing
    npt_data={1,A,Ktrain_exp,Phi,Traindata};%1,A,Ktrain,Phi,Traindata (1 is for flag)
    Traindata=Phi;
else
    disp('Linear GESSVDD running...')
end

%Define L for non-basic variant
if ~strcmp(params.variant, 'basic')
    if isfield(params, 'L')
        Lt = L;
    else
        Lt = laplacianselect(Traindata, params);
    end
end

[D,N] = size(Traindata);

%Compute these here to compute them only once
if strcmp(params.variant, 'basic')
    St = eye(D);
    St_inv = eye(D);
else
    St = Traindata*Lt*Traindata';
    if strcmp(params.solution, 'eig')
        St_inv = pinv(St);
    elseif strcmp(params.solution, 'spectral_regression')
        Lt_inv = pinv(Lt);
    end
    
end
Q = initialize_Q(size(Traindata,1),params.d);

for ii=1:params.maxIter
    
    SS = pinv(real(sqrtm(Q*St*Q' + 10^-6*eye(size(Q,1))))); % e inverse sqrroot
    reducedData=SS*Q*Traindata;
    Model = svmtrain(ones(N,1), reducedData', ['-s ',num2str(5),' -t 0 -c ',num2str(params.C)]);
    Qiter{ii}=SS*Q;
    Modeliter{ii}=Model;
    
    Alphavector=fetchalpha(Model,N);
    La = diag(Alphavector) - Alphavector*Alphavector';
    
    %Update Q
    switch params.solution
        case 'gradient'
            Sa = Traindata*La*Traindata';
            Q = gradient_update(Q, Sa, St, params);
        case 'eig'
            Sa = Traindata*La*Traindata';
            Q = eig_update(St_inv*Sa, params);
        case 'spectral_regression'
            Q = spectral_regression_update(Lt_inv*La, params, Traindata);
    end
    
    if isempty(Q)
        break;
    end
    
    %orthogonalize and normalize Q
    Q = OandN_Q(Q);
end

gessvdd.modelparam = Modeliter;
gessvdd.Q = Qiter;

if params.npt==1
    gessvdd.npt=npt_data;
else
    gessvdd.npt{1}=0;
end
end
