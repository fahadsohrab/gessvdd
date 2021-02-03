% This is a sample demo code for Graph Embedded Subspace Support Vector Data Description
% Please contact fahad.sohrab@tuni.fi for any errors/bugs
clc
close all
clear

%%Generate Random Data
noOfTrainData = 500; noOfTestData = 100;
D= 5; %Original dimentionality of data
Traindata = rand(D,noOfTrainData); %Training Data/Features
%Training labels (all +1s) are not needed.

testlabels = -ones(noOfTestData,1);
perm = randperm(noOfTestData);
positiveSamples = floor(noOfTestData/2);
testlabels(perm(1:positiveSamples))=1; % test labels, +1 for target, -1 for outliers
Testdata= rand(D,noOfTestData); %Testing Data/Features from modality 1

%Possible inputs to essvddtrain
% The first input argument is the Training (target) data
%other options are
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

gessvddmodel=gessvddtrain(Traindata,'C',0.1,'d',4,'maxIter',10,'opt',2,'laptype',4,'max',1);
[predicted_labels,accuracy,sensitivity,specificity]=gessvddtest(Testdata,testlabels,gessvddmodel);
