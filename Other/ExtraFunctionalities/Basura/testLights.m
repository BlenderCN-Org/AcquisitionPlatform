function testLights(focalLength, calibrationParam)
%testLights Function done to test the lights recovering process is done
%correctly.

    addpath('../Nikon')
    images = imageSet(fullfile('calibrationImages'));
    
    
    %SHOW RESULTS
     f= figure(); 
     showExtrinsics(calibrationParam,'PatternCentric');
     hold on
     [xS, yS, zS]= sphere(20);
      
     
     realWorldSphereCenter= [-100 100 200];
      
     %plot sphere representing real sphere.
     surface((xS)*60-realWorldSphereCenter(1),(yS)*60-realWorldSphereCenter(2),(zS)*60-realWorldSphereCenter(3)) 
     
    

    
    %define an array of colours for identifying lights.
    %Red, green, blue, yellow
    
    colours= [[1 0 0],[0 1 0], [0 0 1], [1 1 0]];
    for k=1:calibrationParam.NumPatterns
        image= imread(char(images.ImageLocation(k)));
        [worldVectors, nHighlights, ~] = lightDirections(image,focalLength,calibrationParam,k);
        colour= colours(uint8((k-1)*3)+1:uint8(3*(k-1)+3));
        
        set(0, 'CurrentFigure', f)
        [xL,yL,zL]= sphere(5);
        distanceSL= 1000;
        for i= 1:nHighlights
           h=surface((xL)*50-(-worldVectors(1,i)*distanceSL+realWorldSphereCenter(1)),(yL)*50-(-worldVectors(2,i)*distanceSL+realWorldSphereCenter(2)),(zL)*50-(-worldVectors(3,i)*distanceSL+realWorldSphereCenter(3))); 
           set(h,'FaceColor',[colour]);
        end
       

        
    end
    hold off
    
    
    %showExtrinsics(cameraParameters,'CameraCentric');
    
    axis equal



end

