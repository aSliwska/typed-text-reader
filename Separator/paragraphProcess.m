function [linesimout, letterArray, letterFlags] = paragraphProcess(paragraphImage)
            
            l = bwlabel(paragraphImage);
            
            % figure
            % imshow(im2);

            % Szukamy kropek, kropki są be
            areasUnfiltered = regionprops(paragraphImage, 'Area');
            areasUnfiltered = cat(1, areasUnfiltered.Area);
            
            avgArea = mean(areasUnfiltered);
            Areadev = std(areasUnfiltered);
            
            outlier = (areasUnfiltered - avgArea)./ Areadev; % Znak jest nam potrzebny, bo innym rodzajem artefaktu są wieloznaki!!
            
            t = -1.5; % Metodad NaOkowa

            % Find zwraca indeksy elementow ktore sa niezerowe
            outidx = find(outlier < t);

            % Backup który zawiera kropki przed operacją
            dots = l;
            
            % Usuwamy wszystkie wiersze ktore uznajemy za nietypowe
            l(ismember(l,outidx)) = 0; % usuwamy z obrazu binarnego
            dots(~ismember(dots,outidx)) = 0; % usuwamy wszystko poza kropkami

            % figure
            % imshow(dots)
            
            
            dotfree = l > 0;

            % figure
            % imshow(dotfree)

            % Mamy odszumiony, odkropkowany obraz jednego paragrafu, można
            % zacząć szukać linii

            labels = bwlabel(dotfree);
            properties = regionprops(labels, 'Centroid', 'BoundingBox');
           
            heights = cat(1,properties.BoundingBox);
            avgHeights = ceil(mean(heights(:,4)) / 2);
            
            % Musimy operowac na liczbach calkowitych
            yInts = round(cat(1,properties.Centroid));
            yInts = yInts(:,2);
            
            largestY = max(yInts,[],'all');
            
            % Sprawdzamy jakie wartosci y istnieja wsrod naszych centroidow
            % Nastepnie przeprowadzamy dylatacje na osi wysokosci, co rowna sie
            % zlaczeniu pobliskich sobie w y znakow w jeden obszar
            yArray = ismember(1:largestY, yInts);
            yArray = imdilate(yArray,ones(avgHeights));
            yArray = bwlabel(yArray);
            
            
            % figure;
            % plot(yArray);
            
            % Nakladamy obszary linii na nowy obraz wynikowy
            k = zeros(size(labels));
            
            for i = 1:size(yInts,1)
                sub = (labels == i) .* yArray(yInts(i));
                k = k + sub;
            end

            linesorig = k;
            
            
            % Grupujemy kropki do linii, kropka wskakuje do linii w której
            % jest na osiach y liter wielkich
            for line = 1:max(k, [], 'all')

                lineim = k == line;
                lineim = bwlabel(lineim);

                % figure
                % imshow(label2rgb(lineim,'jet','black','shuffle') )

                boxes = cat(1,regionprops(lineim, 'BoundingBox').BoundingBox);
                [minY, minIndex] = min(boxes(:,2),[],'all');
                minY = floor(minY);
                maxY = minY + boxes(minIndex,4);

                k(minY:maxY,:) = line;
            end

        
            dfilt = (dots > 0) .* k;
            

            

            % Mamy dwa obrazy wynikowe - obraz z liniami oraz kropkami
            % Label kropek odpowiada labelom tych linii do których naleza

            linesfull = linesorig + dfilt;

            % 
            % figure
            % imshow(label2rgb(linesfinal,'jet','black','shuffle') )

            boxes = cat(1,regionprops(linesorig, 'BoundingBox').BoundingBox);
            
            compositedLetters = zeros(size(linesfull));
            compositedFlags = [];

            letterLabel = 1;


            % Ostatni krok - przypisanie znaków diakrytycznych ich literom
            % Przechodzimy po każdej linii, mergujemy litery w linii + ich
            % kropki

            % Otrzymujemy poetykietowany obraz wynikowy w którym każda
            % etykieta przedstawia kolejną literę

            % linesrepo = {};

            for line = 1:max(linesorig, [], "all")

                

                lineim = imcrop(linesorig, boxes(line, :));
                lineim = bwlabel(lineim);

                linebox = boxes(line, :);
                

                lineprops = regionprops(lineim, 'BoundingBox', 'Image', 'Centroid');
                letterboxes = cat(1,lineprops.BoundingBox);

                
                % Projekcja na os x, mniej-więcej odnajduje granice slow
                lwidth = mean(letterboxes(:,3));
                projection = max(lineim > 0);
                projection = imclose(projection, true(1,floor(lwidth/1.25)));
                projection = bwlabel(bwmorph(projection, "thicken",inf));

                word = projection(1);




                % centroids = cat(1,lineprops.Centroid);

                % linevect = [];

                for letter = 1:max(lineim, [], "all")



                    % Przygotowujemy obrazek
                    % Szerokość litery
                    % Wysokość linii
                    % Osadzony na y linii, x litery w linii + x linii
                    letterboxLocal = letterboxes(letter, :);
                    letterbox = letterboxLocal;

                    if (projection(floor(letterbox(1)+1)) ~= word)
                        word = projection(floor(letterbox(1)+1));
                        compositedFlags(end + 1) = 1;
                    else
                        compositedFlags(end + 1) = 0;
                    end


                    letterbox(1) = floor(letterbox(1) + linebox(1));
                    letterbox(2) = floor(linebox(2));
                    letterbox(4) = linebox(4);

                    

                    letterImage = imcrop(linesorig, letterbox) + imcrop(dfilt, letterbox);
                    letterImage = letterImage > 0;
                    letterImage = letterImage * letterLabel;

                    cols = letterbox(1):(letterbox(1) + letterbox(3));
                    rows = letterbox(2):(letterbox(2) + letterbox(4));

                    compositedLetters(rows,cols) = letterImage;
                    
                    % figure
                    % imshow(letterImage)
                    % linevect(:, end + 1) = [letterLabel ; centroids(letter, 1)];
                    letterLabel = letterLabel + 1;
                end
               
            end

            

            % Mamy wszystkie fajne literki, teraz trzeba je przekonwertowac
            % do obrazu ktory zrozumie siec neuronowa


            letters = regionprops(compositedLetters, 'Image', 'BoundingBox');
            letterboxes = cat(1,letters.BoundingBox);

            letterimages = {};

            if (size(letterboxes, 2) > 0) % Tylko jeżeli w paragrafie znaleźliśmy cokolwiek
                maxWidth = max(letterboxes(:,3), [], 'all');
                maxHeight = max(letterboxes(:,4), [], 'all');
    
                maxDimension = ceil(1.25 * max([maxWidth, maxHeight], [], "all"));
    
                
    
                for i = 1:max(compositedLetters, [], 'all')
                    processedLetter = letters(i).Image > 0;
    
                    letterMold = zeros(maxDimension);
                    
                    sizes = size(processedLetter);
                    %letterProp = regionprops(processedLetter,
                    %'Centroid').Centroid; Centroidy daja gorsze wyniki
                    letterProp = sizes ./ 2;
    
                    dx =  floor(maxDimension / 2 - letterProp(1));
                    dy = floor(maxDimension / 2 - letterProp(2));
                    
                    dx=min(max(dx,1),inf);
                    dy=min(max(dy,1),inf);
                   
    
                    rangerows = dx:(dx + sizes(1) - 1);
                    rangecols = dy:(dy + sizes(2) - 1);
    
                    letterMold(rangerows, rangecols) = processedLetter;
    
                    
    
                    % Przed chwilą wycentrowaliśmy literę na kwadracie, teraz
                    % trzeba ją przeskalować
                    
                    letterMold = double(~letterMold);
                    letterMold = imresize(letterMold, [32,32]);

                    % imwrite(letterMold, strcat(num2str(i), ".png"))
    
                    letterimages{end + 1} = letterMold;
    
                    % figure
                    % imshow()
                end
            end

            letterFlags = compositedFlags;


            % Kod do debugowania programu

            % resultstring = "";

            %figure

            % for i = 1:size(letterimages,2)
            %     lett = ocr(letterimages{i},LayoutAnalysis="block",CharacterSet="QWERTYUIOPLKJHGFDSAZXCVBNMqwertyuioplkjhgfdsazxcvbnm0123456789");
            %     %figure
            %     %imshow(letterimages{i});
            %     if (compositedFlags(i) == 1)
            %         resultstring = append(resultstring, " ");
            %     end
            %     resultstring = append(resultstring, strtrim(lett.Text));
            % end

            % sprintf("Result: %s", resultstring)

            
            % figure
            % imshow(letterimages {3})
            % size(letterimages {3})
            
            % figure
            % imshow(label2rgb(compositedLetters,'jet','black','shuffle'));


            linesimout = label2rgb(compositedLetters,'jet','black','shuffle');
            letterArray = letterimages;



        end

