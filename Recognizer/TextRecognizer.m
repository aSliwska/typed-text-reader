classdef TextRecognizer
    methods
        function resultText = recognize(obj, someInput, recognizerValues)

            load('trainedModel.mat', 'net');

            % Wczytaj obrazek - to tylko przykład dla jednego obrazka. My
            % powinniśmy dostać jako input tablicę z macierzami
            % reprezenującymi obrazki!!!

            imagePath = 'testImageA.png';
            inputImage = imread(imagePath);
            % Convert the image to grayscale
            inputImage = rgb2gray(inputImage);
            
            % Preprocess the image
            inputImage = imresize(inputImage, [32, 32]);
            inputImage = im2double(inputImage);
            
            % Ensure the image has the correct dimensions
            inputImage = reshape(inputImage, [32, 32, 1]);

            predictedLabel = classify(net, inputImage);
            textArray = char(str2double(char (predictedLabel)));
            
            % define return value
            resultText = textArray;
        end
    end
end


% classdef TextRecognizer
%     methods
%         function resultText = recognize(obj, someInput, recognizerValues)
% 
%             % if something goes wrong you'll get zeros
%             % in the recognizerValues cell array (but it shouldn't lol)
% 
%             % for now it'll be easier for you to edit what you get if you
%             % get a whole cell array, but once you tell me exactly what fields
%             % you'd like to have, then you won't have to map like this:
% 
%             slider3_value = recognizerValues{1};
%             slider4_value = recognizerValues{2};
%             editfield_value = recognizerValues{3};
%             doubleslider_value_min = recognizerValues{4}(1);
%             doubleslider_value_max = recognizerValues{4}(2);
% 
%             % idk what input you'll get from the separator, sorry 
%             someInput;
% 
% 
%             textArray = {'this is ' '   some text' '' 'mind the lack of commas in matlab arrays 😒'};
% 
%             % define return value
%             resultText = textArray;
%         end
%     end
% end