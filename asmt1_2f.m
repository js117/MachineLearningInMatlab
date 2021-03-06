% LOGISTIC REGRESSION

% fit a k-param model to the training data.
% For each model, make predictions for the validation cases, get their classErrs
% Use that value of k to make predictions for the 100 test cases and report the test error rate.


train_len = length(x_train);
xx = x_train; %in workspace, x_train saved as row vector
% Form features - polynomial powers of training data

X_train = [ones(train_len,1)]; 
w_all = cell(10,1);
LL_times = cell(10,1);
w_ls_test = cell(10,1);

% Create the 10 models over the training data:
num_itrs = 200000;
for k=1:10
    X_train = [X_train,  (xx.^k)]; %extend previous design matrix by adding new polynomial feature
    if (k > 1)
       disp(num2str(size(X_train))); 
    end
    [w, error_vector, LL, LL_time] = LogisticRegression(X_train,  (y_train), 0.001, -0.1, 0.1, num_itrs, -Inf, 0);
    w_all{k} = w; %save the model params
    LL_times{k} = exp(LL_time); %need to plot the likelihood otherwise you can't see anything...
    %w_ls_test{k} = (X_train'*X_train)\X_train'* (y_train);
end;
t=1:num_itrs;
plot(t,LL_times{1},t,LL_times{2},t,LL_times{3},t,LL_times{4},t,LL_times{5},...
     t,LL_times{6},t,LL_times{7},t,LL_times{8},t,LL_times{9},t,LL_times{10});

%TEST

% For each model, test over the validation data and get their classErrs:
val_len = length(x_val);
xx = x_val; %in workspace, x_val saved as row vector
X_val = [ones(val_len,1)];
min_classErr = Inf;
k_best = 1;
w_best = Inf;
min_classErr_ls = Inf;
LL_max = -Inf;
%k_best_ls = 1;
%w_best_ls = Inf;
for k=1:10
    X_val = [X_val,  (xx.^k)]; %extend previous design matrix by adding new polynomial feature
    y_predict_2f = X_val*w_all{k}; %compute the prediction for validation data
    %y_predict_ls = X_val*w_ls_test{k};
    classErr = nnz(binaryThresholdVector(y_predict_2f,0.5) - y_val)/length(y_val);
    LL = loglikelihood(y_val,y_predict_2f);
    %classErr_ls = nnz(binaryThresholdVector(y_predict_ls,0.5) - y_test)/length(y_test);
    disp(strcat('Validation classErr is:: ',num2str(classErr),'||LL==',num2str(LL),' for k==',num2str(k)));
    %disp(strcat('Validation classErr_ls is:: ',num2str(classErr_ls),' for k==',num2str(k)));
    if LL > LL_max
       LL_max = LL;
       k_best = k;
       w_best = w_all{k};
    end
    %if classErr_ls < min_classErr_ls
    %   min_classErr_ls = classErr_ls;
    %   k_best_ls = k;
    %   w_best_ls = w_ls_test{k};
    %end
end

% Use the best model to fit the test data:
test_len = length(x_test);
xx = x_test; %in workspace, x_val saved as row vector
X_test = [ones(test_len,1)];
for k=1:k_best
    X_test = [X_test,  (xx.^k)]; %extend previous design matrix by adding new polynomial feature
end
y_predict_2f = X_test*w_best;
LL = loglikelihood(y_test,y_predict_2f);

%Do the same for LS:
%X_test = [ones(test_len,1)];
%for k=1:k_best_ls
%    X_test = [X_test,  (xx.^k)]; %extend previous design matrix by adding new polynomial feature
%end
%y_predict_ls = X_test*w_best_ls;


classErr = nnz(binaryThresholdVector(y_predict_2f,0.5) - y_test)/length(y_test);
disp(strcat('Test classErr is:: ',num2str(classErr),'||LL==',num2str(LL),' for k==',num2str(k_best)));

%classErr_ls = nnz(binaryThresholdVector(y_predict_ls,0.5) - y_test)/length(y_test);
%disp('classErr is (least squares): ');
%disp(num2str(classErr_ls));
%disp(strcat('for k==',num2str(k_best_ls)));

figure;
plot(x_test, y_test, 'ro');
title('Test data');

%plot the predicted data:
%"unnormalize": z = (x-u)/s ==> x = z*s + u
stdy = std(y_test);
meany = mean(y_test); 
%y_predict_2f = stdy*y_predict_2f + meany;
%y_predict_ls = stdy*y_predict_ls + meany;
figure; 
plot(x_test, y_predict_2f, 'bo');
title('Predicted data - logistic regression');
figure; 
plot(x_test, binaryThresholdVector(y_predict_2f,0.5), 'ko');
title('Predicted data - logistic regression - thresholded');
%figure; 
%plot(x_test, y_predict_ls, 'bo');
%title('Predicted data - least squares');
%figure; 
%plot(x_test, binaryThresholdVector(y_predict_ls,0.5), 'ko');
%title('Predicted data - least squares - thresholded');