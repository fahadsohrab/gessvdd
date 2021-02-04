# Graph embedded subspace support vector data description

This repository is for Graph Embedded Subspace Support Vector Data Description (GES-SVDD). The codes are provided as .m (matlab) files to be executed in matlab. The codes are provided without any warranty or gurantee. Download the package from [HERE](https://github.com/fahadsohrab/gessvdd/archive/main.zip), unzip and add the folder gessvdd-main to the path in matlab. see **GESSVDDdemo.m** for exmaple usage.
```text
Possible inputs to gessvddtrain
The first input argument is the Training (target) data
other options are
   'maxIter' :Maximim iteraions, Default=100
   'C'       :Value of hyperparameter C, Default=0.1
   'd'       :Data in lower dimension, make sure that input d<D, Default=1,
   'eta'     :Used as step size for gradient, Default=0.1
   'opt'     :Selection of optimisation type, Default=3 (Spectral regression based)
              other options: 1=Gradient Based Solution, 2=Generalized eigen value based
   'laptype' :Selection for laplacian type, 1 for PCA, 2 for S_w, 3 for knn, 4 for S_b
   'L'       :User's defined Laplacian matrix
   's'       :Hyperparameter for the kernel. 
   'kcluster':Number of clusters (S_w,S_b), Number of K-neighbors(knn),Default=5
   'max'     :Input 1 for maximisation, (Default=0, minimization)
```
# Example
gessvddmodel=gessvddtrain(Traindata,'C',0.12,'d',2,'eta',0.02);
[predicted_labels,accuracy,sensitivity,specificity]=gessvddtest(Testdata,testlabels,gessvddmodel); 

Please contact fahad.sohrab@tuni.fi for any issues.
# Citation
If you use any part of this repository in younr implementation, consider citing the following paper.

  @ARTICLE{gessvdd,
  author={F. {Sohrab} and J. {Raitoharju} and A. {Iosifidis} and M. {Gabbouj}},
  journal={TBD}, 
  title={Graph Embedded Subspace Support Vector Data Description}, 
  year={2021},
  }
  
@inproceedings{sohrab2018subspace,
  title={Subspace support vector data description},
  author={Sohrab, Fahad and Raitoharju, Jenni and Gabbouj, Moncef and Iosifidis, Alexandros},
  booktitle={2018 24th International Conference on Pattern Recognition (ICPR)},
  pages={722--727},
  year={2018},
  organization={IEEE}
}

@ARTICLE{essvdd2020sohrab,
  author={F. {Sohrab} and J. {Raitoharju} and A. {Iosifidis} and M. {Gabbouj}},
  journal={IEEE Access}, 
  title={Ellipsoidal Subspace Support Vector Data Description}, 
  year={2020},
  volume={8},
  pages={122013-122025},
  doi={10.1109/ACCESS.2020.3007123}}
  

  
  
