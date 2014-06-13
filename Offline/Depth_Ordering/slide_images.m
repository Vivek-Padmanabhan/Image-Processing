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
  