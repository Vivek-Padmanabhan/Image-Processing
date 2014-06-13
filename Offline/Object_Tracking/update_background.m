function BG = update_background(frames)
% This program updates background by taking median of all frames
[nr,nc,nm,nf] = size(frames);
frames = double(frames);
BG = zeros(nr,nc,nm);
tic
R1 = frames(:,:,1,:);
G1 = frames(:,:,2,:);
B1 = frames(:,:,3,:);
BG(:,:,1) = median(R1,4);
BG(:,:,2) = median(G1,4);
BG(:,:,3) = median(B1,4);