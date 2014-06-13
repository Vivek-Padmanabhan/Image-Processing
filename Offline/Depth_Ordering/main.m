clc;
clear all;
close all;
%% Run this to demo stereo disparity extraction

vid1 = mmreader('D:\Final Year Project\Code Development\Datasets\customDatabase\StudioSequenceRight.avi');
vid2 = mmreader('D:\Final Year Project\Code Development\Datasets\customDatabase\StudioSequenceLeft.avi');
    
%% Background model
%% 
L =30;
% Webcam 1
im = read(vid1,1);
[nr nc nm ] = size(im);
frames = zeros(nr,nc,nm,L);
for ii = 1:L 
    ii
    im = read(vid1,ii);
    frames(:,:,:,ii) = im;
end

BG1 = update_background(frames);

% Webcam 2
im = read(vid2,1);
[nr nc nm ] = size(im);
frames = zeros(nr,nc,nm,L);
for ii = 1:L 
    ii
    im = read(vid2,ii);
    frames(:,:,:,ii) = im;
end

BG2 = update_background(frames);

%%
maxs = 30;
for ii = 1:1000

    % Acquire the image
    i1 = read(vid1,ii);
    % Acquire the image
    i2 = read(vid2,ii);
    
    subplot(231)
    imshow(i1)
    subplot(232)
    imshow(i2)
    
    % moving mask
    bw1 = moving_mask1(i1,BG2);
    bw2 = moving_mask1(i2,BG1);
    
    subplot(234)
    imshow(bw1)
    subplot(235)
    imshow(bw2)
    
    [d p] = stereo(i1,i2, maxs);
    subplot(233)
    imagesc(d,[0 maxs]);
    title('filtered disparity');
    axis image;
    D1 = d.*bw1;
    D1 = cluster(D1,bw1);
    subplot(236)
    imshow(D1,[0 maxs]);
end