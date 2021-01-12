# gessvdd
Graph embedded subspace support vector data description

This repository is for Graph Embedded Subspace Support Vector Data Description (GES-SVDD). The codes are provided as .m (matlab) files to be executed in matlab. The codes are provided without any warranty or gurantee. Download the package from [HERE](https://github.com/fahadsohrab/gessvdd/archive/main.zip),, unzip and add the folder gessvdd-main to the path in matlab. see **GESSVDDdemo.m** for exmaple usage.

Possible inputs to gessvddtrain
The first input argument is the Training (target) data
other options are
   'maxIter' :Maximim iteraions, Default=100
   'C'       :Value of hyperparameter C, Default=0.1
   'd'       :data in lower dimension, make sure that input d<D, Default=1,
   'eta'     :Used as step size for gradient, Default=0.1
   'laptype' :Used for selecting the available Laplacians, Default=1 (PCA)
              other options: 2=withinclass scatter,3=knn
   'L'       :Input custom/other Laplacian matrix
   'opt'     :Selection of optimisation type, Default=3 (Spectral regression based)
              other options: 1=Gradient Based Solution, 2=Generalized eigen value based

# Example
gessvddmodel=gessvddtrain(Traindata,'C',0.12,'d',2,'eta',0.02);
[predicted_labels,accuracy,sensitivity,specificity]=gessvddtest(Testdata,testlabels,gessvddmodel); 

Please contact fahad.sohrab@tuni.fi for any issues.
