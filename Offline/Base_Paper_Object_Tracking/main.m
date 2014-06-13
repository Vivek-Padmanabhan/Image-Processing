clc;
clear all;
close all;
%% Video Input
[vid1, vid2, vid3, L, nr, nc, BG1] = acquire_video();
maxs = 30;
%% Subject Object Tracker
for ii = 25
    %5:5:L-5
    ii
    
    i1=read(vid1,ii);
    i2=read(vid2,ii); 
    
    subplot(231)
    imshow(i1);
    title('Left Video');
    axis image;
    
    I3 = superimposed_stereo(i1,i2);
    
    subplot(232)
    imshow(I3);
    title('Superimposed Stereo');
    axis image;

    bw1 = mask_background(BG1,vid3,i1,ii);
    
    subplot(234)
    imshow(bw1);
    title('Background Mask');
    axis image;
    
    [d] = stereo(i1,i2, maxs);
    
    subplot(233)
    imshow(d,[0 maxs]); 
    title('Filtered Disparity');
    axis image;
    
    subplot(236)
    imshow(i1);
    title('Object Tracking');
    axis image;
    
    Dim = track_objects(d,bw1,nr,nc);

    subplot(235)
    imshow(Dim,[0 maxs]);
    title('Depth Ordering');
    axis image;
    pause(0.0000001)
    
end