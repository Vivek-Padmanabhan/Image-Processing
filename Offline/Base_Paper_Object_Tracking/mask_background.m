%% Background Mask
%-----------------------------------------------------------------
% function bw1 = mask_background(BG1,vid3,i1,ii)
%-----------------------------------------------------------------
function bw1 = mask_background(BG1,vid3,i1,ii)
    Step = 5;
    %--Moving Mask
    bw1 = moving_mask(i1,BG1);
    bw1 = imfill(bw1,'holes');
    bw1 = bwareaopen(bw1,400);
    
    % --------------------------------------------------------
    if  mod(ii,5) ==0
        bw3 = read(vid3,1+floor(ii/Step));
        bw1 = im2bw(bw3,0.5);
    end
    % --------------------------------------------------------
end