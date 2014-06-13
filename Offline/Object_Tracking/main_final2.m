clc;
clear all;
close all;
%%
vid1 = mmreader('D:\Final Year Project\Code Development\Datasets\DrDoDatabase\StudioSequence170Right1.avi');
vid2 = mmreader('D:\Final Year Project\Code Development\Datasets\DrDoDatabase\StudioSequence170Left1.avi');

%% Background model

L = 30;

% Left Video

im=read(vid1,1); 
[nr nc nm ] = size(im);
nf = L;
frames = zeros(nr,nc,nm,L);

for ii = 1:L 
    ii
    im=read(vid1,ii);
    frames(:,:,:,ii) = im;
end

BG1 = update_background(frames);

%%

Step = 5;
maxs = 30;
idx = 1;
colors = {'r','g','b','y','c','m','k'};
obid = [];
obL = []; 

for ii =5:5:170
    
    ii
    
    i1=read(vid1,ii);
    i2=read(vid2,ii); 
    
    subplot(231)
    imshow(i1);
    title('Left Video');
    axis image;
    
    I1 = rgb2gray(i1);
    I2 = rgb2gray(i2);
    
    I3 = cat(3,I1,I2,I2);
    
    subplot(232)
    imshow(I3);
    title('Superimposed Stereo');
    axis image;

    % moving mask
    bw1 = moving_mask1(i1,BG1);
    bw1 = imfill(bw1,'holes');
    bw1 = bwareaopen(bw1,400);
    
    subplot(234)
    imshow(bw1);
    title('Background Mask');
    axis image;
    
    [d] = stereo(i1,i2, maxs);
    subplot(233)
    imshow(d,[0 maxs]); 
    title('Filtered Disparity');
    axis image;
    
    [L count] = bwlabel(bw1);
    Dim = zeros(nr,nc);
    
    subplot(236)
    imshow(i1);
    title('Object Tracking');
    axis image;
    
    idx = 1;
    for nn = 1:count
        
        ob = L ==nn;   
        [x y] = find(ob);
        [Dim levels] = cluster(d,bw1);
        
        for kk = 1:length(levels)
            
            % Find the same level in previosly detected objects
            
            if ~isempty(obid) % If not empty
                match = 0;
                
                for oo = 1:length(obid)
                    diff = abs(levels(kk)-obid(oo));
                    
                    if diff<=4 % if diff less then one then same object
                        objectid = obL(oo);
                        match = 1;
                        obidtemp(kk) = obid(oo);
                        obLtemp(kk) = objectid;
                        break;
                    end
                    
                end
                
                if match~=1
                    obid = [obid levels(kk)];
                    
                    % Take empty value
                    for ii1 = 1:7
                        
                        if ~ismember(ii1,obL)
                            obL = [obL ii1];
                            break;
                        end
                        
                    end
                    
                    objectid = obL(end);
                    obidtemp(kk) = levels(kk);
                    obLtemp(kk) = objectid;
                    
                end
                
            else
                
                obid = levels(kk);
                objectid = 1;
                obidtemp(kk) = levels(kk);
                obLtemp(kk) = objectid;
                    
            end
            
            ob1 = Dim ==levels(kk);
            ob1 = bwareaopen(ob1,200);
            [x1 y1] = find(ob1);
            co = [min(y1) min(x1) max(y1)-min(y1) max(x1)-min(x1)];
            rectangle('position',co,'edgecolor',colors{objectid})
            text(co(1), co(2),num2str(levels(kk)),'color','r')
            idx = idx+1;
            
        end
        
        obid = obidtemp;
        obL = obLtemp;
        
    end

    subplot(235)
    imshow(Dim,[0 maxs]);
    title('Depth Ordering');
    axis image;
    pause(0.0000001)
    
end