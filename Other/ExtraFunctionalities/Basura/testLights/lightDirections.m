function [ lightVectors ,worldVectors, sphericalCord] = lightDirections(image, focalLength, calibrationParameters)
% lightDirections Function to get the light directions from a sphere
% The light directions are returned in the order that they appear in the
% image. This means, lights located at lower x will appear first, lights
% located at higher x will appear later.
% 
    %%first we need to calculate the intrinsic camera calibration matrix.
    %%This is used to cast rays from camera Coordinates in to World
    %%Coordinates. This matrix usually has the following form: 
    %%[f/widthPerPixel 0 imageCenter_x]
    %%[0 f/heightPerPixel imageCenter_y]
    %%[0 0 1]
    %%where f is focal length, widthPerPixel is the distance (horizontal)
    %%occuped by each pixel in the camera film, and the imageCenter_x is
    %%the center of the image. 
    realSphereRadii= 60; %in mm
    height_cameraFilm= 15.6; %in mm
    width_cameraFilm= 23.5; %in mm
 
    height= size(image,1);
    width = size(image,2);
    
    heightPerPixel= height_cameraFilm/height;
    widthPerPixel = width_cameraFilm/width;
    

    
    K= [focalLength/widthPerPixel 0  width/2; 0 focalLength/heightPerPixel height/2; 0 0 1];
    imshow(image);
    hold on
    
    disp('Click Sphere Center: ');
    [sphereCenter_x, sphereCenter_y]= getpts(gcf);
    
    disp('Click Sphere Boundary: ');
    [sphereBoundary_x, sphereBoundary_y] = getpts(gcf);
    sphereRadiiPixels= ((sphereBoundary_x- sphereCenter_x)^2+(sphereBoundary_y-sphereCenter_y)^2)^0.5;
    sphereRadiiPixels= round(sphereRadiiPixels);
    
    
    %%detect highlight points
    grey= rgb2gray(image);
    BW= grey > 250;
    structs= regionprops(BW,grey,{'centroid','Area'});
    
    highlights_x= [];
    highlights_y= [];
    for k = 1: numel(structs)
        if(structs(k).Area > size(image,2))
            if(((structs(k).Centroid(1)-sphereCenter_x)^2+(structs(k).Centroid(2)-sphereCenter_y)^2) < sphereRadiiPixels^2)
                %%if the point is inside the circle
                highlights_x= [highlights_x structs(k).Centroid(1)];
                highlights_y= [highlights_y structs(k).Centroid(2)];
                plot(structs(k).Centroid(1),structs(k).Centroid(2),'r*')
            end
        end
    end
    
    hold off
    
    %%sort the highlight points in increasing x (first the lights in the
    %%left of the image)
    highlightPoints = [highlights_x; highlights_y];
    [~, order] = sort(highlightPoints(1,:));
    highlightPoints = highlightPoints(:,order);
    
    %before start, we need to know conic matrices corresponding to
    %the sphere. The ellipse equation has the form= Ax^2+Bxy+Cy^2+Dx+Ey+F=0
    %And the conic matrix is: 
    %[ A   B/2  D/2 ]
    %[ B/2  C   E/2 ]
    %[ D/2 E/2   F  ]
    %a center at point (h,k) satisfies the following => (x-h)^2 + (y-k)^2 = r^2
    %which corresponds to a generall ellipse equation with
    %parameters: A=1, B= 0, C=1, D=-2h, E= -2k, F= h^2+k^2-r^2
    %so general matrix is: 
           
    conic = [1.0 0 -sphereCenter_x; 0 1.0 -sphereCenter_y; 
    -sphereCenter_x -sphereCenter_y sphereCenter_x^2+sphereCenter_y^2-sphereRadiiPixels^2];
    
    conic_normalized = transpose(K)*conic*K;
    [eigenvectors, eigvalues]= eig(conic_normalized);
    %eigvalues
    %eigenvectors
    a= (eigvalues(3,3)+eigvalues(2,2))/2;
    r = sqrt(-eigvalues(1,1)/a);
    d = realSphereRadii*(sqrt(1+r^2))/r;
    sphereCenter= d*eigenvectors(:,1);
    sc = sphereCenter ;
    
    

    %highlightPoints= transpose(highlightPoints);
    %%CALCULATION OF HIGHLIGHTS POINTS
    nHighlights= size(highlightPoints,2);
            
    %%pass highlight points to homogeneous coordinates
    highlightPoints= [highlightPoints; ones(1,size(highlightPoints,2))];
    

    %%once we have the sphere center respect the camera, we can
    %%proceed to calculate the lights directions
    lightVectors= zeros(nHighlights,3);
    sphericalCord= zeros(nHighlights,2);
    for i= 1:nHighlights 
        visionVector = inv(K)*highlightPoints(:,i);
        visionVector= visionVector/norm(visionVector);

        %visionVector
        intersection= firstIntersectionLineSphere(visionVector,sphereCenter,realSphereRadii);
        normalVector= (intersection - sphereCenter)/realSphereRadii;

        
        lightVectors(i,:)= visionVector - (dot(2*normalVector,visionVector)*normalVector);
        lightVectors(i,:)= lightVectors(i,:)/norm(lightVectors(i,:));
        lightVectors(i,2)= -lightVectors(i,2); %to flip the y coordinate, making coordinates intuitive.
        lightVectors(i,3)= -lightVectors(i,3); %to flip the z coordinate, making coordinates intuitive.
        
        
        
        x= lightVectors(i,1);
        y= lightVectors(i,2);
        z= lightVectors(i,3);
        %%now we will pass the cartesian coordinates to spheric:
        
        
        %%this is theta, inclination angle:
        sphericalCord(i,1) = acosd(y);
        
        %%this is azimtuth, desplacement angle:
        %%we have to make the analysis for all the quadrants in space
        if(x>=0 && z >=0)
            sphericalCord(i,2) = atand(x/z);
        elseif(x<0 && z>0)
            sphericalCord(i,2) = atand(x/z);
        elseif(x<0 && z<0)
            sphericalCord(i,2) = -(180-atand(x/z));
        elseif(x>0 && z<0)
            sphericalCord(i,2) = (180+atand(x/z));
        end
        
        lightVectors(i,1)= -lightVectors(i,1);
    end
    
    
    figure();
    [xC,yC,zC]= sphere(6);
    surface(xC*40,yC*40,zC*40) %plot sphere representing the camera
    hold on;
    
    [xS, yS, zS]= sphere(20);
    surface((xS)*60-sc(3),(yS)*60-sc(2),(zS)*60-sc(1)) %plot sphere representing real sphere.
    
    %% now plot the lights at a given distance
    distanceSL= 500;
    [xL,yL,zL]= sphere(4);
    
    for i = 1:nHighlights
       surface((xL)*50-(lightVectors(i,3)*distanceSL+sc(3)),(yL)*50-(lightVectors(i,2)*distanceSL+sc(2)),(zL)*50-(lightVectors(i,1)*distanceSL+sc(1)))    
    end
    axis equal
    
    

    
    
    
end

%%This function should calculate the first intersection point between a
%%line guided by direction Vector, and a sphere with radii = radii,
%%centered at sphereCenter. Vectors and points are given in columns.
function point= firstIntersectionLineSphere(directionVector,sphereCenter,radii)

    %first guess of solution, for Newton method
    x0 = [1, 1, 1, 1];
    
    %%options=optimset('Display','iter');
    f= @(variables) nonlinearSystem(variables,directionVector,sphereCenter,radii);
    
    options = optimset('Display','off'); 
    solutions= fsolve(f,x0,options);
   
    %lambda value is not needed
    point = transpose(solutions(1:3));

    
end

function F= nonlinearSystem(variables, directionVector,sphereCenter,radii)
%Rewrite the equations in the form F(x) = 0
    F= [(variables(1)-sphereCenter(1))^2 + (variables(2)-sphereCenter(2))^2 + (variables(3)-sphereCenter(3))^2 - radii^2;
    variables(1) - directionVector(1)*variables(4);
    variables(2) - directionVector(2)*variables(4);
    variables(3) - directionVector(3)*variables(4);];
end

