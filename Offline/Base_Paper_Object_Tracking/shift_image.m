%% Shift Image
%-----------------------------------------------------------------
% function I = shift_image(I,shift)
%-----------------------------------------------------------------

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
end