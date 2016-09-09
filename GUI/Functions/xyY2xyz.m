function [ xyz ] = xyY2xyz( xyY )
%XYY2XYZ Transform xyY coordinates in to xyz
%   xyY --> coordinates in [x y Y]

    x= xyY(1)*xyY(3)/xyY(2);
    y=  xyY(3);
    z=(1-xyY(1)-xyY(2))*xyY(3)/xyY(2);
    
    xyz= [ x y z ];

end

