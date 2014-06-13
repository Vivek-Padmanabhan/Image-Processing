%% Disparity
%-----------------------------------------------------------------
% function pd = winner_take_all(d1,m1,d2,m2,tolerance,maxs)
%-----------------------------------------------------------------

function pd = winner_take_all(d1,m1,d2,m2,tolerance,maxs)

  %-- initialize output
  pixel_dsp = zeros(size(d1));
  
  %-- find where d1 is best
  idx1 = find(abs(d1-d2)<tolerance & m1<m2); 
  
  %-- find where d2 is best
  idx2 = find(abs(d1-d2)<tolerance & m2<m1); 
  
  %-- fill with d1
  pixel_dsp(idx1) = d1(idx1);       
  
  %-- fill with d2
  pixel_dsp(idx2) = d2(idx2);                
  
  %-- shift to match i1
  pd = shift_image(pixel_dsp,5);            
  
end