%% Compute Stereo
%-----------------------------------------------------------------
% function [dsp_f dsp] = stereo(img_R,img_L, maxs)
%-----------------------------------------------------------------

function [fdsp dsp] = stereo(i1,i2, maxs)
  win_size  = 7; %-- size of window used when smoothing
  tolerance = 2; %-- how close R-L and L-R values need to be
  weight    = 5; %-- weight on gradients opposed to color
  
  %--determine pixel correspondence Right-to-Left and Left-to-Right
  [dsp1, diff1] = slide_images(i1,i2, 1, maxs, win_size, weight);
  [dsp2, diff2] = slide_images(i2,i1, -1, -maxs, win_size, weight);
  
  %--keep only high-confidence pixels
  dsp = winner_take_all(dsp1,diff1,dsp2,diff2,tolerance);
  
  %--try to eliminate bad pixesl
  fdsp = modefilt2(dsp,[win_size,win_size],2);
end
