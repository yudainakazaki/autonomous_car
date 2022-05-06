%read the training data and test data from csv files
%make the matrix of targets
datasetu = actuallyMakeDataset();
labels = datasetu(1:end, 1);
targets=dummyvar(labels);
 
%change the size of the training data set
inputs = datasetu (1:end, 2:end);

%transpose the matrices
inputs = inputs';
targets = targets';

%create and show neural networks; write about it
net = patternnet (10);
view(net);

%start training the neural networks
net = train(net, inputs, targets);
 
%execute a test with the inputs
predicted = net(inputs);

%plot the confusion matrix
plotconfusion(targets,predicted);

%This part is for plotting the graph with 439 sample sizes.
%In this case, the function was declared as function[n] for return value
%n = 1 - confusion(targets,predicted)