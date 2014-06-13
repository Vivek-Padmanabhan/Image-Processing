clc;
clear all
close all;
%%
% vid = mmreader('hall_monitor.mpg');
% Nframe = vid.NumberOfFrames;
L = 150;
%% WEBCAM
delete(imaqfind)

vid=videoinput('winvideo',1,'YUY2_320x240');

% vid=videoinput('winvideo',1,'RGB24_320x240');
triggerconfig(vid,'manual');
set(vid,'FramesPerTrigger',1 );
set(vid,'TriggerRepeat', Inf);
% start(vid);
% vid = videoinput('winvideo',1);

%  View the default color space used for the data — The value of the ReturnedColorSpace property indicates the color space of the image data.
color_spec=vid.ReturnedColorSpace;

% Modify the color space used for the data — To change the color space of the returned image data, set the value of the ReturnedColorSpace property.
if  ~strcmp(color_spec,'rgb')
    set(vid,'ReturnedColorSpace','rgb');
end

start(vid)
pause(5)

%% Detect background
trigger(vid);
im=getdata(vid,1); % Get the frame in im
[nr nc nm ] = size(im);
nf = L;
frames = zeros(nr,nc,nm,L);
for ii = 1:L 
    ii
    trigger(vid);
    im=getdata(vid,1); % Get the frame in im
    frames(:,:,:,ii) = im;
end

% BG =updateBG( frames);
BG = update_background(frames);
toc
% clear  frames
imshow(uint8(BG))


%% Moving object Detection
% Local memory
Memory1 = cell(1,3);

% Global memory
Memory2 = cell(1,3);

% Global memory index
gidx = 0;

% Threhold for distance matching
dth = 10;

% Threhold for length matching
Lth =2;

% threhold for width matching
Wth = 2;

% Threhold for Shape matching
SSDth = 10;

% Threshold for feature updation
Beta = 0.2; % i.e 20% of previous feature

% Threhold for maximum number of frames to be waited before shifting the
% object in to global memory
Matchth = 20;

% Plot background
subplot(2,2,2)
imshow(uint8(BG))
title('Background');

% Local memory index
idx =0;

% Number of frames for median filtering
Lf = L;
ThC = 50; % Centroid detection threhold
for ii = 1:600
    
    % Trigger video object
    trigger(vid);
    
    % Obtain image from webcam
    im=getdata(vid,1); % Get the frame in im
    
    % Plot the current frame
    subplot(2,2,1)
    imshow(im)
    title('Frame');
    % -------------- Update Background (Optional)------------------------------------
%     % Background updation
%     frames(:,:,:,Lf)=[]; % Delete last frame
%     frames = cat(4,im,frames); % Concatinate current frame at first place
%     if mod(ii,50) ==0 
%         % update background
%         BG = update_background(frames);
%         disp('Background is updated');
%         subplot(2,2,2)
%         imshow(uint8(BG))
%         title('Background');
%     end
    % --------------------------------------------------
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
    bw = bwmorph(bw,'dilate');
    
    % fill the circular region
    bw =imfill(bw,'holes');
    
    % Remove noise
    bw = bwareaopen(bw,150);
    
    %
