# Graph embedded subspace support vector data description

This repository is for Graph Embedded Subspace Support Vector Data Description (GESSVDD). The codes are provided as .m (matlab) files to be executed in matlab. The codes are provided without any warranty or gurantee. Download the package from [HERE](https://github.com/fahadsohrab/gessvdd/archive/main.zip), unzip and add the folder gessvdd-main to the path in matlab. see **GESSVDDdemo.m** for exmaple usage.

# Requirements
GESSVDD requires *LIBSVM for SVDD*. Before executing the codes, make sure that correct version (3.22) of *LIBSVM for SVDD* is installed already. In order to install *LIBSVM for SVDD*  Please download zip file from [HERE](https://www.csie.ntu.edu.tw/~cjlin/libsvmtools/svdd/libsvm-svdd-3.22.zip), put sources into libsvm-3.22 available [HERE](https://www.csie.ntu.edu.tw/~cjlin/libsvm/oldfiles/libsvm-3.22.zip), and make the code. For more details about how to install libsvm, please refer [HERE](https://www.csie.ntu.edu.tw/~cjlin/libsvmtools/#libsvm_for_svdd_and_finding_the_smallest_sphere_containing_all_data)

# Example
```text

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
% params.K        :Number of clusters (S_w,S_b), Number of K-neighbors(knn),Default=5.
% params.minmax   :Possible options are 'max', 'min' ,Default='min'.
% params.maxIter  :Maximim iteraions of the algorithm. Default=10.

%%Input parameters setting example
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
```
Please contact fahad.sohrab@tuni.fi for any errors, bugs or issues.
# Citation
If you use any part of this repository in younr implementation, consider citing the following papers.

@article{sohrab2023graph,
  title={Graph-embedded subspace support vector data description},
  author={Sohrab, Fahad and Iosifidis, Alexandros and Gabbouj, Moncef and Raitoharju, Jenni},
  journal={Pattern Recognition},
  volume={133},
  pages={108999},
  year={2023},
  publisher={Elsevier}
}
  
@article{sohrab2020ellipsoidal,
  title={Ellipsoidal subspace support vector data description},
  author={Sohrab, Fahad and Raitoharju, Jenni and Iosifidis, Alexandros and Gabbouj, Moncef},
  journal={IEEE Access},
  volume={8},
  pages={122013--122025},
  year={2020},
  publisher={IEEE}
}

@inproceedings{sohrab2018subspace,
  title={Subspace support vector data description},
  author={Sohrab, Fahad and Raitoharju, Jenni and Gabbouj, Moncef and Iosifidis, Alexandros},
  booktitle={2018 24th International Conference on Pattern Recognition (ICPR)},
  pages={722--727},
  year={2018},
  organization={IEEE}
}
