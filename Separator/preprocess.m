function [imresult, imbin] = preprocess(image, agresjaFiltrowania, agresjaMergeowania, czuloscSegmentacji, dodatkowaSegmentacja, dodatkoweOtwarcie)

        close all

        % Przenieś obraz na odcienie szarości
        im = rgb2gray(image) ;

        % Popraw kontrast
        im = imadjust(im);

        segSens = dodatkoweOtwarcie / 100;
        
        % Progowanie adaptacyjne daje lepsze wyniki dla zanieczyszczonego tekstu
        T = adaptthresh(im, segSens, 'NeighborhoodSize', 65, 'ForegroundPolarity', 'dark');
        im = ~imbinarize(im,T);


        % Odszumianie
        
        agresjaFiltrowania = ceil(agresjaFiltrowania / 100 * 10);

   
        % Wstępne odszumianie i usuwanie artefaktów
        im = imclearborder(im);

        if (agresjaFiltrowania > 1)
            im = imopen(im, ones(agresjaFiltrowania));
            im = medfilt2(im);
        end

        

        im = imclearborder(im);

        
        % Regionprops do ustalenia parametrów liter

        im = bwlabel(im);
        props = regionprops(im,'BoundingBox', 'Area');
       
        S = cat(1, props.BoundingBox);
        meanH = round(mean(S(:,4)));

        % Filtr zanieczyszczen - usuwa obszary o polu znacznie mniejszym od
        % pola sredniej litery, kropki srednio nie wchodza w ta kategorie
        P = cat(1, props.Area);
        meanP = mean(P);
        devP = std(P);
        outlier = (P - meanP)./ devP;
        outidx = find(outlier < -2.5);
        im(ismember(im,outidx)) = 0;
        
        im = (im > 0);

        mergeCoeff = round(meanH / 4 * (agresjaMergeowania / 100));

        if (mergeCoeff > 1)
            im = imdilate(im, ones(mergeCoeff));
        end

        % Drugi pass, trzeba znaleźć obiekty które odstają
        % wielkością/innymi parametrami od liter i jeszcze raz
        % przeprowadzić na tych obszarach segmentację (aby np. pozbyć się
        % wieloznaków, nie wszystkich ale części)


        
        

        if (dodatkowaSegmentacja == 1)
            im = bwlabel(im > 0);
            props = regionprops(im, 'BoundingBox');
            boxes = cat(1, props.BoundingBox);
            widths = cat(1, props.BoundingBox);
            widths = widths(:, 3);

            meanWidths = mean(widths);
            devWidths = std(widths);
            outlier = (widths - meanWidths)./ devWidths;
            outlier = (outlier > 1.5);
    
            for i = 1:size(outlier,1)
                if (outlier(i) == 1)
    
                    box = boxes(i,:);
                    originalImageSample = rgb2gray(imcrop(image, box));
    
                    filtSize = ceil(size(originalImageSample,2));
    
                    if (mod(filtSize,2) == 0)
                        filtSize = filtSize - 1;
                    end
    
                    T = adaptthresh(originalImageSample, segSens - 0.05, 'NeighborhoodSize', filtSize, 'ForegroundPolarity', 'dark');
                    originalImageSample = ~imbinarize(originalImageSample,T);

                    originalImageSample = imopen(originalImageSample, ones(agresjaFiltrowania));
    
                    startingX = ceil(box(2));
                    startingY = ceil(box(1));
    
                    widthX = startingX + size(originalImageSample, 1) - 1;
                    widthY = startingY + size(originalImageSample, 2) - 1;
    
                    originalImageSample = imclose(originalImageSample, ones(2));
                    originalImageSample = bwmorph(originalImageSample, "thicken", mergeCoeff);
    
    
                    im(startingX:widthX, startingY:widthY) = originalImageSample;
    
                    % figure
                    % imshow(originalImageSample)
    
                end
    
            end
   
        end

        im = im > 0;

        % Wieloznaki po części wyfiltrowane, do szukania bardziej
        % wyrafinowanych przypadków potrzebna byłaby sieć neuronowa



        % figure
        % imshow(im);


        imbin = im;

        % return;

        % figure
        % imshow(imbin);
        % figure

        
        
        % figure
        % imshow(im)

        % Wydobycie paragrafów tekstu z obrazka (nowy parametr?)

        thick = bwmorph(im, 'thicken', round(meanH / 2));
        thick = imfill(thick, "holes");
        thick = imclose(thick, ones(round(meanH)));
        thick = imfill(thick, "holes");

        thick = imclearborder(thick);
        
        imresult = thick;
        
        
        end
