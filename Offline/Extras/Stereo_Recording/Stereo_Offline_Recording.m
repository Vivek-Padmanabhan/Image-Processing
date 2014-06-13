clc;
clear all;
close all;
%% Superimposed Stereo Re-recording

vid1 = mmreader('D:\Final Year Project\Code Development\Datasets\i2iDatabase\IU\IU_Left.avi');
vid2 = mmreader('D:\Final Year Project\Code Development\Datasets\i2iDatabase\IU\IU_Right.avi');

for ii = 1:150
    
    i1 = read(vid1,ii);
    i2 = read(vid2,ii);
    
    I1 = rgb2gray(i1);
    I2 = rgb2gray(i2);
    
    I3 = cat(3,I1,I2,I2);
    
    mov(ii).cdata = I3;
    mov(ii).colormap = [];
    
end

movie2avi(mov, 'Stereo150Sequence.avi', 'compression', 'None','fps',12)