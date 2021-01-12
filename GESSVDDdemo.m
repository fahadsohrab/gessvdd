% This is a sample demo code for Graph Embedded Subspace Support Vector Data Description
% The demo code is provided for Linear case S-SVDD
% For non-linear cases, first apply NPT.m over the data and then use the output Phi and Phi_t as train and test data in gessvddtrain() and gessvddtest()
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
%   'd'       :data in lower dimension, make sure that input d<D, Default=1,
%   'eta'     :Used as step size for gradient, Default=0.1
%   'laptype' :Used for selecting the available Laplacians, Default=1 (PCA)
%              other options: 2=withinclass scatter,3=knn
%   'L'       :Input custom/other Laplacian matrix
%   'opt'     :Selection of optimisation type, Default=3 (Spectral regression based)
%              other options: 1=Gradient Based Solution, 2=Generalized eigen value based

gessvddmodel=gessvddtrain(Traindata,'C',0.1,'d',4,'maxIter',10,'opt',3);
[predicted_labels,accuracy,sensitivity,specificity]=gessvddtest(Testdata,testlabels,gessvddmodel);