%     SE = strel('line',30,0);
    
    % Segmentation
    % Create mask in 3D by concatinating them in 3 dimension
    bw3 = cat(3,bw,bw,bw);
    
    % Segment image by multiplying with 3d mask
    imseg = bw3.*double(im);
    
    % Plot the segmented image
    subplot(2,2,3)
    imshow(uint8(imseg));
    title('Moving object');

    
    %% Object segmentation, tracking and classification
    % Give labels to binary image
    [L count] = bwlabel(bw);
   
    disp([num2str(count) ' objects are detected']);
   
    % Initialize empty mask
    bwnew = zeros(size(bw));
    
    plots1=[];
    for kk = 1:count % For all objects
        ob1 = (L == kk);
        
        % Area calculation
        A = bwarea(ob1);
        [yo,xo] = find(ob1); % Find all non zero points
        
        % Centroid calculation
        xbar = sum(xo)/A;
        ybar = sum(yo)/A;
        
        % Shape caculation
        W = max(yo)-min(yo);
        L1 = max(xo)-min(xo);
        
        % compactness
        Pbw = bwperim(ob1);
        P = sum(Pbw(:));
        C = 4*pi*A/(P.^2);
        
        % Orientation
        mu11 = sum(sum((xo-xbar).*(yo-ybar)));
        mu20 = sum(sum((xo-xbar).^2));
        mu02 = sum(sum((yo-ybar).^2));
        theta = 0.5*atan(2*mu11/(mu20-mu02));
        
        % PCA calculation
        % Take RGB values from the frame
        rval = zeros(length(xo),1);
        gval = zeros(length(xo),1);
        bval = zeros(length(xo),1);
        
        for jj = 1:length(xo) % For all pixels from the segment
            
            % Tale R values from segmented area
            rval(jj) = im(yo(jj),xo(jj),1);
            
            % Take G value
            gval(jj) = im(yo(jj),xo(jj),2);
            
            % Take B value
            bval(jj) = im(yo(jj),xo(jj),3);
        end
        
        % Create one matrix
        M = [rval gval bval];
        
        % Calculate covariance matrix
        si = M'*M;
        
        % Calculate eigenvalues and eigenvectors
        [eigvec eigvalue] = eig(si);
        
        % Take the eigenvector corresponds to maximum eigenvalue
        [val id] = max(sum(eigvalue));
        
        eigvec = eigvec(:,id);
        
        % Reset global and local match flag
        mflag =0; % MAtch flag
        
        mgflag = 0; % global match flag;
        
        % match in global memory
        for nn = 1:gidx
            % Obtain features from Global memory
            f1 = Memory2{nn,1};
            f2 = Memory2{nn,2};
            
            % MATching stage
            
            % Centroid matching
            dist = sqrt((f1(1)-xbar).^2+(f1(2)-ybar).^2);
            
            % Shape matching
            SSD = ((f1(5)/A)-1)^2+((f1(6)/C)-1)^2+((f1(7)/theta)-1)^2;
            
            % Color matching
            S_Si = (f2'*eigvec)/(abs(f2)'*abs(eigvec));
            
            % match for global memory
            if dist<dth % Matched
                % if centroid is matched go for secong matching
                disp('global dist matched')
               if SSD < SSDth
                   
                   % update feature vectores
                   % Take old features
                   fold = Memory2{nn,1};
                   
                   % Take current features
                   fcurrent = [xbar ybar L1 W A C theta];
                   
                   % Apply adaptive filter to update feature vectors
                   fnew = Beta.*fold+(1-Beta).*fcurrent;
                   
                   % Update global memory
                   Memory2{nn,1}=fnew;
                   
                   % Set matching flag
                   mgflag = 1;
                   
                   % Add MAsk
                   bwnew = bwnew+ob1;
                   
                   disp('global SSD matched')
                   
%                    % Draw rectangle on real moving object
%                    rectangle('position',[min(xo),min(yo),L1,W],'edgecolor','r');
%                     
%                    % Write text at the corner of rectange 
%                    text(min(xo),min(yo),num2str(nn),'color','r','fontsize',12)
%                    
%                     objects1 = {'person','group','object'};
                   % Classification
                   % Calcualte ratio between height and length
                   ratio1 = W/L1;
                   if ratio1>1.75 && W>120 && L1>50
                       obi = 'Person';
                       oidx = 1;
                   elseif ratio1>0.9 && ratio1<1.75 && L1>80 && W>120
                       obi = 'group';
                       oidx = 2;
                   else
                       obi = 'object';
                       oidx = 3;
                   end
                   
                   plots1 = [plots1;min(xo) min(yo) L1 W nn oidx];
