function [ solution ] = test(image)
%TEST Summary of this function goes here
%   Detailed explanation goes here
    
    imshow(image);
    [x,y]= getpts();
    contorn= [x y];
    solution= fitSphereToPoints(contorn);
    
    

end

function point= fitSphereToPoints(sphereContourPositions)

    %Equation to be solved: (x-x0)^2/a+ (y-y0)^2/b = R^2
    %first guess of solution, for Newton method
    firstGuess = [1, 1, 1, 1];% 4 variables. 1rst for center_X, 2nd for center_Y, 3rd for a, 4th for b
    
    
    %%options=optimset('Display','iter');
    radiiSphere= sqrt((sphereX-sphereContourPositions(2,1))^2+(sphereContourPositions(1,2)-sphereContourPositions(2,2)))/2
    f= @(variables) nonlinearSystem(variables,sphereContourPositions,radiiSphere);
    
    options = optimset('Display','off'); 
    solutions= fsolve(f,firstGuess,options);
   
    %lambda value is not needed
    point = transpose(solutions);

    
end

function F= nonlinearSystem(variables, sphereCountourPositions,radiiSphere)
%Rewrite the equations in the form F(x) = 0
    F= [(sphereCountourPositions(1,1)-variables(1))^2/variables(3) + (sphereCountourPositions(1,2)-variables(2))^2/variables(4) - radiiSphere^2;
    (sphereCountourPositions(2,1)-variables(1))^2/variables(3) + (sphereCountourPositions(2,2)-variables(2))^2/variables(4) - radiiSphere^2;
    (sphereCountourPositions(3,1)-variables(1))^2/variables(3) + (sphereCountourPositions(3,2)-variables(2))^2/variables(4) - radiiSphere^2;
    (sphereCountourPositions(4,1)-variables(1))^2/variables(3) + (sphereCountourPositions(4,2)-variables(2))^2/variables(4) - radiiSphere^2;
    (sphereCountourPositions(5,1)-variables(1))^2/variables(3) + (sphereCountourPositions(5,2)-variables(2))^2/variables(4) - radiiSphere^2];
end





