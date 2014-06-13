clear all;
close all;
clc;
%% Run this to demo stereo disparity extraction

vid1 = mmreader('D:\Final Year Project\Code Development\Datasets\DrDoDatabase\StudioSequence150Left1.avi');
vid2 = mmreader('D:\Final Year Project\Code Development\Datasets\DrDoDatabase\StudioSequence150Right1.avi');

maxs = 75; %maximum disparity between the two images
for ii = 25
    i1 = read(vid1,ii);
    i2 = read(vid2,ii);

    

    %-- here's the main call
    [d p] = stereo(i1,i2, maxs);

    %--  Display stuff
    subplot(2,2,1), imshow(i2); title('left image');
    subplot(2,2,2), imshow(i1); title('right image');
    subplot(2,2,3), imagesc(p); title('original disparity'); axis image;
    subplot(2,2,4), imagesc(d); title('filtered disparity'); axis image;
    pause(0.0001)
end
