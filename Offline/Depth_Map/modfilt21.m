function B = modfilt21(A,M, N)

% MODFILT2 Perform 2-D modal filtering.
%    B = MODFILT2(A,[M N]) performs modal filtering of the matrix
%    A in two dimensions. Each output pixel contains the modal
%    value in the M-by-N neighborhood around the corresponding
%    pixel in the input image.

[m n] = size(A);
if (m < M) | (n < N)
   disp(' Image size smaller than MxN');
   return;
end

B = zeros(m-M+1, n-N+1);
for i=0:m-M
   for j=0:n-N
      c = A(i+1:i+M,j+1:j+N);      
      c = reshape(c,1,M*N);
      h = hist(c, max(c)+1);
      [maxv maxidx] = max(h);
      B(i+1,j+1) = maxidx;
   end
end