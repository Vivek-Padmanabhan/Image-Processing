%-----------------------------------------------------------------
% function dsp = stereo(img_R,img_L, maxs)
%
% 3D from stereo.  This function takes a stereo pair
% (that should already be registered so the only difference is in the
% 'x' dimension), and produces a 'disparity map.'  The output here is
% pixel disparity, which can be converted to actual distance from the
% cameras if information about the camera geometry is known.
% 
% The output here does show which objects are closer.
% Brighter = closer
%
% EXAMPLE:
% img_R = imread('tsuR.jpg');
% img_L = imread('tsuL.jpg');
% dsp = stereo_nofilter(img_R,img_L,20);
%
% Inputs:
%   img_R  = right image
%   img_L  = left image
%   maxs   = maximum pixel disparity.  (depends on image pair)
%
% Outputs:
%   dsp   = final disparity map (0 indicates bad pixel)
%
% Algorithm: 
% 1) Compute pixel disparity by comparing shifted versions of images.  
% 
% Coded by Shawn Lankton (http://www.shawnlankton.com) Feb. 2008
%-----------------------------------------------------------------

function [fdsp dsp] = stereo_nofilter(i1,i2, maxs)
  win_size  = 7; %-- size of window used when smoothing
  tolerance = 2; %-- how close R-L and L-R values need to be
  weight    = 5; %-- weight on gradients opposed to color
  
  %--determine pixel correspondence Right-to-Left and Left-to-Right
  [dsp1, diff1] = slide_images(i1,i2, 1, maxs, win_size, weight);
  [dsp2, diff2] = slide_images(i2,i1, -1, -maxs, win_size, weight);
  
  %--keep only high-confidence pixels
  dsp = winner_take_all(dsp1,diff1,dsp2,diff2,tolerance);
  
%%----- HELPER FUNCTIONS

%-- takes the best disparity when we're within tolerance
function pd = winner_take_all(d1,m1,d2,m2,tolerance,maxs)
  pixel_dsp = zeros(size(d1));               %-- initialize output
  idx1 = find(abs(d1-d2)<tolerance & m1<m2); %-- find where d1 is best
  idx2 = find(abs(d1-d2)<tolerance & m2<m1); %-- find where d2 is best
  pixel_dsp(idx1) = d1(idx1);                %-- fill with d1
  pixel_dsp(idx2) = d2(idx2);                %-- fill with d2
  pd = shift_image(pixel_dsp,5);             %-- shift to match i1

%-- slides images across each other to get disparity estimate
function [disparity mindiff] = slide_images(i1,i2,mins,maxs,win_size,weight)
  [dimy,dimx,c] = size(i1);
  disparity = zeros(dimy,dimx);    %-- init outputs
  mindiff = inf(dimy,dimx);    
  
  h = ones(win_size)/win_size.^2;  %-- averaging filter

  [g1x g1y g1z] = gradient(double(i1)); %-- get gradient for each image
  [g2x g2y g2z] = gradient(double(i2));
  
  step = sign(maxs-mins);          %-- adjusts to reverse slide
  for(i=mins:step:maxs)
    s  = shift_image(i2,i);        %-- shift image and derivs
    sx = shift_image(g2x,i);
    sy = shift_image(g2y,i);
    sz = shift_image(g2z,i);

    %--CSAD  is Cost from Sum of Absolute Differences
    %--CGRAD is Cost from Gradient of Absolute Differences
    diffs = sum(abs(i1-s),3);       %-- get CSAD and CGRAD

    gdiffx = sum(abs(g1x-sx),3);
    gdiffy = sum(abs(g1y-sy),3);
    gdiffz = sum(abs(g1z-sz),3);
    gdiff = gdiffx+gdiffy+gdiffz;
    
    CSAD  = imfilter(diffs,h);
    CGRAD = imfilter(gdiff,h);
    d = CSAD+weight*CGRAD;          %-- total 'difference' score
    
    idx = find(d<mindiff);          %-- put corresponding disarity
    disparity(idx) = abs(i);        %   into correct place in image
    mindiff(idx) = d(idx);
  end
  
%-- Shift an image
function I = shift_image(I,shift)
  dimx = size(I,2);
  if(shift > 0)
    I(:,shift:dimx,:) = I(:,1:dimx-shift+1,:);
    I(:,1:shift-1,:) = 0;
  else 
    if(shift<0)
      I(:,1:dimx+shift+1,:) = I(:,-shift:dimx,:);
      I(:,dimx+shift+1:dimx,:) = 0;
    end  
  end

