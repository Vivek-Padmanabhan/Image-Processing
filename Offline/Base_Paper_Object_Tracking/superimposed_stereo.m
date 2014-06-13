%% Superimposed Stereo
%-----------------------------------------------------------------
% function I3 = superimposed_stereo(i1,i2)
%-----------------------------------------------------------------

function I3 = superimposed_stereo(i1,i2)
    
    %--Convert to GreyScale 
    I1 = rgb2gray(i1);
    I2 = rgb2gray(i2);
    %--Concatenate RGB Channels
    I3 = cat(3,I1,I2,I2);
end