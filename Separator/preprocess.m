function [imresult, imbin] = preprocess(image, agresjaFiltrowania, agresjaMergeowania)

        % Przenieś obraz na odcienie szarości
        im = rgb2gray(image) ;

        if (agresjaFiltrowania < 5)
            agresjaFiltrowania = 5;
        end
        
        

        agresjaFiltrowania = ceil(agresjaFiltrowania / 100 * 4);

        
        % Odszumianie w dziedzinie obrazu skali szarości
        % im = medfilt2(im);

        % figure;
        % imshow(edges)

        im = imadjust(im);
        
        % figure
        % imshow(im)
        
        % Progowanie adaptacyjne daje lepsze wyniki dla zanieczyszczonego tekstu
        T = adaptthresh(im, 0.9, 'NeighborhoodSize', 55);
        im = ~imbinarize(im,T);


        
        % Wstępne odszumianie i usuwanie artefaktów
        im = imclearborder(im);
        im = imopen(im, ones(agresjaFiltrowania));
        im = imclose(im, ones(agresjaFiltrowania));
        % im = medfilt2(im);
        im = imclearborder(im);

        % figure
        % imshow(im)

        
        
        % Regionprops do ustalenia parametrów liter
        
        props = regionprops(im,'BoundingBox');
        S = cat(1, props.BoundingBox);

        meanH = round(mean(S(:,4)));

        mergeCoeff = round(meanH * (agresjaMergeowania / 100));

        if (mergeCoeff > 1)
            im = imclose(im, ones());
        end


        

        imbin = im;

        % figure
        % imshow(imbin);

        
        
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
