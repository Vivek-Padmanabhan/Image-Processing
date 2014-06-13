%% Video Acquisition
%-----------------------------------------------------------------
% function [vid1, vid2, vid3, L, nr, nc, BG1] = acquire_video()
%-----------------------------------------------------------------
function [vid1, vid2, vid3, L, nr, nc, BG1] = acquire_video()
    %--Create Video Object
    vid1 = mmreader('D:\Final Year Project\Code Development\Datasets\i2iDatabase\IU\IU_Left.avi');
    vid2 = mmreader('D:\Final Year Project\Code Development\Datasets\i2iDatabase\IU\IU_Right.avi');
    vid3 = mmreader('D:\Final Year Project\Code Development\Datasets\i2iDatabase\IU\IU_GT_motion_every5frames.avi');
    %--Get Number of Frames
    L = get(vid1, 'NumberOfFrames');
    %--Get Number of Rows & Columns
    im=read(vid1,1); 
    [nr nc nm] = size(im);
    %--Get Frames
    frames = zeros(nr,nc,nm,L);
    for ii = 1:L 
        ii
        im=read(vid1,ii);
        frames(:,:,:,ii) = im;
    end
    %--Update Background
    BG1 = update_background(frames);
end