%                    text(min(xo)+10,min(yo)+10,obi,'color','g','fontsize',10)
%                  text(min(xo)+10,min(yo)+10,num2str(ratio1),'color','g','fontsize',10)
                   break;
                   
               end
                
            end
        end
        if mgflag~=1 % If global memory object is not matched
            % Match the features of previously detected objects with local
            % memory
            for nn = 1:idx
                f1 = Memory1{nn,1};
                
                f2 = Memory1{nn,2};
                % Centroid matching
                dist = sqrt((f1(1)-xbar).^2+(f1(2)-ybar).^2);

                % Shape matching
                SSD = ((f1(5)/A)-1)^2+((f1(6)/C)-1)^2+((f1(7)/theta)-1)^2;

                % Color matching
                S_Si = (f2'*eigvec)/(abs(f2)'*abs(eigvec));

                % match for local memory
                if dist<dth % Matched
                    % Update
                    fold = Memory1{nn,1}; 
                    fcurrent = [xbar ybar L1 W A C theta];
                    fnew = Beta.*fold+(1-Beta).*fcurrent;
                    Memory1{nn,1}=fnew;
                    
                    % Increment counter for matched object
                    Memory1{nn,3} = Memory1{nn,3}+1;
                    
                    % if matched for more than threshold then add entry
                    if Memory1{nn,3}>Matchth 
                        % Create new entry in global memory
                        gidx = gidx+1;
                        Memory2{gidx,1} = fnew;
                        Memory2{gidx,2} = Memory1{nn,2};
                        bwnew = bwnew+ob1;
                        % Delete the entry from local memory
                        Memory1(nn,:)=[];
                        
                        % Decrement count of local memory
                        idx = idx-1;
                    end
                    % SEt the local matching flag
                    mflag = 1;
                    disp('dist matched')
                    break;
                elseif abs(f1(3)-L1)<Lth && abs(f1(4)-W)<Wth
                    fold = Memory1{nn,1}; 
                    fcurrent = [xbar ybar L1 W A C theta];
                    fnew = Beta.*fold+(1-Beta).*fcurrent;
                    Memory1{nn,3} = Memory1{nn,3}+1;
                     % if matched for more than threshold then add entry
                    if Memory1{nn,3}>Matchth 
                        gidx = gidx+1;
                        Memory2{gidx,1} = fnew;
                        Memory2{gidx,2} = Memory1{nn,2};
                        bwnew = bwnew+ob1;
                        
                    end
                    mflag = 1;
                    disp('LW matched')
                    break;
                elseif SSD < SSDth
                    fold = Memory1{nn,1}; 
                    fcurrent = [xbar ybar L1 W A C theta];
                    fnew = Beta.*fold+(1-Beta).*fcurrent;
                    Memory1{nn,1}=fnew;
                     % if matched for more than threshold then add entry
                    if Memory1{nn,3}>Matchth 
                        gidx = gidx+1;
                        Memory2{gidx,1} = fnew;
                        Memory2{gidx,2} = Memory1{nn,2};
                        bwnew = bwnew+ob1;
                        
                    end
                    mflag = 1;
                    disp('SSD matched')
                    break;
                end
            end
        end
  
         
        if mflag ~= 1 && mgflag~=1% if not matched then add to memory
            % Create new class in local memory
            disp('new class created')
            idx = idx+1;
            Memory1{idx,1} = [xbar ybar L1 W A C theta];
            Memory1{idx,2} = eigvec;
            Memory1{idx,3} = 0;
        end
        
    end
    imseg1 = imseg.*cat(3, bwnew ,bwnew,bwnew );
     % Plot the segmented image
    subplot(2,2,4)
    imshow(uint8(imseg1));
    title('Real Moving object');
    
    objects1 = {'person','group','object'};

%      plots1 = [plots1;min(xo) min(yo) L1 W nn oidx];
    % Plot rectangles
    for nn = 1:size(plots1,1)
        
        text(plots1(nn,1)+10,plots1(nn,2)+10,objects1{plots1(nn,6)},'color','g','fontsize',10)
        
        % Draw rectangle on real moving object
        rectangle('position',plots1(nn,1:4),'edgecolor','r');
        
        % Write text at the corner of rectange 
        text(plots1(nn,1),plots1(nn,1),num2str(plots1(nn,5)),'color','r','fontsize',12)
                
    end
    pause(0.001)
    
end
% fprintf('matched value = %d, at %f \ n',a,0.03)