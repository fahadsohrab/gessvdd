% This is a sample demo code for Graph Embedded Subspace Support Vector Data Description
% Please contact fahad.sohrab@tuni.fi for any errors/bugs
clc
close all
clear

%% Possible inputs to gessvddtrain
% The first input argument is the Traindata (target training data)
% other inputs/options are
%
% params.variant  :Possible options are 'basic', 'ellipsoid', 'pca', 'kNN', 'Sw', 'Sb'. Default= 'pca'
% params.solution :Possible options are 'gradient', 'eig', 'spectral_regression' Default='gradient'
% params.C        :Value of hyperparameter C, Default=0.1.
% params.d        :Data in lower dimension, make sure that params.dim<D, Default=2.
% params.eta      :Needed only with gradient solution, Used as step size for gradient, Default=0.01.
% params.npt      :Used for selecting non-linear data description. Possible options are 1 (for non-linear data description), default=1 (linear data description)
% params.s        :Hyperparameter for the kernel, used in non-linear data description. Default=10.
% params.K:       :Number of clusters (S_w,S_b), Number of K-neighbors(knn),Default=5.
% params.minmax   :Possible options are 'max', 'min' ,Default='min'.
% params.maxIter  :Maximim iteraions of the algorithm. Default=10.

%% Generate Random Data
noOfTrainData = 500; noOfTestData = 100;
D= 5; %D=Original dimensionality of data/features
Traindata = rand(D,noOfTrainData); %Training data/features
%Training labels (all +1s) are not needed.

testlabels = -ones(noOfTestData,1);
perm = randperm(noOfTestData);
positiveSamples = floor(noOfTestData/2);
testlabels(perm(1:positiveSamples))=1; % test labels, +1 for target, -1 for outliers
Testdata= rand(D,noOfTestData); %Testing data/features

%% Input parameters setting example
params.variant = 'pca';
params.solution = 'gradient';
params.minmax = 'max';
params.maxIter = 5;
params.Cval=0.5;
params.d=2;
params.eta=0.2;
params.npt=1;
params.s=5;
params.maxIter = 10;

%% Training and Testing
gessvddmodel=gessvddtrain(Traindata,params);
[predicted_labels,eval]=gessvddtest(Testdata,testlabels,gessvddmodel);
