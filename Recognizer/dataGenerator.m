clear;
clc;
close all;

setSize = 17;

chars = ['0':'9', 'A':'Z'];

dataMatrix = zeros(400,setSize,strlength(chars));

for char = 1:strlength(chars)
    sprintf("Now processing: %c ",chars(char))
    dataMatrix(:,:,char) = MakeCharDataset(chars(char));
end

save("dataMatrix.mat",'dataMatrix')


% dataA = MakeCharDataset("a");
% dataB = MakeCharDataset("b");
% 
% n1 = size(dataA,1);
% n2 = size(dataB,1);
% 
% uin = [dataA(1:end-100, :) ; dataB(1:end-100,:)]'; % Transpozycja, bo chce pionowy wektor!!
% uout = [repmat([1;0], 1, n1-100), repmat([0;1], 1, n2-100)];
% 
% % Dane do testowania - do sprawdzania modelu, nie podlega nauce!
% tin = [dataA(end-99:end, :) ; dataB(end-99:end,:)]';
% tout = [repmat([1;0], 1, 99), repmat([0;1], 1, 99)];
% 
% % Zbudowanie sieci
% nn = feedforwardnet();
% 
% % Trenowanie sieci
% nn = train(nn, uin, uout);
% 
% % Mamy narzedzie, pytanie czy dziala ~ jt
% round(nn(tin))
