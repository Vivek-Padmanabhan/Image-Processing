function bwcl = moving_mask1(im,BG)


  % Calculate density diff
s = [1 2 1; 0 0 0; -1 -2 -1];
% Seprate R G B
Rbg = BG(:,:,1);
Gbg = BG(:,:,2);
Bbg = BG(:,:,3);

% Calculate density diff
s = [1 2 1; 0 0 0; -1 -2 -1];
HRdens = conv2(Rbg,s);
VRdens = conv2(Rbg,s');
HGdens = conv2(Gbg,s);
VGdens = conv2(Gbg,s');
HBdens = conv2(Bbg,s);
VBdens = conv2(Bbg,s');

DensRf = (HRdens+VRdens)./9;
DensGf = (HGdens+VGdens)./9;
DensBf = (HBdens+VBdens)./9;
Densbg = cat(3,DensRf,DensGf,DensBf);

im = double(im);
% Calculate color difference
diff = abs(BG-im);
diff = max(diff,[],3);
bw = (diff>30);

% ------------ Calculate density diff
% Seprate R G B
R1 = im(:,:,1);
G1 = im(:,:,2);
B1 = im(:,:,3);

% Calculate density diff
HRdens1 = conv2(R1,s);
VRdens1 = conv2(R1,s');
HGdens1 = conv2(G1,s);
VGdens1 = conv2(G1,s');
HBdens1 = conv2(B1,s);
VBdens1 = conv2(B1,s');

DensRf1 = (HRdens1+VRdens1)./9;
DensGf1 = (HGdens1+VGdens1)./9;
DensBf1 = (HBdens1+VBdens1)./9;

Dens1 = cat(3,DensRf1,DensGf1,DensBf1);
diff1 = abs(Dens1-Densbg);
diff1 = max(diff1,[],3);
bw1 = (diff1>30);
bw1 = bw1(2:end-1,2:end-1);
BW = or(bw1,bw);
% Perform close operation
bwcl = bwmorph(BW,'close');
bwcl = bwareaopen(bwcl,150);
se = strel('line',5,90);
bwcl = imdilate(bwcl,se);
% bwcl =bwmorph(bwcl,'dilate');