classdef TextSeparator
    methods(Static)
        

        

    end


    methods
        function [segmentationResult, compositedLetters, image3, paragraphs] = separate(obj, originalImage, separatorValues)
            
            % if something goes wrong you'll get zeros here
            denoiseLevel = separatorValues{1};
            letterMergeLevel = separatorValues{2};
            segmentationLevel = separatorValues{3};
            slider4Value = separatorValues{4};
            needsAdditionalDenoising = separatorValues{5};


            % Przekaż obraz do algorytmu odszumiającego, parametr określa
            % agresję odszumiania
            [imParagraphs, imBinary] = preprocess(originalImage, denoiseLevel, letterMergeLevel);

            % figure
            % imshow(imParagraphs)

            

            
            
            % figure;
            % imshow(thick)

            % figure
            % imshow(imParagraphs);

            boxes = cat(1,regionprops(imParagraphs, 'BoundingBox').BoundingBox);

      
            % figure;
            
            % Potem dla każdego paragrafu tekstu, pętla

            paragraphData = [];

            for i = 1:size(boxes, 1)

                % sprintf("Paragraph: %d", i)
                
                % Wytnij paragraf
                im2 = imcrop(imBinary, boxes(i, :));

                % Przetwarza jeden paragraf tekstu, przyjmuje obraz binarny
                % jako wejscie
    
                [improcess, letterArray, letterFlags] = paragraphProcess(im2);

                if (i == 1)
                    resultImage = improcess;
                    imshow(resultImage);
                end

                paragraph = {};
                paragraph.images = letterArray;
                paragraph.flags = letterFlags;

                paragraphData{end + 1} = paragraph;
                

            end


            % define return value
            segmentationResult = imbinarize(rgb2gray(originalImage)); 
            compositedLetters = bwlabel(imbinarize(rgb2gray(originalImage)));
            image3 = imbinarize(rgb2gray(originalImage)); 
            paragraphs = paragraphData;

        end
    end
end