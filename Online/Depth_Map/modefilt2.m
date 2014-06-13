%  f = modefilt2_mex(img,win,ignore)
%  
%  Each pixel in the output gets the mode of its neighbors in the input.
%  The local neighborhood is defined by <win>. Numbers below ignore
%  are not considered when computing the modes.
%  
%  Inputs: 
%    > img: 2D matrix holding only positive integers
%    > win: [x_window_radius, y_window_radius] (default 5x5)
%    > ignore: minimum value of pixels to consider (0 by default to
%              consider all pixels)
%  
%  Outputs: 
%    > f: 2D matrix size(img) with filter result.
% 
%  Note: This is a wrapper for a mex implementation (modefilt2_mex.cpp).
%        It may be necessary to compile this on your machine.  Simply run:
%        >>mex modefilt2_mex.cpp
%  
%  Coded by: Shawn Lankton, April 2008, (www.shawnlankton.com)
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
  
  
  
  
