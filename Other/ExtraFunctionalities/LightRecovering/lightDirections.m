function [ worldVectors] = lightDirections(image, focalLength, calibrationParam,cameraNumber,varargin)
% lightDirections Function to get the light directions from a sphere. This
% function is able to detect highlight points in a sphere, and returns its
% direction in a world Coordinate system. 
% 
% Author: Victor Moyano 
% Date: 11/07/2016

%WORKFLOW:
%  0. PreJob: Calibrate camera to obtain intrinsic and extrinsic parameters.
%
%  1. Get light directions in Camera Coordinate System:
%   1.1. Find sphere center, and sphere radii at the 2D image taken. (Done automatically or manually) 
%   1.2. Detect highlight points in 2D image.(Done automatically).
%   1.3. Fit the sphere in to a conic matrix, in order to be able to do the
%   maths for finding sphereCenter. As said, in order to do this, we need
%   to know intrinsic parameters of the camera.
%   1.4. For each light detected in the image, cast the 2D point in to a ray 
%   in Camera coordinate, going from optical center in to the sphere.
%   1.5. Knowing the real sphere radii and the real sphere center position, we can find 
%   the point where the ray intersects the surface of the sphere. If we
%   find this point, we can do some easy geometry to extract light
%   directions.
%   
%  2. Transform light directions from Camera Coordinate System in to World
%Coordinate System. The only tricky part in this point is to be sure camera 
%axis matches with the rotation Matrices obtained when calibrating the Images. 
%If the axis doesn't match, you need to rotate from one (or two, if
%unlucky), to make the axis equal.
    %addpath('../Nikon')
    
    %first we need to calculate the intrinsic camera calibration matrix.
    %This is used to cast rays from camera Coordinates in to World
    %Coordinates. This matrix usually has the following form: 
    %[f/widthPerPixel 0 imageCenter_x]
    %[0 f/heightPerPixel imageCenter_y]
    %[0 0 1]
    %where f is focal length, widthPerPixel is the distance (horizontal)
    %occuped by each pixel in the camera film, and the imageCenter_x is
    %the center of the image. 
    
    [c,r,l] = borrar(image);
    
    height_cameraFilm= 15.6; %in mm
    width_cameraFilm= 23.5; %in mm
    height= size(image,1);
    width = size(image,2);
    heightPerPixel= height/height_cameraFilm;
    widthPerPixel = width/width_cameraFilm;

    %Now we should get the sphere center and the radius
    f= figure();
    imshow(image);
    hold on
    %Find the sphere to a cercle, by least square method:
    
