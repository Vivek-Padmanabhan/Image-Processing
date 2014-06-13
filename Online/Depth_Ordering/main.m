clc;
clear all;
close all;
%%
delete(imaqfind)

% construct
vid1=videoinput('winvideo',1,'YUY2_320x240');

% cam_spec = imaqhwinfo('winvideo');

% Modify the color space used for the data — To change the color space of the returned image data, set the value of the ReturnedColorSpace property.
set(vid1,'ReturnedColorSpace','rgb');

% Trigger configuration
triggerconfig(vid1,'manual');
set(vid1,'FramesPerTrigger',1 );
set(vid1,'TriggerRepeat', Inf);

% Start webcam
start(vid1);

%construct
vid2=videoinput('winvideo',2,'YUY2_320x240');



% Modify the color space used for the data — To change the color space of the returned image data, set the value of the ReturnedColorSpace property.
set(vid2,'ReturnedColorSpace','rgb');

% Trigger configuration
triggerconfig(vid2,'manual');
set(vid2,'FramesPerTrigger',1 );
set(vid2,'TriggerRepeat', Inf);

% Start webcam
start(vid2);

%% Background model
%% 
L =30;
% Webcam 1
trigger(vid1);
im=getdata(vid1,1); % Get the frame in im
[nr nc nm ] = size(im);
nf = L;
frames = zeros(nr,nc,nm,L);
for ii = 1:L 
    ii
    trigger(vid1);
    im=getdata(vid1,1); % Get the frame in im
    frames(:,:,:,ii) = im;
end

BG1 = update_background(frames);

% WEbcam2
trigger(vid2);
im=getdata(vid2,1); % Get the frame in im
[nr nc nm ] = size(im);
nf = L;
frames = zeros(nr,nc,nm,L);
for ii = 1:L 
    ii
    trigger(vid2);
    im=getdata(vid2,1); % Get the frame in im
    frames(:,:,:,ii) = im;
end

BG2 = update_background(frames);

%%
maxs = 30;
for ii = 1:1000

    % Acquire the image
    trigger(vid2);
    i1=getdata(vid2,1); % Get the frame in im
    % Acquire the image
    trigger(vid1);
    i2=getdata(vid1,1); % Get the frame in im
    
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