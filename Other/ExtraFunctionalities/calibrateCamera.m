function [cameraParameters] = calibrateCamera(n, p)
%CalibrateCamera Use this function to get camera parameters. 
%the return object cameraParameters holds the extrinsic and intrinsic
%parameters.
%
%INPUT:
%· n: handle to a nikonController object.
%  p: handle to a platform object
%OUTPUT:
%· cameraParameters: struct containing instrinsic and extrinsic camera 
%  parameters
    %path for using Nikon class


    
    %if the handle is not a nikonController, throw error
    %if(nargin<1)
    %    error('Not a valid nikonController object passed as parameter');
    %end
    

    
    %%set the image to capture in JPEG small(fast calibration)
    n.set('Compression Level',3);
    n.set('Image Size',3);
    defaultPath= 'calibrationImages2/image';
    
    %TAKE THE CALIBRATION IMAGES
    %Note: First picture taken has to be the one with the pattern being
    %the coplanar with the xy axis in the world coordinates
    %%first delete all images from previous sessions.
    delete('C:\AcquisitionPlatform\Other\ExtraFunctionalities\calibrationImages2\*.jpg');
    p.home
    
    for i=0:18:45 %inclinationAngle
        for j=36:-4.5:-36 %rotationAngle
            p.move(p.deg2steps([j i]),'Absolute');
            
            filename= strcat(defaultPath,sprintf('Inclination_%02d_Rotation_',(i)),num2str(j),'.jpg');
        
            %take pictures
            image= n.capture();
            if(~isempty(image))
                imwrite(image.Image,filename);
            end
            
        end
        p.home;
        p.move([0,0],'Absolute');
    end
    
    %START CALIBRATION.
    %%set the calibration Images path
    images = imageSet(fullfile('calibrationImages2'));
    imageFileNames= images.ImageLocation;
    
    %%detect Checkerboardpoints
    [imagePoints,boardSize,imagesUsed]= detectCheckerboardPoints(imageFileNames);
    
    for i=1:length(imageFileNames)%delete images not used
        if(~imagesUsed(i))
        delete(num2str(cell2mat(imageFileNames(i))))
        end
    end
    %%set the square Size of milimeters as a constant and calculate world
    %%points
    squareSize= 35;
    worldPoints= generateCheckerboardPoints(boardSize,squareSize);
    
    %%get the parameters of the camera
    cameraParameters= estimateCameraParameters(imagePoints, worldPoints);
    
    %SHOW RESULTS
    %%first lets show the camera positions detected:
    figure; 
    showExtrinsics(cameraParameters,'PatternCentric');
    %showExtrinsics(cameraParameters,'CameraCentric');
    
    %%then show the values reprojected, to see the error we are doing in
    %%calibration
    images = imageSet(fullfile('calibrationImages2'));
    imageFileNames= images.ImageLocation;
    
    figure;
    imshow(imageFileNames{1});
    hold on;
    plot(imagePoints(:,1,1), imagePoints(:,2,1),'go');
    plot(cameraParameters.ReprojectedPoints(:,1,1), cameraParameters.ReprojectedPoints(:,2,1),'r+');
    legend('Detected Points','ReprojectedPoints');
    hold off;

    

end

