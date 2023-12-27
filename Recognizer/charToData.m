function data=charToData(char)

patterna = zeros([200,200,3]);

position = [100, 100];
patterna = insertText(patterna, position, char, FontSize=30,BoxOpacity=0, TextColor="white");
patterna = imbinarize(rgb2gray(patterna));
patterna = bwlabel(patterna);
sectors = max(patterna,[],"all");

Ma = zeros(sectors,17);

propsa = regionprops(patterna, "Extent", "EulerNumber", "Solidity", "Circularity", "Eccentricity", "Orientation","BoundingBox","MaxFeretProperties","MinFeretProperties","Extrema", "Centroid");

Ma(:,9) = cat(1,propsa.Extent);
Ma(:,10) = cat(1,propsa.EulerNumber);
Ma(:,11) = cat(1,propsa.Solidity);
Ma(:,12) = cat(1,propsa.Circularity);
Ma(:,13) = cat(1,propsa.Eccentricity);
Ma(:,14) = cat(1,propsa.Orientation);
bd = cat(1,propsa.BoundingBox);
Ma(:,15) = bd(:,3)./bd(:,4);

bd =  cat(1,propsa.BoundingBox);
Ma(:,16)  =  cat(1,propsa.MinFeretAngle);
Ma(:,17) =  cat(1,propsa.MaxFeretAngle);

% Kropki są brane pod uwagę w innych miejscach
if (char == "i" || char == "j")
    outidx = find(Ma(:,12) > 0.8);
    Ma(outidx,:) = [];
end

sectors = size(Ma,1);

fim = {@AO5RBlairBliss, @AO5RCircularityL, @AO5RCircularityS, @AO5RDanielsson, @AO5RFeret, @AO5RHaralick, @AO5RMalinowska, @AO5RShape};


for i = 1:sectors
    for j = 1:8
        Ma(i,j) = fim{j}(patterna == i);
    end
end

data = Ma';
end