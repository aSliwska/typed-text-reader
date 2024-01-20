% Ten skrypt służy do generowania dużej liczby obrazków potrzebnych do
% wytrenowania modelu. Zwróć uwagę gdzie uruchamiasz ten skrypt. Tam też
% powstanie folder wyjściowy. Upewnij się, że nie istnieje on już w twojej
% lokalizacji (np. sprawdź to komendą ls)

% Ustawienia
fontSize = 24;
imageSize = [32, 32];
outputFolderName = 'train';
fontTypes=["PLAIN", "BOLD", "ITALIC"];


% Do tego folderu dodaj wszystkie dliki .ttf czcionek, dla których chcesz
% wygenerować obrazki
% folderPath='fonts\'
% files = dir(fullfile(folderPath, '*.ttf'));
fonts=["Arial"];%,"Calibri", "Verdana", "Comic sans", "Times New Roman",...
    %"Garamond","Sitka Text","Cambria"];
% 
% for i=1:numel(fonts)
% 
%     font = java.awt.Font(fonts(i),  java.awt.Font.PLAIN, fontSize);
% end
% return;
types=["dilate", "normal", "rotateR", "rotateL", "moveR", "moveL", "moveU", "moveD"];

% Literki A-Z i a-z
letterRange = [65:90, 97:122];

% Generuj obrazki
for t_index = 1:numel(types)
    type=types(t_index);
    outputFolder = outputFolderName; %_'+types(t_index);

    %użyj tej nazwy, jeśli chcesz rozdzielić pliki na foldery według typu
    %outputFolder = outputFolderName+'_'+types(t_index); -

    if ~exist(outputFolder, 'dir')
        % Utwórz katalog, jeśli nie istnieje
        mkdir(outputFolder);
        disp(['Utworzono katalog: ' outputFolder]);
    else
        disp(['Katalog już istnieje: ' outputFolder]);
        % return;
    end

    for f = 1:length(fonts)
        % Iteruj po letterRange
        for i = letterRange
            % Iterate over font types
            for j = 1:3
                % Przygotuj nazwę obrazka
                outputPath = fullfile(outputFolder, sprintf('%d_%s_%s_%s.png', i, fonts(f), fontTypes(j), type));
                disp (outputPath);
                % Wygenerujobrazek
                generateLetterImage(char(i), fonts(f), fontSize, imageSize, outputPath, fontTypes(j), type);
            end
        end

    end
end


% Generowanie obrazu literki
function generateLetterImage(letter, fontPath, fontSize, imageSize, outputPath, fontType, type)
img = ones(imageSize, 'uint8') * 255; % Biały obraz
switch fontType
    case 'PLAIN'
        style = java.awt.Font.PLAIN;
    case 'BOLD'
        style = java.awt.Font.BOLD;
    case 'ITALIC'
        style = java.awt.Font.ITALIC;
    otherwise
        style = java.awt.Font.PLAIN;
end

font = java.awt.Font(fontPath, style, fontSize);

% Tworzenie obiektu do rysowania
imgBuffer = java.awt.image.BufferedImage(imageSize(2), imageSize(1), java.awt.image.BufferedImage.TYPE_INT_RGB);
graphics = imgBuffer.createGraphics();
graphics.setFont(font);

% Ustalanie pozycji dla środka litery
textBounds = graphics.getFontMetrics().getStringBounds(letter, graphics);
xPosition = round((imageSize(2) - textBounds.getWidth()) / 2);
yPosition = round((imageSize(1) - textBounds.getHeight()) / 2) + round(textBounds.getHeight()) - 6;

% Rysowanie litery na obrazie
graphics.setColor(java.awt.Color(0, 0, 0)); % Czarny kolor
graphics.fillRect(0, 0, imageSize(2), imageSize(1));
graphics.setColor(java.awt.Color(1, 1, 1)); % Biały kolor
graphics.drawString(letter, xPosition, yPosition);

% Konwersja obrazu Java BufferedImage na obraz MATLABa
imageData = typecast(imgBuffer.getData.getDataStorage, 'uint8');
imageData = reshape(imageData, [4, imageSize(2), imageSize(1)]);
imageData = permute(imageData(1:3, :, :), [3, 2, 1]);

% Wybierz typ przekształcenia podany jako argument fukcji
switch type
    case 'normal'
        ;
    case 'dilate'
        imageData = imdilate(imageData, ones(3));
    case 'rotateL'
        imageData = imrotate(imageData, 10);
    case 'rotateR'
        imageData = imrotate(imageData, -10);
    case 'moveR'
        imageData = imtranslate(imageData, [2, 0]);
    case 'moveL'
        imageData = imtranslate(imageData, [-2, 0]);
    case 'moveU'
        imageData = imtranslate(imageData, [0, -2]);
    case 'moveD'
        imageData = imtranslate(imageData, [0, 2]);
    otherwise
        error('Invalid transformation type');
end

imageData = 255 - imageData;

% Zapis obrazu
imwrite(imageData, outputPath);
end