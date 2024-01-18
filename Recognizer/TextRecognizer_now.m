load('trainedModel.mat', 'net');

[testImages, testLabels] = preprocessImages('standarized');

% Convert validation images to 4D (Height x Width x Channels x NumImages)
testImages = permute(testImages, [1, 2, 4, 3]); % Rearrange dimensions

% Predict labels for validation images using the trained model
predictedLabels = classify(net, testImages);

% Convert predicted labels to numeric values (assuming they are categorical)
numericPredictedLabels = double(predictedLabels);

% Draw confusion matrix for validation and predicted labels
confusionchart(testLabels,predictedLabels)



%  Functions ----------------------- 

function [images, labels] = preprocessImages(directory)
    files = dir(fullfile(directory, '*.png'));
    images = zeros(32, 32, numel(files), 'uint8');
    labels = strings(numel(files), 1);

    for i = 1:numel(files)
        filename = files(i).name;
        [~, nameWithoutExt, ~] = fileparts(filename);

        underscoreIndex = strfind(nameWithoutExt, '_');

        if ~isempty(underscoreIndex)
            charactersBeforeUnderscore = nameWithoutExt(1:underscoreIndex(1)-1);
            % disp(['Characters before underscore in "', filename, '": ', charactersBeforeUnderscore]);
            originalImage = imread(fullfile(directory, filename));
            rescaledImage = imresize(originalImage, [32, 32]);
            
            % rescaledImage = rgb2gray(rescaledImage);
            rescaledImage = im2gray(rescaledImage);
            images(:, :, i) = double(rescaledImage);
            labels(i) = char(str2double(charactersBeforeUnderscore));
        else
            % disp(['No underscore found in "', filename, '"']);
        end
    end
    labels=categorical(labels);
end