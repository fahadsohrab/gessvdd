function L=laplacianselect(train,laptype,knngmean,gamma)

if laptype==1
    noOfTrainData=size(train,2);
    L =  (1/noOfTrainData)*(eye(noOfTrainData) - 1/noOfTrainData *(ones(noOfTrainData,1)*ones(noOfTrainData,1)'));
    
elseif laptype==2
    clusters=knngmean;
    idx = kmeans(train',clusters);
    A = 0 ;
    for clustersnumber=1:clusters
        temp = idx==clustersnumber;
        temp=double(temp);
        current_matrix = temp*temp';
        current_matrix = current_matrix./ sum(temp) ;
        A = A + current_matrix;
    end
    L=eye(size(A))-A;
    
elseif laptype==3
    N = size(train,2);
    Dtrain = ((sum(train'.^2,2)*ones(1,N))+(sum(train'.^2,2)*ones(1,N))'-(2*(train'*train)));
    sigma2 = gamma * mean(mean(Dtrain));  A = 2.0 * sigma2;
    Ktrain = exp(-Dtrain/A);
    %Ktrain = KforKnn;
    W = zeros(size(Ktrain));
    kNN = knngmean;
    
    for ii=1:size(Ktrain,2)
        [~, ind] = sort(Ktrain(ii,:),'descend');
        W(ii,ind(1:kNN)) = 1.0;
    end
    W=(W+W');
    W(W~=0)=1.0;
    D = sum(W')';
    L = diag(D) - W;
    
elseif laptype==4%S_B
    clusters=knngmean;
    idx = kmeans(train',clusters);
    A = 0 ;
    for clustersnumber=1:clusters
        temp = idx==clustersnumber;
        temp=double(temp);
        Nc=sum(temp);
        temp=temp./Nc;
        tempones=ones(size(temp));
        tempones=tempones./sum(tempones);
        temp=temp-tempones;
        current_matrix=temp*temp';
        current_matrix=Nc.*current_matrix;
        A = A + current_matrix;
    end
    L=A;
   
else
    msg = 'Error: Input a correct selection for laptype, 1 for PCA, 2 for S_w, 3 for knn, 4 for S_b';
    error(msg)
end

end