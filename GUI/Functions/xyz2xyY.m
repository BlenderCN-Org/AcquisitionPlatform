function [ xyY] = xyz2xyY( xyz )
%XYZ2XYY Transform from xyz to xyY
%   xyz coordinates of xyz vector

    x= xyz(1)/(xyz(1)+xyz(2)+xyz(3));
    y= xyz(2)/(xyz(1)+xyz(2)+xyz(3));
    Y= xyz(2);
    
    xyY= [x y Y];

end

