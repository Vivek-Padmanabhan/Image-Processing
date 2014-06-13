clear all;
Step=5;

mov_mot = aviread('IU_GT_motion_every5frames.avi'); L = size(mov_mot,2);
mov_dep = aviread('IU_GT_depth_every5frames.avi');
mov_org = aviread('IU_Left.avi');

for frame=1:L
    
    ima = frame2im(mov_org(1+Step*(frame-1)));
    figure(1); imshow(ima);

    mot = frame2im(mov_mot(frame));
    figure(2); imshow(mot);
  
    dep = frame2im(mov_dep(frame));
    figure(3); imshow(dep);
 
    figure(4); imshow((double(ima)+double(mot))/(2*255));
    figure(5); imshow((double(ima)+double(dep))/(2*255));
    
    fprintf('\n frame %dx%d \t paused',frame-1,Step); pause;
  
end;

fprintf('\n');
