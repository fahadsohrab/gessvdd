function [gessvdd]=gessvddtrain(Traindata,varargin)
%ssvddtrain() is a function for training a model based on "Graph Embedded Subspace Support
%Vector Data Description"
% Input
%    Traindata = Contains training data from a single (target) class for training a model.
%   'maxIter' :Maximim iteraions, Default=100
%   'C'       :Value of hyperparameter C, Default=0.1
%   'd'       :Data in lower dimension, make sure that input d<D, Default=1,
%   'eta'     :Used as step size for gradient, Default=0.1
%   'opt'     :Selection of optimisation type, Default=3 (Spectral regression based)
%              other options: 1=Gradient Based Solution, 2=Generalized eigen value based
%   'laptype' :Selection for laplacian type, 1 for PCA, 2 for S_w, 3 for knn, 4 for S_b
%   'L'       :User's defined Laplacian matrix
%   's'       :Hyperparameter for the kernel. 
%   'kcluster':Number of clusters (S_w,S_b), Number of K-neighbors(knn),Default=5
%   'max'     :Input 1 for maximisation, (Default=0, minimization)
%
% Output      :gessvdd.modelparam = Trained model (for every iteration)
%             :gessvdd.Q= Projection matrix (after every iteration)
%             :gessvdd.npt=non-linear train data information, used for testing data
%Example
%essvddmodel=gessvddtrain(Traindata,'C',0.12,'d',2,'opt',2,'laptype',4);

p = inputParser;
defaultVal_maxIter = 100;
defaultVal_Cval = 0.1;
defaultVal_d = 1;
defaultVal_eta = 0.001;
defaultVal_opt=3;
defaultVal_laptype=1;
defaultVal_L=1;
defaultVal_s=0.001;
defaultVal_cluster=5;
defaultVal_max=0;

addParameter(p,'maxIter',defaultVal_maxIter)
addParameter(p,'C',defaultVal_Cval)
addParameter(p,'d',defaultVal_d)
addParameter(p,'eta',defaultVal_eta)
addParameter(p,'opt',defaultVal_opt)
addParameter(p,'laptype',defaultVal_laptype)
addParameter(p,'L',defaultVal_L)
addParameter(p,'s',defaultVal_s)
addParameter(p,'kcluster',defaultVal_cluster)
addParameter(p,'max',defaultVal_max)

valid_argnames = {'l','laptype'};
argwasspecified = ismember(valid_argnames, lower(varargin(1:2:end)));
if(sum(argwasspecified)>1)
    msg = 'Error: Both L and laptype cannot be passed as an input argument together.';
    error(msg)
end

parse(p,varargin{:});
maxIter=p.Results.maxIter;
Cval=p.Results.C;
d=p.Results.d;
eta=p.Results.eta;
optimisationtype=p.Results.opt;
laptype=p.Results.laptype;
L=p.Results.L;
kappa=p.Results.s;
knngmean=p.Results.kcluster;
maxmin=p.Results.max;

if(maxmin~=1)&&(maxmin~=0)
    msg = 'Error: the argument max should be either 1 (for maximizing) or 0 (defaullt if no argument is passed) for minimising.';
    error(msg)
end

valid_argnames = {'l'};
argwasspecified = ismember(valid_argnames, lower(varargin(1:2:end)));
if(argwasspecified~=1)
    L=laplacianselect(Traindata,laptype,knngmean,kappa);
end

