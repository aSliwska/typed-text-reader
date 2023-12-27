function [imresult] = preprocess(image)

% Przenieś obraz na odcienie szarości
im = rgb2gray(image) ;

% Odszumianie w dziedzinie obrazu skali szarości
im = medfilt2(im);

figure
imshow(im)

% Progowanie adaptacyjne daje lepsze wyniki dla zanieczyszczonego tekstu
T = adaptthresh(im, 0.99);
im = ~imbinarize(im,T);

% Wstępne odszumianie i usuwanie artefaktów
im = imclearborder(im);

im = imopen(im, ones(2));
im = imclose(im, ones(2));
im = medfilt2(im);

% Mocniejsze odszumianie z użyciem regionprops

props = regionprops(im,'Area');
S = cat(1, props.Area);

meanS = mean(S);
stdev = std(S);

label = bwlabel(im);

for i = 1:max(label, [], 'all')
    a = regionprops(label == i, 'Area');
    if abs(a.Area - meanS) / stdev > 1
        label(label==i) = 0;
    end
end

im = (label > 0);

figure
imshow(im)

imresult = im;


end