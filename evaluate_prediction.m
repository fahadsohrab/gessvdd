function eval = evaluate_prediction(ACTUAL,PREDICTED)
% This fucntion evaluates the performance of a graph embedded SSVDD model by
% calculating the common performance measures: Accuracy, tp_rate,
% Precision, F-Measure, G-mean.
% Input: ACTUAL = Column matrix with actual class labels of the training
%                 examples
%        PREDICTED = Column matrix with predicted class labels by the
%                    classification model
% Output: eval = struct with all the performance measures

if isempty(PREDICTED)
    eval.tp_rate = 0;
    eval.tn_rate = 0;
    eval.accuracy = 0;
    eval.precision = 0;
    eval.f_measure = 0;
    eval.gmean = 0;
else
    idx = (ACTUAL()==1);
    p = length(ACTUAL(idx));
    n = length(ACTUAL(~idx));
    N = p+n;
    tp = sum(ACTUAL(idx)==PREDICTED(idx));
    tn = sum(ACTUAL(~idx)==PREDICTED(~idx));
    fp = n-tn;
    eval.tp_rate = tp/p;
    eval.tn_rate = tn/n;
    eval.accuracy = (tp+tn)/N;
    eval.precision = tp/(tp+fp);
    eval.precision(isnan(eval.precision))=0;
    recall = eval.tp_rate;
    eval.f_measure = 2*((eval.precision*recall)/(eval.precision + recall));
    eval.f_measure(isnan(eval.f_measure))=0;
    eval.tp_rate(isnan(eval.tp_rate))=0; 
    eval.tn_rate(isnan(eval.tn_rate))=0;
    eval.gmean = sqrt(eval.tp_rate*eval.tn_rate);
end
