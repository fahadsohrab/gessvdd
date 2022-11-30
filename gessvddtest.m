function [Predictlabel,eval] = gessvddtest(Testdata,Testlabel,gessvddmodel, varargin)
%gessvddtest() is a function for testing a model based on "Graph Embedded Subspace Support Vector Data Description"
% Input
%   Testdata  = Contains testing data from
%   Testlabels= contains original test lables
%   ssvddmodel= contains the output obtained from "ssvddmodel=ssvddtrain(Traindata,varargin)"
% Output
%   output argument #1      = predicted labels
%   output argument #2      = eval (evaluate predictions)
%           eval.tp_rate= sensitivity (True Positive Rate)
%           eval.tn_rate= specificity (True Negative Rate)
%           eval.accuracy= accuracy
%           eval.precision= precision
%           eval.f_measure=  F-Measure
%           eval.gmean= Geometric mean i.e, sqrt(tp_rate*tn_rate)
%
%NOTE regarding varargin: The model performance can be evaluated at a
%certain iteration by providing a cerytain number. If its not provided, the last iteration value is used as default. 

nptflag=gessvddmodel.npt{1};
if nptflag==1
    disp('NPT based non-linear gessvdd testing...')
    A=gessvddmodel.npt{2};
    Ktrain=gessvddmodel.npt{3};
    Phi=gessvddmodel.npt{4};
    M_train=gessvddmodel.npt{5};
    NN = size(Testdata,2);
    N = size(Ktrain,2);
    Dtest = ((sum(M_train'.^2,2)*ones(1,NN))+(sum(Testdata'.^2,2)*ones(1,N))'-(2*(M_train'*Testdata)));
    Ktest = exp(-Dtest/A);
    M = size(Ktest,2);
    Ktest = (eye(N,N)-ones(N,N)/N) * (Ktest - (Ktrain*ones(N,1)/N)*ones(1,M));
    Testdata = pinv(Phi')*Ktest;
else
    disp('Linear gessvdd testing...')
end

%Iter check for fetching model and corresponding Q
iter_index = double(isempty(varargin));
if(iter_index==1)
    testiter=size(gessvddmodel.Q,2);
else
    testiter=varargin{1};
end

Q = gessvddmodel.Q;
if size(Q,2) < testiter
    Predictlabel = [];
else
    model = gessvddmodel.modelparam{testiter};
    RedTestdata=Q{testiter}* Testdata;
    Predictlabel = svmpredict(Testlabel, RedTestdata', model);
end
eval = evaluate_prediction(Testlabel,Predictlabel);

end
