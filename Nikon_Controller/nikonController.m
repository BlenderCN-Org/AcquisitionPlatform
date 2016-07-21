    %nikonController MATLAB class wrapper for the c++ class that manages a
%Nikon Camera.

classdef nikonController < handle
    properties (SetAccess = private, Hidden = true)
        objectHandle = 'NULL'; % Handle to the underlying C++ class instance
        attributeNames= {'Compression Level','Image Size','White Balance Mode','Sensitivity','Aperture','Metering Mode','Shutter Speed', ...
						'Flash Sync Mode','Active D Lighting','Auto-Distorsion','Image Color Space','HDR Mode','Continuous AF Area Priority', ...
								'AF AreaPoint', 'EV Steps for Exposure Control', 'Focus Preferred Area','Exposure Mode','Enable Bracketing', ...
								'ISO Control','Af Sub Light','Exposure Comp.','Internal Flash Comp','Focus Mode'}; 
    end
    methods
         
        function this = nikonController(varargin)
            % NIKONCONTROLLER - Create a new object controlling a Nikon camera.
            %
            %PARAMETERS:
            %   0 inputs --> Camera settings are not set to default.
            %   1 input: type string. Example: 'default' --> Camera settings are set to default.
            %OUTPUT: 
            %   1 output --> handle to the object controlling Nikon camera
            %<a href="matlab: opentoline('example.m',8)">Some examples here</a>
            old= cd('C:\AcquisitionPlatform\Nikon_Controller');
            this.objectHandle = nikonController_mex('new', varargin{:});
            cd(old);
        end
        
        function delete(this)
            %%DELETE - Destroys the nikon handle and closes the camera connection.
            %
            %PARAMETERS:
            %   0 inputs 
            %OUTPUT: 
            %   O output
            %<a href="matlab: opentoline('example.m',13)">Some examples here</a>
            
            nikonController_mex('delete', this.objectHandle);
        end
        
        function varargout = capture(this, varargin)
            %%CAPTURE - Capture an image from the camera.
            %
            %PARAMETERS: 
            %   nikon.capture(exif)
            %   exif='on'|'off' (default:'off')  'on':retrives exif data algonside with the
            %   image in info field
            %                    'off':
            % without parameter default is 'off'
            %   otherwise -> 'no exif data
            %   0 input --> no exif file is returned
            %   1 input --> capture('exif')--> exif file is returned
            %OUTPUT: 
            %   1 output --> Struct containing an image and its exif file. If the camera is
            %   set in RAW+ JPEG mode, JPEG image will be discarted.
            %   2 outputs --> Two structs containing Images captured by the camera. The first
            %   variable contains the RAW image, and the second one is the 
            %   JPEG image. If the camera is not set to capture 2 images
            %   (JPEG+RAW), error will be shown. 
            %<a href="matlab: opentoline('example.m',29)">Some examples here</a>
            [varargout{1:nargout}] = nikonController_mex('capture', this.objectHandle, varargin{:});
            
        end
        
        function varargout = captureToDisk(this,varargin)
            %%CAPTURETODISK- Capture an image and save it directly to disk.
            %%This could save time.
            %PARAMETERS:
            %   1 input --> the full path of the image name to save. If you
            %   enter a name with no extension, the program will try to
            %   save 2 images: one .jpeg and the other .nef, with the name
            %   you indicated.
            %   2 input --> the full path of the 2 images names to save. The
            %first parameter should contain the .nef image name, and the
            %second parameter should contain the .jpeg image name. 
            %OUTPUT:
            %   0 output --> no output is given.
            for i=1:length(varargin)
                %%check if the paths exist
                [path, ~, extension]=fileparts(varargin{i});
                [~, directory, ~]= fileparts(pwd);

                if((~(exist(path,'file') == 7) && ~isempty(path)) || strcmp(directory,path))                   
                    error('The path of the input number %d does not exist. Please check it.',i)
                end
                
                if(length(varargin)==2 && isempty(extension))
                    if(i==1)
                        varargin{1}= strcat(varargin{1},'.nef');
                    elseif(i==2)
                        varargin{2}= strcat(varargin{2},'.jpeg');
                    end
                end
            end
            
            if(isempty(extension) && length(varargin)==1)
                parameters= this.get();
                captureMode= getfield(parameters,'Compression Level');
                
                if(strcmp(captureMode,'JPEG Basic') || strcmp(captureMode,'JPEG Normal') || strcmp(captureMode,'JPEG Fine'))
                %%case of the camera taking jpeg
                    varargin{1}= strcat(varargin{1},'.jpeg');
                elseif(strcmp(captureMode,'RAW'))
                %%case of the camera taking nef
                    varargin{1}= strcat(varargin{1},'.nef');
                else
                %%case of the camera taking nef + jpef
                    fileName= varargin{1};
                    varargin{1}= strcat(fileName,'.nef');
                    varargin{2}= strcat(fileName,'.jpeg');
                end
            end
            
            [varargout{1:nargout}] = nikonController_mex('captureToDisk', this.objectHandle, varargin{:});
        end
        
        function varargout = captureFromDisk(this,varargin)
            %%CAPTUREFROMDISK- Read an image from disk and returns the
            %%image in matlab. The image could be either jpeg or raw.
            %PARAMETERS:
            %   1 input --> name of the image to read.
            %OUTPUT:
            %   0 output --> image obtained.
            [varargout{1:nargout}] = nikonController_mex('captureFromDisk', this.objectHandle, varargin{:});
        end
        function varargout = set(this, varargin)
            %%SET - Set a camera parameter.
            %
            %PARAMETERS: 
            %   1 input --> type Matlab struct. Matlab struct containing all
            %   camera parameters. 
            %   2 inputs --> The first input is a string containing the
            %   parameter name, and the second one is a number containing
            %   the value of the parameter you want to set. Check range
            %   function for information about parameter values. 
            %OUTPUT: 
            %   0 outputs
            %<a href="matlab: opentoline('example.m',27)">Some examples here</a>
            if(length(varargin) == 2)%%the user is passing an attribute Name and a value
                varargin{1}= validatestring(varargin{1},this.attributeNames);
            end
            [varargout{1:nargout}] = nikonController_mex('set', this.objectHandle, varargin{:});
        end

        function varargout = setDefault(this,varargin)
            %%SETDEFAULT - Set camera parameters to the default values 
            %stored in defaultParameters.mat.
            %
            %PARAMETERS: 
            %   0 outputs 
            %OUTPUT: 
            %   0 outputs
            %<a href="matlab: opentoline('example.m',33)">Some examples here</a>
            [varargout{1:nargout}]= nikonController_mex('setDefault',this.objectHandle,varargin{:});
        end
        
        function changeDefault(this,varargin)
            %%CHANGEDEFAULT - Save the current camera parameters as the
            %default ones.
            %
            %PARAMETERS: 
            %   0 input 
            %OUTPUT: 
            %   0 outputs
            %<a href="matlab: opentoline('example.m',49)">Some examples here</a>
            parameters= nikonController_mex('get',this.objectHandle, varargin{:});
            save('defaultParameters.mat','parameters');
        end
            
        function varargout = get(this, varargin)
            %%GET - Get current camera parameters
            %
            %PARAMETERS:
            %   0 input --> Request all camara parameters information.
            %   1 input --> string type. Name of the parameter you want to set.
            %   Request the information about the parameter indicated by parameter.
            %OUTPUT:
            %   1 output --> Matlab struct containing the camera parameter
            %   requested. It will contain all camera parameters if no
            %   input is used.
            %<a href="matlab: opentoline('example.m',21)">Some examples here</a>
            
            if(length(varargin) == 1)%%the user is passing an attribute Name 
                varargin{1}= validatestring(varargin{1},this.attributeNames);
            end
            [varargout{1:nargout}] = nikonController_mex('get', this.objectHandle, varargin{:});
        end

        function varargout = range(this,varargin)
            %%RANGE - Get all the possible values for a given camera
            %parameter
            %
            %PARAMETERS:
            %   0 input --> Print all the possibles values of all the
            %   camera parameters avaliable. 
            %   1 input --> string type. Print all the possible values of
            %   the parameter indicated by the string.
            %OUTPUT: 
            %   0 output --> The values are printed in matlab console. 
            %<a href="matlab: opentoline('example.m',24)">Some examples here</a>
            if(length(varargin) == 1)%%the user is passing an attribute Name 
                varargin{1}= validatestring(varargin{1},this.attributeNames);
            end
            [varargout{1:nargout}] = nikonController_mex('range',this.objectHandle, varargin{:});
        end
        
        
        function liveView(this,varargin)
           %%LIVEVIEWIMAGE - Get bad quality images for live view.
            %PARAMETERS:
            %   0 input 
            %OUTPUT: 
            %   0 output --> The iamges are shown in a Matlab figure.
            %<a href="matlab: opentoline('example.m',46)">Some examples here</a>
           
           liveViewImage = nikonController_mex('liveView',this.objectHandle,varargin{:});
           f= figure('name','liveView');
           set(f, 'Visible', 'on');
           h= imshow(liveViewImage);
           
           while (ishandle(f))
               liveViewImage = nikonController_mex('liveView',this.objectHandle,varargin{:});
               set(h,'CData', liveViewImage);
               drawnow;
           end
           
           nikonController_mex('endLiveView',this.objectHandle,varargin{:});
        end
        
        function flush(this,varargin)
            %%Flush- Call this function to eliminate all information stored in
            %%the RAM of the camera. (Reboot the camera)
            nikonController_mex('flush',this.objectHandle,varargin{:});
        end
    end
end
