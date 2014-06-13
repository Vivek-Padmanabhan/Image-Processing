clear all;
close all;
clc;
%% Run this to demo stereo disparity extraction
delete(imaqfind)

% construct
vid1=videoinput('winvideo',1,'YUY2_320x240');

% Modify the color space used for the data — To change the color space of the returned image data, set the value of the ReturnedColorSpace property.
set(vid1,'ReturnedColorSpace','rgb');

% Trigger configuration
triggerconfig(vid1,'manual');
set(vid1,'FramesPerTrigger',1 );
set(vid1,'TriggerRepeat', Inf);

% Start webcam
start(vid1);

% construct
vid2=videoinput('winvideo',2,'YUY2_320x240');



% Modify the color space used for the data — To change the color space of the returned image data, set the value of the ReturnedColorSpace property.
set(vid2,'ReturnedColorSpace','rgb');

% Trigger configuration
triggerconfig(vid2,'manual');
set(vid2,'FramesPerTrigger',1 );
set(vid2,'TriggerRepeat', Inf);

% Start webcam
start(vid2);

maxs = 50; %maximum disparity between the two images
for ii = 1:100
    
    % Acquire the image
    trigger(vid2);
    i1=getdata(vid2,1); % Get the frame in im
    % Acquire the image
    trigger(vid1);
    i2=getdata(vid1,1); % Get the frame in im

    

    %-- here's the main call
    [d p] = stereo(i1,i2, maxs);

    %--  Display stuff
    subplot(2,2,1), imshow(i2); title('left image');
    subplot(2,2,2), imshow(i1); title('right image');
    subplot(2,2,3), imagesc(p); title('original disparity'); axis image;
    subplot(2,2,4), imagesc(d); title('filtered disparity'); axis image;
    pause(0.0001)
end
