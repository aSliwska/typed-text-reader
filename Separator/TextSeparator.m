classdef TextSeparator
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
            [imParagraphs, imBinary] = preprocess(originalImage, denoiseLevel, letterMergeLevel, segmentationLevel, needsAdditionalDenoising);

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

            largestParagraph = ones(25);
            largestLines = ones(25);

            for i = 1:size(boxes, 1)

                % sprintf("Paragraph: %d", i)
                
                % Wytnij paragraf
                im2 = imcrop(imBinary, boxes(i, :));

                % Przetwarza jeden paragraf tekstu, przyjmuje obraz binarny
                % jako wejscie

                try
                    [improcess, letterArray, letterFlags, lines] = paragraphProcess(im2);


                    if (size(improcess,2) > size(largestParagraph, 2) && size(improcess, 1) > size(largestParagraph, 1))
                        largestParagraph = improcess;
                        largestLines = lines;
                    end
    
                    paragraph = {};
                    paragraph.images = letterArray;
                    paragraph.flags = letterFlags;
    
                    paragraphData{end + 1} = paragraph;
                catch ME
                    figure
                    imshow(im2)
                    ME

                end
            end


            % define return value
            segmentationResult = imBinary; 
            compositedLetters = largestParagraph;
            image3 = largestLines; 
            paragraphs = paragraphData;

        end
    end
end