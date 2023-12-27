%
%   Algorytm separowania linii - Jakub Kawka - v2
%   Na podstawie laboratoriów 1-6 z dosypką dokumentacji Matlaba
%
%   Pewne zadania zdają się być niemożliwe, dopóki nie stoją na drodze do
%   3.0
%
% Boże miej w opiece tego kto będzie to musiał przepisać do pythona albo C


clear;
clc;
close all;

% Czytanie pliku

im = imread('tekst.png');
im = rgb2gray(im) ;
im = ~imbinarize(im);

% Trzeba odszukać paragrafy znaków aby uzyskać lepszą binaryzację

thick = imopen(im, ones(2));
thick = bwmorph(thick, 'thicken', 11);
thick = imfill(thick, "holes");
thick = imclose(thick, ones(6));
thick = imfill(thick, "holes");

% Wycięte regiony tekstu trzeba osobno zbinaryzować z lepszą dokładnością

l = bwlabel(thick);
% imshow(label2rgb(l));

boxes = cat(1,regionprops(thick, 'BoundingBox').BoundingBox);

im = imread('tekst.png');
im = rgb2gray(double(im) / 255);

paragraph = 2;

im = imcrop(im, boxes(paragraph, :));
im = ~imbinarize(im);

l = bwlabel(im);

% figure
% imshow(im);

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
imshow(fim) % Otrzymujemy obraz binarny bez kropek ktore psuja linie


l = bwlabel(fim);

% Musimy znać średnią wartość wysokości znaku


s = regionprops(l, 'centroid', 'BoundingBox');
centroids = cat(1,s.Centroid);
heights = cat(1,s.BoundingBox);

% Szukamy jak średnio wysokie są znaki
meanCharHeight = mean(heights(:,4)) + 3;

% Teraz czas na analizę dyskretną rozkładu y
yInt = round(heights(:,2));

processedHeight = round(max(yInt, [], 'all') + meanCharHeight);

% Trzeba zbudować histogram do szukania peaków
[counts, values] = histcounts(yInt, 'BinLimits', [1, processedHeight], 'BinWidth',1);


% Szukamy zakresów -height/height które są jednorodne

% figure
% histogram(yInt,'BinLimits', [1, processedHeight], 'BinWidth',1)

bincounts = logical(counts);
% bincounts(bincounts > 0) = 1;

% Morfologia obrazu 1D, wow
intHeight = round(meanCharHeight * 0.5);
bincounts = imdilate(bincounts, ones(intHeight));
bincounts = bwlabel(bincounts);

figure
plot(bincounts)

% Teraz każdemu centroidowi trzeba przypisać nowy sektor

sectorId = 1:size(s,1);
newNumber = zeros(1,[size(s,1)]);

for i = 1:size(s,1)
    newNumber(i) = bincounts(floor(yInt(i)));
end

for i = 1:size(s,1)
    l(l == i) = newNumber(i);
end

figure
imshow(label2rgb(l))



% vvvv otóż nie działa, ale zatrzymuję  gdyby pomysł się przydał

% Jak to działa? Przesuwamy przedział o szerokości dwóch znaków
% wycentrowany na kursorze
% W tym przedziale szukamy maksimum i jego indeksu, wpisujemy indeks do
% pamięci tam gdzie jest ono większe od poprzednich maksimów tych punktów
% Zamierzany efekt - peaki rezerwują punkty wokół siebie, mamy pewność że
% te peaki to znaki, a nie kropki lub przecinki, więc jednocześnie są one
% liniami

% for i = 1:processedHeight-1
%     lower = max([1, i - intHeight]);
%     upper = min([i + intHeight, processedHeight-1]);
%     neighbourHood = counts(lower:1:upper);
% 
%     [localMaximum, index] = max(neighbourHood, [], "all");
% 
%     actualMaxIndex = index + lower - 1;
% 
%     for j = lower:upper
%         if (localmax(j) < localMaximum && abs(localmaxindex(j) - j) > abs(localmaxindex(j) - actualMaxIndex) )
%             localmaxindex(j) = actualMaxIndex;
%             localmax(j) = localMaximum;
%         end
%     end
% end

% figure
% plot(localmaxindex)

% Teraz 'wystarczy' zastąpić labele w obrazie wartościami z histogramu


return

centroids(:,2)
size(im,2)
disc = discretize(centroids(:,2),1:meanCharHeight:max(centroids(:,2),[],'all')+meanCharHeight);

% figure
% histogram(disc)

% found = find(sum(disc,2) == 2);
% 

for le = 1:meanCharHeight:max(centroids(:,2),[],'all')+meanCharHeight
    l(round(le),:) = max(l,[],'all') + 1;
end

figure
imshow(label2rgb(l))
hold on
plot(centroids(:,1),centroids(:,2),'b*')
hold off

k = l;

for i = 1:max(disc,[],"all")
    found = find(sum(disc,2) == i);
    k(ismember(l,found)) = i;
end

bim2 = k > 0;

% figure
% imshow(label2rgb(k));







return
