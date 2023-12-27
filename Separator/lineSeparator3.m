%
%   Algorytm morfologicznego separowania linii - Jakub Kawka - v3
%   Na podstawie laboratoriów 1-6 z dosypką dokumentacji Matlaba i kofeiny
%
%   Pewne zadania zdają się być niemożliwe, dopóki nie stoją na drodze do
%   3.0
%
% Boże miej w opiece tego kto będzie to musiał przepisać do pythona albo C


clear;
clc;
close all;

% Czytanie pliku

plik = 'skan.jpg';

im = imread(plik);


oim = im;

im = preprocess(im);


figure
imshow(im)




% Trzeba odszukać paragrafy znaków aby uzyskać lepszą binaryzację



thick = bwmorph(thick, 'thicken', 5);
thick = imfill(thick, "holes");
thick = imclose(thick, ones(5));
thick = imfill(thick, "holes");


% Wycięte regiony tekstu trzeba osobno zbinaryzować z lepszą dokładnością

l = bwlabel(thick);
% imshow(label2rgb(l));

%imshow(thick)

boxes = cat(1,regionprops(thick, 'BoundingBox').BoundingBox);

im = oim;
im = double(rgb2gray(im)) / 255; 

% figure;


paragraph = 1;

im = imcrop(im, boxes(paragraph, :));
im = ~imbinarize(im);

l = bwlabel(im);

figure
imshow(im);

% Teraz dzielimy tekst na linie

% Trzeba odszukać linie znaków
% Aby to zrobić, potrzeba odpowiednio pudełkować wartości

% Najpierw należy wyfiltrować kropki, przecinki i kreski. Będą
% charakteryzować się bardzo niskim polem

areasUnfiltered = regionprops(im, 'Area');
areasUnfiltered = cat(1, areasUnfiltered.Area);

avgArea = mean(areasUnfiltered);
Areadev = std(areasUnfiltered);

outlier = (areasUnfiltered - avgArea)./ Areadev; % Znak jest nam potrzebny, bo innym rodzajem artefaktu są wieloznaki!!

t = -1.5; % Metodad NaOkowa

% Find zwraca indeksy elementow ktore sa niezerowe
outidx = find(outlier < t);

% Usuwamy wszystkie wiersze ktore uznajemy za nietypowe
l(ismember(l,outidx)) = 0; % usuwamy z obrazu binarnego
fim = l > 0;

figure
imshow(fim) % Otrzymujemy obraz binarny bez kropek i kresek ktore moga 'podszyc' sie za linie tekstu

labels = bwlabel(fim);
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


figure;
plot(yArray);

% Nakladamy obszary linii na nowy obraz wynikowy
k = zeros(size(labels));

for i = 1:size(yInts,1)
    sub = (labels == i) .* yArray(yInts(i));
    k = k + sub;
end

figure

imshow(label2rgb(k,'jet','black','shuffle') )







