function bw = moving_mask(im,BG)

% Calculate difference
im = double(im);

% Calculate color difference
diff = abs(BG-im);

% Calculate maximum difference in 3rd dimension
diff = max(diff,[],3);

% Thresholding to convert image in binary
bw = (diff>30); % Gives logical output

% Morphological operations
% Dialation
% bw = bwmorph(bw,'dilate');

% fill the circular region
% bw =imfill(bw,'holes');

% Remove noise
bw = bwareaopen(bw,500);