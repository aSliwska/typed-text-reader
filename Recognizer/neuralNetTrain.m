clear;
clc;
close all;

load('dataMatrix.mat');

% Macierz nauki



% Macierz testowania
uin = [];
uout = [];

for i = 1:size(dataMatrix,3)
    uin = [uin ; dataMatrix(1:end-100,:,i)];

    id = zeros(size(dataMatrix,3),1);
    id(i) = 1;
    identifier = repmat(id, 1, 300);

    uout = [uout identifier];
end

tin = [];
tout = [];

for i = 1:size(dataMatrix,3)
    tin = [tin ; dataMatrix(end-99:end,:,i)];

    id = zeros(size(dataMatrix,3),1);
    id(i) = 1;
    identifier = repmat(id, 1, 100);

    tout = [tout identifier];
end

uin = uin';
tin = tin';

% Zbudowanie sieci



nn = feedforwardnet(50)
% 
% % Trenowanie sieci
nn = train(nn, uin, uout)

save("nn.mat",'nn')


