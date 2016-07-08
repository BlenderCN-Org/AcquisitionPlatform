function [ xc,yc,R] = fitCircle( x,y )
%FITCIRCLE This function fits a given set of points to the best circle that
%matches this set of points.
%-----INPUTS:
% x= coordinate X of all the points to fit.
% y= coordinate Y of all the points to fit.
%-----OUTPUTS:
% xc= x coordinate of circle center
% xy= y coordinate of circle center
% R= radius of Cercle
   x=x(:); y=y(:);
   a=[x y ones(size(x))]\[-(x.^2+y.^2)];
   xc = -.5*a(1);
   yc = -.5*a(2);
   R  =  sqrt((a(1)^2+a(2)^2)/4-a(3));
end