%NPT for train Data starts here
%RBF kernel
    N = size(Traindata,2);
    Dtrain = ((sum(Traindata'.^2,2)*ones(1,N))+(sum(Traindata'.^2,2)*ones(1,N))'-(2*(Traindata'*Traindata)));
    sigma = kappa * mean(mean(Dtrain));  A = 2.0 * sigma;
    Ktrain = exp(-Dtrain/A);
    %center_kernel_matrices
    Ktrain = (eye(N,N)-ones(N,N)/N) * Ktrain * (eye(N,N)-ones(N,N)/N);
    [U,S] = eig(Ktrain);        s = diag(S);
    s(s<10^-6) = 0.0;
    [U, s] = sortEigVecs(U,s);  s_acc = cumsum(s)/sum(s);   S = diag(s);
    II = find(s_acc>=0.999);
    LL = II(1);
    Pmat = pinv(( S(1:LL,1:LL)^(0.5) * U(:,1:LL)' )');
    %Phi
    Phi = Pmat*Ktrain;
    %Saving useful variables for non-linear testing
    npt_data={1,A,Ktrain,Phi,Traindata};%1,A,Ktrain,Phi,Traindata (1 is for NPT flag #Future)
    Traindata=Phi;
%NPT for train Data Ends here

Trainlabel= ones(size(Traindata,2),1); %Training labels (all +1s)
%Init start
Q = initialize_Q(size(Traindata,1),d);
S=Q*Traindata*L*Traindata'*Q';
SS = sqrtm(pinv(S)) ; % e inverse sqrroot
reducedData=SS*Q*Traindata;
Model = svmtrain(Trainlabel, reducedData', ['-s ',num2str(5),' -t 0 -c ',num2str(Cval)]);
%Init ends

if optimisationtype==1
    disp('Gradient Based GES-SVDD running...')
    for ii=1:maxIter
        %Get the alphas
        Alphavector=fetchalpha(Model,N);
        S_transpose=Q*Traindata*L'*Traindata'*Q';
        V=pinv(S_transpose);
        CovX=Traindata*L'*Traindata';
        
        Sum1_data =2*V*Q*Traindata*diag(Alphavector)*Traindata';
        Sum2_data= 2*V*Q*(Traindata*(Alphavector*Alphavector')*Traindata');
        Sum3_data=Sum1_data*Q'*V*Q*CovX;
        Sum4_data=Sum2_data*Q'*V*Q*CovX;
        Grad=Sum1_data-Sum2_data-Sum3_data+Sum4_data;
        
        if(maxmin==0)%Minimise
        Q = Q - eta*Grad; 
        else %Maximise
        Q = Q + eta*Grad;  
        end
        Q = OandN_Q(Q);
                
        S=Q*Traindata*L*Traindata'*Q'; 
        SS = sqrtm(pinv(S));
        reducedKtrain=SS*Q*Traindata;
        Model = svmtrain(Trainlabel, reducedKtrain', ['-s ',num2str(5),' -t 0 -c ',num2str(Cval)]);
        Qiter{ii}=SS*Q;
        Modeliter{ii}=Model; 
    end
    disp('...All Iterations Completed')
    
elseif optimisationtype==2
    disp('Generalized eigen value based GES-SVDD running...')
    for ii=1:maxIter
        %Get the alphas
        Alphavector=fetchalpha(Model,N);
        St=Traindata*L*Traindata';
        S_alpha=Traindata*(diag(Alphavector)-(Alphavector*Alphavector'))*Traindata';
        Q =eigQ(S_alpha,St,d,eta,maxmin);
        %orthogonalize and normalize 
        Q = OandN_Q(Q);
        
        S=Q*Traindata*L*Traindata'*Q';
        SS = sqrtm(pinv(S)); 
        reducedData=SS*Q*Traindata;
        Model = svmtrain(Trainlabel, reducedData', ['-s ',num2str(5),' -t 0 -c ',num2str(Cval)]);
        Qiter{ii}=SS*Q;
        Modeliter{ii}=Model;
    end
    disp('...All Iterations Completed')
    
elseif optimisationtype==3
    disp('Spectral Regression based GES-SVDD running...')
    for ii=1:maxIter
        %Get the alphaS
        Alphavector=fetchalpha(Model,N);
        % compute the gradient and update the matrix Q
        J_sepctral=(diag(Alphavector)-(Alphavector*Alphavector'));
        Q=SpectraleigQ(Traindata,J_sepctral,eta,d,L,maxmin);
        %orthogonalize and normalize Q
        Q = OandN_Q(Q);
        
        S=Q*Traindata*L*Traindata'*Q';
        SS = sqrtm(pinv(S)) ;
        reducedData=SS*Q*Traindata;
        Model = svmtrain(Trainlabel, reducedData', ['-s ',num2str(5),' -t 0 -c ',num2str(Cval)]);
        Qiter{ii}=SS*Q;
        Modeliter{ii}=Model;
    end
    disp('...All Iterations Completed')
else
    msg = 'Error: Please select correct solution for optimisation. 1: Gradient based, 2:Generalised eigen value based, 3: Spectral regression based';
    error(msg)
end
gessvdd.modelparam= Modeliter;
gessvdd.Q= Qiter;
gessvdd.npt=npt_data;
end
