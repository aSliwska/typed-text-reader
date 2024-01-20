% Poniższy plik ma na celu trening modelu na obrazach dostarczonych w
% folderze images. Obrazy w folderze powinny być w formacie .png i mieć
% wymiar 32x32 (ewentualnie 32x32x3).
% Dane dzielone są na 3 zbiory: treningowy, walidacyjny oraz testowy w
% proporcji 8:1:1
% Proces treningu zostaje przedstawiony na wykresie
% Test modelu jest przedstawiony w macierzy konfuzji


clc; close all; clear;
addpath("..\Recognizer\Generator\images\");

% Załaduj wszystkie obrazy z folderu images do obiektu imageDatastore
imgDatastore = imageDatastore('..\Recognizer\Generator\images\', 'IncludeSubfolders', true, 'FileExtensions', {'.png'});

% Wydobądź etykiety (etykietą jest wartość liczbowa zawarta w nazwie pliku;
% tę wartość stanowią wszystkie znaki znajdujące się przed pierwszym
% wystąpieniem znaku '_'
% Przykładowo: etykietą obrazu o nazwie 65_domyslny_tekst.png jest 65.
imgDatastore.Labels = categorical(cellfun(@(filename) extractLabel(filename), imgDatastore.Files, 'UniformOutput', false));

% Podziel dane na zbiór treningowy, walidacyjny oraz testowy w sposób
% losowy
[trainData, valData, tData] = splitEachLabel(imgDatastore, 0.8, 0.1, 0.1, 'randomized');

%Augmentacja
% Specify data augmentation options
augmenter = imageDataAugmenter('RandRotation',[-5,5], 'RandScale',[0.5 1]);

% Create augmented datastores
augmentedTrainData = augmentedImageDatastore([32 32 1], trainData, ...
    'DataAugmentation',augmenter);

% Przygotuj dane treningowe
% Konwersja do odcieni szarości
imageData = cellfun(@(x) im2gray(imresize(imread(x), [32, 32])), augmentedTrainData.Files, 'UniformOutput', false);
% Konwersja do tablicy 4D
imageData = cat(4, imageData{:});
% Narmalizacja wartości pikseli [0, 1]
imageData = double(imageData) / 255;


% Przygotuj dane walidacyjne (wykorzystane do ulepszania modelu podczas
% treningu)
% Konwersja do odcieni szarości
validationData = cellfun(@(x) im2gray(imresize(imread(x), [32, 32])), valData.Files, 'UniformOutput', false);
% Konwersja do tablicy 4D
validationData = cat(4, validationData{:});
% Normalize the pixel values to be in the range [0, 1]
validationData = double(validationData) / 255;




% Przygotuj dane testowe (wykorzystane do sprawdzenia poprawności wytrenowanego modelu)
% Konwersja do odcieni szarości
testData = cellfun(@(x) im2gray(imresize(imread(x), [32, 32])), tData.Files, 'UniformOutput', false);
% Konwersja do tablicy 4D
testData = cat(4, testData{:});
% Znormalizuj wartości do zakresu [0, 1]
testData = double(testData) / 255;



%%%% ODKOMENTUJ JEŚLI CHCESZ TRENOWAĆ MODEL %%%%%
% Dostosowanie hiperparametrów
options = trainingOptions('adam', ...
    'MaxEpochs', 50, ...
    'MiniBatchSize', 128, ...
    'InitialLearnRate', 0.001, ...
    'Shuffle', 'every-epoch', ...
    'ValidationData', {validationData, valData.Labels}, ...
    'ValidationFrequency', 10, ...
    'Plots', 'training-progress', ...
    'CheckpointPath', tempdir, ...
    'ExecutionEnvironment', 'auto', ...
    'Verbose', false, ...
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropFactor', 0.1, ...
    'LearnRateDropPeriod', 10, ...
    'GradientThresholdMethod', 'absolute', ...
    'GradientThreshold', 0.05, ...
    'L2Regularization', 0.001);
    % 'OutputFcn', @(info, event)stopIfAccuracyNotImproving(info, event, 5)


% Architektura sieci
layers = [
    imageInputLayer([32 32 1])

    convolution2dLayer(3, 16, 'Padding', 'same')
    batchNormalizationLayer()
    reluLayer()
    maxPooling2dLayer(2, 'Stride', 2)

    convolution2dLayer(3, 32, 'Padding', 'same')
    batchNormalizationLayer()
    reluLayer()
    maxPooling2dLayer(2, 'Stride', 2)

    convolution2dLayer(3, 32, 'Padding', 'same')
    batchNormalizationLayer()
    reluLayer()
    maxPooling2dLayer(2, 'Stride', 2)

    flattenLayer()

    fullyConnectedLayer(256)

    % Zapobiegaj za dużym wagom 
    % fullyConnectedLayer(256, 'WeightLearnRateFactor', 10, 'WeightL2Factor', 1e-4)
    
    reluLayer()
    dropoutLayer(0.5)

    fullyConnectedLayer(52)
    softmaxLayer()
    classificationLayer()
];

% Trening sieci
net = trainNetwork(imageData, trainData.Labels, layers, options);

% Zapisz wytrenowany model
save('trainedModel_v6_dropout.mat', 'net');



%%%%% ODKOMENTUJ JEŚLI CHCESZ TRENOWAĆ MODEL - KONIEC %%%%%

%%%%% SPRAWDŹ POPRAWNOŚĆ MODELU %%%%%
% Wczytaj wytrenowany model
load('trainedModel_v6_dropout.mat', 'net');
tData.Labels = categorical(tData.Labels);

% Wykorzystaj wytrenowany model do określenia etykiet dla zbiory testowego
predictedLabels = classify(net, testData);

% Konwertuj etykiety do typu double
numericPredictedLabels = double(predictedLabels);

% Narysuj macierz konfuzji
confusionchart(tData.Labels,predictedLabels)


%  Funkcje -----------------------

function label = extractLabel(filename)
% Otrzymaj etykietę z obrazka (liczba przed znakiem '_')
[~, name, ~] = fileparts(filename);
underscoreIndex = strfind(name, '_');

if isempty(underscoreIndex)
    label = '';
else
    label = name(1:underscoreIndex(1)-1);
end
end

% Zatrzymaj trening jeśli accuracy się już nie poprawia
% function stop = stopIfAccuracyNotImproving(info, event, threshold)
% 
%     stop = false;
% 
%     Czy accuracy w walidacji się nie poprawiło
%     if info.State.Iteration > 1
%         currentAccuracy = info.ValidationAccuracy(end);
%         previousAccuracy = info.ValidationAccuracy(end - 1);
% 
%         Stop
%         if currentAccuracy <= previousAccuracy + threshold
%             stop = true;
%         end
%     end
% end

%-----------------------------------
