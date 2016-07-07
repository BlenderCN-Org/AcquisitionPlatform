function [distance] = evaluateLights( u1,u2,u3)
%EVALUATELIGHTS Summary of this function goes here
%   Detailed explanation goes here

    lightsZ= -110; %cm
    
    f1= lightsZ/u1(3);
    f2= lightsZ/u2(3);
    f3= lightsZ/u3(3);
    
    pos1= u1*f1;
    pos2= u2*f2;
    pos3= u3*f3;
    
    dist12= sqrt((pos1(1)-pos2(1))^2 +(pos1(2)-pos2(2))^2+(pos1(3)-pos2(3))^2)
    dist23= sqrt((pos3(1)-pos2(1))^2 +(pos3(2)-pos2(2))^2+(pos3(3)-pos2(3))^2)
    
end

