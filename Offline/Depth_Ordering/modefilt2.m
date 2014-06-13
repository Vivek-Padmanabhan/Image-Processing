%  f = modefilt2_mex(img,win,ignore)
%----------------------------------------------------------------------------

function f = modefilt2(img,win,ignore)

  %-- check input
  if(~exist('ignore')) ignore = 0; end
  if(~exist('win')) win = [5 5]; end
  if(~isfloat(img)) img = double(img); end
  
  %-- this could be removed if you are sure you're 
  %   passing whole, positive numbers
  img = abs(round(img));
  
  f = modefilt2_mex(img,win,ignore);
  
  
  
  
