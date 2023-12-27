clear;
clc;
close all;

load('nn.mat');
letter = charToData('K')


chars = ['0':'9', 'A':'Z', 'a':'z'];

[max, index] = max(nn(letter),[],'all');

chars(index)