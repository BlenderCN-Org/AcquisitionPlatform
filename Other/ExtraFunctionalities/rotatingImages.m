function rotatingImages(step)
            %ROTATINGIMAGES- Take several rotating images with a given step. 
            %PARAMETERS: 
            %   1 input: Step in degrees for each image to be rotated. For 
            %   example, if 10 images are going to be taken, enter a step of 36.
            %OUTPUT:
            %   0 output
            %oldFolder= cd('../Nikon_Controller/');
            
            nikon= nikonController;
            nikon.set('Compression Level',3);
            
            
            
            anglesDone= 0;
            y= 'y';
            n= 'n';
            imageNumber= 1;
            if (rem(360,step)~=0)
                error('Step not valid. Enter a divisor of 360, so you can finish where you started')
            end
    
            prompt = 'Any special name for the naming the images? (press enter if you want default):';
            x = input(prompt);
            if (isempty(x))
                prefix= 'image';
            else
                prefix = x;
            end
            
            [im1] = nikon.capture();
            %h= imshow(im1);
            
            while(anglesDone~=360)   
                %[im1, im2]= nikonController_mex('capture', this.objectHandle)
                
                prompt = 'Image captured correctly? (y/n)';
                x = input(prompt);
                x=y;
                if (x==y)
                    %fileName = strcat('../Images/',prefix,'_',num2str(imageNumber),'_','Angle_',num2str(anglesDone),'.jpg');
                    fileName = strcat('../Images/Hassan/',prefix,'_',num2str(imageNumber),'.jpg');
                    %fileName2 = strcat('../Images/',prefix,'_',num2str(imageNumber),'.nef');
                    %fileName2 = strcat(prefix,'_','Angle:',Done,'.nef');
                    imwrite(im1.Image,fileName);
                    
                    %rawImage= im1.Image;
                    %save('fileName2','rawImage'); %%In order to visualize this pictures, some treatment has to be done!!!!!!!
                    
                    anglesDone= anglesDone +step;
                    imageNumber= imageNumber +1;
                end 
                pause(1)
                [im1] = nikon.capture();
                pause(1);
            end
            nikon.delete;
            %cd(oldFolder);
end