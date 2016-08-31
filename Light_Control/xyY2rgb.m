%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function rgb = xyY2rgb(xyY, doClamp)
%  Converts an image in xyY format to the RGB format, as described in 
%  http://en.wikipedia.org/wiki/CIE_1931_Color_Space
% 
% Input parameters:
%   - xyY: input image (3 channels) in the xyY color space
%   - doClamp: 0 or [1], clamps the output in the [0,1] range. If not,
%       linearly extrapolates the values of rgb
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rgb = xyY2rgb(xyY)

    xyz= xyY2xyz(xyY);
    rgb= xyz2rgb(xyz);
    
end


