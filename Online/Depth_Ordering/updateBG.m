function BG =updateBG( frames)
[nr nc nm nf] = size(frames);

BG = zeros(nr,nc,nm);
tic
for ii = 1:nr
    for jj = 1:nc
        vecR = frames(ii,jj,1,:);
        vecG = frames(ii,jj,2,:);
        vecB = frames(ii,jj,3,:);
        medR = median(double(vecR));
        medG = median(double(vecG));
        medB = median(double(vecB));
        BG(ii,jj,1) = medR;
        BG(ii,jj,2) = medG;
        BG(ii,jj,3) = medB;
        
    end
end