%     disp('Click some points in the sphere Boundary: ');
%     [sphereX, sphereY]= getpts(gcf);
%      [sphereCenter_x, sphereCenter_y,sphereRadiiPixels]= fitCircle(sphereX,sphereY)
%     

    sphereCenter_x= round(c(1));
    sphereCenter_y= round(c(2));
    sphereRadiiPixels= r;

    %plot cercle found
    plotCircle(sphereCenter_x, sphereCenter_y, sphereRadiiPixels);
        

    %set K to the value calculated experimentally
    if(isempty(calibrationParam))
        %calculate K theoretically, to compare with experimental:
        
        %Ktheoric= [focalLength/widthPerPixel 0  width/2; 0 focalLength/heightPerPixel height/2; 0 0 1]
        Ktheoric= [focalLength*widthPerPixel 0  width/2; 0 focalLength*heightPerPixel height/2; 0 0 1];
        K= Ktheoric;
    else
        K= calibrationParam.IntrinsicMatrix';
    end
    

    %---------------DETECT AND PROCESS HIGHLIGHT POINTS--------------------
    %%detect highlight points. It could be done either automatically or
    %%manually.
    if( length(varargin) == 0 || (strcmp(varargin{1},'Auto'))) 
        highlights_x= l(1);
        highlights_y= l(2);
    
    elseif(strcmp(varargin{1},'Manual'))
        [highlights_x,highlights_y]= getpts();
        highlights_x= highlights_x';
        highlights_y= highlights_y';
        
    elseif(strcmp(varargin{1},'Full'))
        disp('Select the points defining the area to study: ');
        [pointsX, pointsY]= getpts(gcf);
        init_x= pointsX(1);
        init_y= pointsY(1);
        end_x= pointsX(2);
        end_y= pointsY(2);
    
        %plot(init_x,init_y,'x');
        step = 7;
        
        highlights_x= [];
        highlights_y= [];
        
        for i=init_x:step:end_x
            for j= init_y:step:end_y
                if((i-sphereCenter_x)^2+(j-sphereCenter_y)^2 < sphereRadiiPixels^2)
                    highlights_x= [highlights_x i];
                    highlights_y= [highlights_y j];   
                    plot(i,j,'x');
                end
                
            end
            drawnow
        end
        
    end
    
    hold off
    
    
    %sort the highlight points in increasing x (first the lights in the
    %left of the image). This is done for being able to relate lights in
    %the image with the directions calculated later on.
    highlightPoints = [highlights_x; highlights_y];

    hold on
    %plot(l(1),l(2),'c*');
    [~, order] = sort(highlightPoints(1,:));
    highlightPoints = highlightPoints(:,order);
    hold off
    
    %now, we need to know conic matrices corresponding to
    %the sphere. The ellipse equation has the form= Ax^2+Bxy+Cy^2+Dx+Ey+F=0
    %And the conic matrix is: 
    %[ A   B/2  D/2 ]
    %[ B/2  C   E/2 ]
    %[ D/2 E/2   F  ]
    %a center at point (h,k) satisfies the following => (x-h)^2 + (y-k)^2 = r^2
    %which corresponds to a generall ellipse equation with
    %parameters: A=1, B= 0, C=1, D=-2h, E= -2k, F= h^2+k^2-r^2
    %so general matrix is:
    conic = [1 0 -sphereCenter_x; 0 1 -sphereCenter_y; 
    -sphereCenter_x -sphereCenter_y sphereCenter_x^2+sphereCenter_y^2-sphereRadiiPixels^2];
    
    %we need real sphere Radii to calculate normal vector (surface vector
    %of the sphere), and the distance to the sphere
    realSphereRadii= varargin{3}; %in mm
    
    %and now we can do the maths to find the sphere Center. Note that in
    %this step we only use intrinsic matrix. The step of finding sphere
    %Center can be done in a lot of diferent ways. 
    conic_normalized = transpose(K)*conic*K;
    [eigenvectors, eigvalues]= eig(conic_normalized);
    a= (eigvalues(3,3)+eigvalues(2,2))/2;
    r = sqrt(-eigvalues(1,1)/a);
    d = realSphereRadii*(sqrt(1+r^2))/r;
    sphereCenter= d*eigenvectors(:,1);
    
    
    %%This part is for calculating the rotation Matrices using the angles
    %%between axis. It could be done this way also, I will just leave it
    %%here, because in future implementations it may be useful.
    %RotationVectors= calibrationParam.RotationVectors;
    %RotationVectors(:,1)= RotationVectors(:,1)+pi/2;
    %Rx= [1 0 0; 0 cos(RotationVectors(cameraNumber,1)) -sin(RotationVectors(cameraNumber,1)); 0 sin(RotationVectors(cameraNumber,1)) cos(RotationVectors(cameraNumber,1))];
    %Ry= [cos(RotationVectors(cameraNumber,2)) 0 sin(RotationVectors(cameraNumber,2)); 0 1 0; -sin(RotationVectors(cameraNumber,2)) 0 cos(RotationVectors(cameraNumber,2))];
    %Rz= [cos(RotationVectors(cameraNumber,3)) -sin(RotationVectors(cameraNumber,3)) 0; sin(RotationVectors(cameraNumber,3)) cos(RotationVectors(cameraNumber,3)) 0; 0 0 1];
    %Rotation= (Rz*Ry*Rx)';
    
    %once we have the sphere center respect the camera, we can
    %proceed to calculate the lights directions
    nHighlights= size(highlightPoints,2);    
    lightVectors= zeros(nHighlights,3);
    sphericalCord= zeros(nHighlights,3);
    worldVectors= [];
    
    %pass highlight points to homogeneous coordinates
    highlightPoints= [highlightPoints; ones(1,size(highlightPoints,2))];
    

    
    for i= 1:nHighlights 
        %cast the 3D vector from the optical center, to the highlight
        %point(2D) in the image. This can be done using the instrinsic
        %matrix, and we need to use homogeneus coordinates (to transform 2D
        %point in 3D).
        visionVector = inv(K)*highlightPoints(:,i);
        
        
        visionVector= visionVector/norm(visionVector);
        
        %find intersection between vision Vector and real Sphere, and
        %calculate the normal for the sphere. Only a simple system of
        %equations has to be solved. I wrote a little function for doing
        %this.
        intersection= firstIntersectionLineSphere(visionVector,sphereCenter,realSphereRadii);
        normalVector= (intersection - sphereCenter)/realSphereRadii;
        
        %then do some easy geometry to find the light Vectors. We know the
        %vision Vector, and we also know the surface Vector, so we can do
        %it. 
        lightVectors(i,:)= visionVector - (dot(2*normalVector,visionVector)*normalVector);
        lightVectors(i,:)= lightVectors(i,:)/norm(lightVectors(i,:));
        

        
        %%now we will pass the cartesian coordinates to spheric:
        lightVectors(i,2)= -lightVectors(i,2); %to flip the y coordinate, preparing coordinates to be multiplied per Rotation Matrix .
       
        %now we must use the calibration parameters to be able to pass from
        %camera coordinates to world coordinates.
        
        %Its important to note that vectors are going to be transformed
        %from camera to world coordinates, and not points. This means no 
        %translation should be applied. Vectors are only affected by
        %translation (we are working with directional vectors, the modulus 
        %of them being always 1). 
        
        %We can use this equation to pass from world to camera:
        %CameraPoint = R*WorldPoint
        %So, WorldPoint= R^-1*CameraPoint.
        %we need to make sure axis naming of world coordinates matches with the
        %camera Cordinates, and then multiply for the inverse of the World to
        %camera matrix. Just take in to account, this is the relation
        %between camera axis and camera axis:
        %Camera= Rotation1'*World
        %World = Rotation1'*Camera
        
        if(~isempty(calibrationParam))
            worldVectors= [worldVectors calibrationParam.RotationMatrices(:,:,cameraNumber)'*lightVectors(i,:)'];
        else
            
            worldVectors= [worldVectors lightVectors(i,:)'];
        end
    end
%         %We can pass to coordinate spheres if needed:
%         x= lightVectors(i,1);
%         y= lightVectors(i,2);
%         z= lightVectors(i,3);
%         
%         %this is theta, inclination angle:
%         sphericalCord(i,1) = acosd(y);
%         %this is azimtuth, desplacement angle:
%         %we have to make the analysis for all the quadrants in space
%         if(x>=0 && z >=0)
%             sphericalCord(i,2) = atand(x/z);
%         elseif(x<0 && z>0)
%             sphericalCord(i,2) = atand(x/z);
%         elseif(x<0 && z<0)
%             sphericalCord(i,2) = -(180-atand(x/z));
%         elseif(x>0 && z<0)
%             sphericalCord(i,2) = (180+atand(x/z));
%         end

        %Finally, be sure axis matches with matlab representation axis:
        if(isempty(calibrationParam))
            y= worldVectors(2,:);
            worldVectors(2,:)= -worldVectors(3,:);
            worldVectors(3,:)= -y;
            %worldVectors(2,:) = -worldVectors(2,:);
        else
            worldVectors(2,:) = -worldVectors(2,:);
        end

        
        if(length(varargin) ==2)
            %plot error for the full study of lights
%             mat=zeros(nHighlights,nHighlights);
            for i=1:nHighlights
                error= errorAngle(varargin{2},worldVectors(:,i)');
                text(highlightPoints(1,i)-1,highlightPoints(2,i)-1,num2str(error,4));

            end
        end
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

