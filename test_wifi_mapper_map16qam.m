
%clear all
%addpath('../')

rand('seed',3)

%Generate random bitstream:
input_bits = round(rand(192,1));

symbols = wifi_mapper_map64qam(input_bits)
