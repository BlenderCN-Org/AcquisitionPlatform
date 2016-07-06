function [ xyY ] = rgb2xyY( rgb )
    %RGB2XYY 
    %   Transform from rgb to xyY
    % INPUT: 3 element vector containing rgb coordinates
    
    if (length(rgb) ~= 3)
        error('RGB coordinates should be a vector of 3 elements. Please input a 3 element vector with each element with values between 0 and 255');
    end
    
    xyY= [];
    var_R = ( rgb(1) / 255 );        %R from 0 to 255
    var_G = ( rgb(2) / 255 );        %G from 0 to 255
    var_B = ( rgb(3) / 255 );        %B from 0 to 255

    if ( var_R > 0.04045 ) 
        var_R = ( ( var_R + 0.055 ) / 1.055 ) ^ 2.4;
    else
        var_R = var_R / 12.92;
    end
    
    if ( var_G > 0.04045 ) 
        var_G = ( ( var_G + 0.055 ) / 1.055 ) ^ 2.4;
    else
        var_G = var_G / 12.92;
    end
    
    if ( var_B > 0.04045 ) 
        var_B = ( ( var_B + 0.055 ) / 1.055 ) ^ 2.4;
    else
        var_B = var_B / 12.92;
    end
    var_R = var_R * 100;
    var_G = var_G * 100;
    var_B = var_B * 100;

    %Observer. = 2°, Illuminant = D65
    X = var_R * 0.4124 + var_G * 0.3576 + var_B * 0.1805;
    Y = var_R * 0.2126 + var_G * 0.7152 + var_B * 0.0722;
    Z = var_R * 0.0193 + var_G * 0.1192 + var_B * 0.9505;   
    
    %X from 0 to 95.047       Observer. = 2°, Illuminant = D65
    %Y from 0 to 100.000
    %Z from 0 to 108.883
    
    xyY = [xyY X/( X + Y + Z ) ];
    xyY = [xyY Y/( X + Y + Z ) ];
    %xyY = [xyY Y];
   

end

