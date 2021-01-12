function [gessvdd]=gessvddtrain(Traindata,varargin)
%ssvddtrain() is a function for training a model based on "Graph Embedded Subspace Support
%Vector Data Description"
% Input
%    Traindata = Contains training data from a single (target) class for training a model.
%   'maxIter' :Maximim iteraions, Default=100
%   'C'       :Value of hyperparameter C, Default=0.1
%   'd'       :data in lower dimension, make sure that input d<D, Default=1,
%   'eta'     :Used as step size for gradient, Default=0.1
%
% Output      :gessvdd.modelparam = Trained model (for every iteration)
%             :gessvdd.Q= Projection matrix (after every iteration)
%Example
%essvddmodel=gessvddtrain(Traindata,'C',0.12,'d',2,'opt',2);

p = inputParser;
defaultVal_maxIter = 100;
defaultVal_Cval = 0.1;
defaultVal_d = 1;
defaultVal_eta = 0.001;
defaultVal_opt=3;
defaultVal_laptype=1;
defaultVal_L=1;

addParameter(p,'maxIter',defaultVal_maxIter)
addParameter(p,'C',defaultVal_Cval)
addParameter(p,'d',defaultVal_d)
addParameter(p,'eta',defaultVal_eta)
addParameter(p,'opt',defaultVal_opt)
addParameter(p,'laptype',defaultVal_laptype)
addParameter(p,'L',defaultVal_L)


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



valid_argnames = {'l'};
argwasspecified = ismember(valid_argnames, lower(varargin(1:2:end)));
if(argwasspecified~=1)
    L=laplacianselect(Traindata,laptype,5);
end

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
        %First Step COmpute Q
        %Get the alphas for data
        Alphaindex=Model.sv_indices; %Indices where alpha is non-zero
        AlphaValue=Model.sv_coef; %values of Alpha
        Alphavector=zeros(size(reducedData,2),1); %Generate a vectror of zeros
        for qq=1:size(Alphaindex,1)
            Alphavector(Alphaindex(qq))=AlphaValue(qq);
        end
        S_transpose=Q*Traindata*L'*Traindata'*Q';
        V=pinv(S_transpose);
        CovX=Traindata*L'*Traindata';
        
        Sum1_data =2*V*Q*Traindata*diag(Alphavector)*Traindata';
        Sum2_data= 2*V*Q*(Traindata*(Alphavector*Alphavector')*Traindata');
        Sum3_data=Sum1_data*Q'*V*Q*CovX;
        Sum4_data=Sum2_data*Q'*V*Q*CovX;
        
        Grad=Sum1_data-Sum2_data-Sum3_data+Sum4_data;
        
        Q = Q - eta*Grad;
        Q = OandN_Q(Q);
        
        %Second Step Find Model (L is fixed here from the original space, different code for L in subspace)
        S=Q*Traindata*L*Traindata'*Q'; % Dont confuse it with S_transpose.
        SS = sqrtm(pinv(S));
        reducedKtrain=SS*Q*Traindata;
        Model = svmtrain(Trainlabel, reducedKtrain', ['-s ',num2str(5),' -t 0 -c ',num2str(Cval)]); %type 5 is svdd
        %Save for later testing
        Qiter{ii}=SS*Q;
        Modeliter{ii}=Model;
        
    end
    disp('...All Iterations Completed')
    
elseif optimisationtype==2
    disp('Generalized eigen value based GES-SVDD running...')
    for ii=1:maxIter
        %Get the alphas
        Alphaindex=Model.sv_indices; %Indices where alpha is non-zero
        AlphaValue=Model.sv_coef; %values of Alpha
        Alphavector=zeros(size(reducedData,2),1); %Generate a vectror of zeros
        for qq=1:size(Alphaindex,1)
            Alphavector(Alphaindex(qq))=AlphaValue(qq);
        end
        St=Traindata*L*Traindata';
        S_alpha=Traindata*(diag(Alphavector)-(Alphavector*Alphavector'))*Traindata';      % V prime , each row is an observation for Cov()
        Q =eigQ(S_alpha,St,d);
        %orthogonalize and normalize Q1
        Q = OandN_Q(Q);
        S=Q*Traindata*L*Traindata'*Q';
        SS = sqrtm(pinv(S)); % e inverse sqrroot
        reducedData=SS*Q*Traindata;
        Model = svmtrain(Trainlabel, reducedData', ['-s ',num2str(5),' -t 0 -c ',num2str(Cval)]);
        %Save for later testing
        Qiter{ii}=SS*Q;
        Modeliter{ii}=Model;
    end
    disp('...All Iterations Completed')
    
elseif optimisationtype==3
    disp('Spectral Regression based GES-SVDD running...')
    for ii=1:maxIter
        %Get the alphas for data1
        Alphaindex=Model.sv_indices; %Indices where alpha is non-zero
        AlphaValue=Model.sv_coef; %values of Alpha
        Alphavector=zeros(size(reducedData,2),1); %Generate a vectror of zeros
        for qq=1:size(Alphaindex,1)
            Alphavector(Alphaindex(qq))=AlphaValue(qq);
        end
        % compute the gradient and update the matrix Q
        J_sepctral=(diag(Alphavector)-(Alphavector*Alphavector'));
        Q=SpectraleigQ(Traindata,J_sepctral,eta,d,L);
        %orthogonalize and normalize Q
        Q = OandN_Q(Q);
        
        S=Q*Traindata*L*Traindata'*Q';
        SS = sqrtm(pinv(S)) ; % e inverse sqrroot
        reducedData=SS*Q*Traindata;
        Model = svmtrain(Trainlabel, reducedData', ['-s ',num2str(5),' -t 0 -c ',num2str(Cval)]);
        %Save for later testing
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
end
