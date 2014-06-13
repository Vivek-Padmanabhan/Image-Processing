clc;
clear all;
close all;
%% Test Superimposed Stereo

vid1 = mmreader('D:\Final Year Project\Code Development\Datasets\MDatabase\StudioSequenceLeft0.avi');
vid2 = mmreader('D:\Final Year Project\Code Development\Datasets\MDatabase\StudioSequenceRight0.avi');

for ii = 1:300
    
    i1 = read(vid1,ii);
    i2 = read(vid2,ii);
    
    I1 = rgb2gray(i1);
    I2 = rgb2gray(i2);
    
    I3 = cat(3,I1,I2,I2);
    
    imshow(I3)
    
end