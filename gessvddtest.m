function varargout=gessvddtest(Testdata,testlabels,gessvddmodel)
%ssvddtest() is a function for testing a model based on "Subspace Support
%Vector Data Description"
% Input
%   Testdata  = Contains testing data from
%   Testlabels= contains original test lables
%   ssvddmodel= contains the output obtained from "ssvddmodel=ssvddtrain(Traindata,varargin)"
% Output
%   output argument #1 = predicted labels
%   output argument #2 = accuracy
%   output argument #3 = sensitivity (True Positive Rate)
%   output argument #4 = specificity (True Negative Rate)
%   output argument #5 = precision
%   output argument #6 = F-Measure
%   output argument #7 = Geometric mean i.e, sqrt(tp_rate*tn_rate)
%Example
%[predicted_labels,accuracy,sensitivity,specificity]=ssvddtest(Testdata,testlabels,ssvddmodel);

%NPT
    disp('GES-SVDD Testing...')
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
%NPT ends

Q=gessvddmodel.Q;
Model=gessvddmodel.modelparam{end};
RedTestdata=Q{end}* Testdata;
predict_label = svmpredict(testlabels, RedTestdata', Model);
EVAL = evaluategessvdd(testlabels,predict_label);
% accuracy =EVAL(1);
% sensitivity =EVAL(2);
% specificity =EVAL(3);
% precision =EVAL(4);
% f_measure =EVAL(5);
% gmean=EVAL(6);
varargout{1}=predict_label;
for jj=2:7
    varargout{jj}=EVAL(jj-1);
end
end
