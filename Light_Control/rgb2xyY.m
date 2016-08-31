function [ xyY ] = rgb2xyY( rgb )
    %RGB2XYY 
    %   Transform from rgb to xyY
    % INPUT: 3 element vector containing rgb coordinates
    
    xyz= rgb2xyz(rgb);
    xyY= xyz2xyY(xyz);

end

