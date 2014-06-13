clc;
clear all;
close all;
%% Stereo Vision Video Cropping

vid1 = mmreader('D:\Final Year Project\Code Development\Datasets\i2iDatabase\IU\IU_Left.avi');
vid2 = mmreader('D:\Final Year Project\Code Development\Datasets\i2iDatabase\IU\IU_Right.avi');

for ii = 1:150
    
    i1 = read(vid1,ii);
    i2 = read(vid2,ii);
    
    mov1(ii).cdata = i1;
    mov1(ii).colormap = [];
    
    mov2(ii).cdata = i2;
    mov2(ii).colormap = [];
    
end

movie2avi(mov1, 'StudioSequence150Left1.avi', 'compression', 'None','fps',12)
movie2avi(mov2, 'StudioSequence159Right1.avi', 'compression', 'None','fps',12)