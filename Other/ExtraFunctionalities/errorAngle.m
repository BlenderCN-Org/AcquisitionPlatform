function [ angle ] = errorAngle( v1,v2 )
%ERRORANGLE Returns the angle between two given vectors.
%OUTPUT:
% angle: the angle (in degrees) between the two vectors given.

    cosangle = dot(v1,v2)/(norm(v1)*norm(v2));
    angle = acosd(cosangle);

end

