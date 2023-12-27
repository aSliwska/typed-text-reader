%
%   Algorytm separowania linii - Jakub Kawka - v1
%


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

paragraph = 1;

im = imcrop(im, boxes(paragraph, :));
im = ~imbinarize(im);

% figure
% imshow(im);

% Teraz dzielimy tekst na linie

% Trzeba odszukać linie znaków
% Aby to zrobić, potrzeba odpowiednio pudełkować wartości
% Musimy znać średnią wartość wysokości znaku

l = bwlabel(im);
s = regionprops(l, 'centroid', 'BoundingBox');
centroids = cat(1,s.Centroid);
heights = cat(1,s.BoundingBox);


% Szukamy jak średnio wysokie są znaki

meanCharHeight = mean(heights(:,4)) + 3;

% Szukamy znaku w lewym górnym rogu
manhattan = heights(:,2) + heights(:,1);
[a, idx] = min(manhattan, [], 'all');
firstChar = heights(idx,2);


% centroids(:,2) = centroids(:,2) - firstChar + 0.5 * meanCharHeight;



figure
histogram(centroids(:,2),'BinWidth',  1)

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




% Zaznaczamy wszystkie odkryte znaki


% Szukamy centroidów znaków oraz ich obwódek
s = regionprops(im, 'centroid', 'BoundingBox');
centroids = cat(1,s.Centroid);
heights = cat(1,s.BoundingBox);

meanCharHeight = mean(heights(:,4));

subplot(1,2,2)


figure
histogram(centroids(:,2),'BinWidth',  meanCharHeight)