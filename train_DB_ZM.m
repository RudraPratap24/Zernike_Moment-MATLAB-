imageFolder = 'D:\Session2\Dorsal';
images = dir(fullfile(imageFolder, '*.png'));
order = 4;

numImages = numel(images);
numTrain = round(0.8 * numImages);
trainIdx = randperm(numImages, numTrain);
testIdx = setdiff(1:numImages, trainIdx);

trainFeatures = [];
for i = 1:numTrain
    img = imread(fullfile(imageFolder, images(trainIdx(i)).name));
    grayImg = rgb2gray(img);
    
    grayImg = double(grayImg);
    [rows, cols] = size(grayImg);
    [X, Y] = meshgrid(1:cols, 1:rows);
    R = sqrt((2*X-cols-1).^2 + (2*Y-rows-1).^2) / rows;
    Theta = atan2((rows-1-2*Y+2), (2*X-cols+1-rows));
    
    zm = zeros(1, order^2);
    for n = 0:order
        for m = -n:2:n
            v = zeros(size(R));
            for s = 0:(n-abs(m))/2
                c = (-1)^s * factorial(n-s) / (factorial(s) * factorial((n+abs(m))/2 - s) * factorial((n-abs(m))/2 - s));
                v = v + c * R.^(n-2*s);
            end
            zm(n^2 + n + m + 1) = sum(sum(grayImg .* v .* cos(m*Theta))) * (n + 1) / (pi * rows^2); % Use cos instead of exp
        end
    end

    trainFeatures = [trainFeatures; zm(:)'];
end

if size(trainFeatures, 1) < 2
    disp('Not enough training features for clustering');
    return;
end

testFeatures = [];
for i = 1:numel(testIdx)
    img = imread(fullfile(imageFolder, images(testIdx(i)).name));
    grayImg = rgb2gray(img);

    grayImg = double(grayImg);
    [rows, cols] = size(grayImg);
    [X, Y] = meshgrid(1:cols, 1:rows);
    R = sqrt((2*X-cols-1).^2 + (2*Y-rows-1).^2) / rows;
    Theta = atan2((rows-1-2*Y+2), (2*X-cols+1-rows));
    
    zm = zeros(1, order^2);
    for n = 0:order
        for m = -n:2:n
            v = zeros(size(R));
            for s = 0:(n-abs(m))/2
                c = (-1)^s * factorial(n-s) / (factorial(s) * factorial((n+abs(m))/2 - s) * factorial((n-abs(m))/2 - s));
                v = v + c * R.^(n-2*s);
            end
            zm(n^2 + n + m + 1) = sum(sum(grayImg .* v .* cos(m*Theta))) * (n + 1) / (pi * rows^2); % Use cos instead of exp
        end
    end

    testFeatures = [testFeatures; zm(:)'];
end


truthTables = randi([1, 2], size(testFeatures, 1), 1);

tree = linkage(trainFeatures, 'complete');

numClusters = 2; 

clusters = cluster(tree, 'MaxClust', numClusters);

classLabels = zeros(size(clusters));
for i = 1:numClusters
    classLabels(clusters == i) = i;
end

predictedLabels = zeros(size(testFeatures, 1), 1);
for i = 1:size(testFeatures, 1)
    distances = pdist2(testFeatures(i, :), trainFeatures, 'euclidean');
    [~, minIdx] = min(distances);
    predictedLabels(i) = classLabels(minIdx);
end


C = confusionmat(predictedLabels, truthTables);

% Calculate True Positive, True Negative, False Positive, False Negative
TP = C(1,1);
TN = C(2,2);
FP = C(2,1);
FN = C(1,2);

% Compute accuracy
accuracy = (TP + TN) / sum(C(:));

errorRate = 1 - accuracy;

% Display accuracy
disp(['Accuracy: ', num2str(accuracy)]);

disp(['Error Rate:', num2str(errorRate)]);


