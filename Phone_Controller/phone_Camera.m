classdef phone_Camera
    %phone_Camera Use this class to take images from the phone camera.
    %
    %
    %INSTRUCTIONS OF USE:
    %This class supports any app that uses your smartphone as an ip webcam.
    %In order for this code to work, you have to download an app in your
    %phone that does the task of converting your device in to an ip webcam.
    %I recommend IP Webcam, which is in the store of many OS for free.
    %
    %Once you installed the app, the only thing you have to do is start the
    %server, and then look at the ip given by the app. This the ip of your
    %camera. This ip is the one you have to pass to this function to work.
    %(In order to have always the same ip for the device, some router
    %managament has to be done. Otherwise, each time you connect to the
    %wifi, you will have a different ip). 
    %
    %
    %EXAMPLES:
    %s= phone_Camera('192.168.11.111') --> For connecting to the camera 
    %image= s.capture --> For capturing an image
    %
    %
    %SETTINGS OF THE CAMERA:
    %For now, if you want to change the settings of the camera you can do
    %it via webbrowser at http://YOUR_IP:8080 or in the phone screen. 
    %Further implementation of changing camera parameters via this code
    %could be considered.
    %
    %Victor Moyano - 23/08/2016
    properties
        url= 'http://';
    end
    
    methods
        function this= phone_Camera(varargin)
            if (length(varargin) ~= 1)
                error('Please, if you are trying to connect to the camera, enter the ip at which the camera is connected');
            end
            port= ':8080';
            this.url= strcat(this.url,varargin{1},port);
            
            
            im= imread(strcat(this.url,'/shot.jpg'));
            
            if(isempty(im))
                error('The camera was not found at the given ip. Please enter the ip as a parameter, without the port number (is always 8080).');
            end
        end
        
        function [varargout] = capture(this,varargin)
            varargout{1}= imread(strcat(this.url,'/photoaf.jpg'));
        end
    end
    
end

% 'url/photo.jpg' --> photo without autofocus 
% 'url/photoaf.jpg' --> photo with autofocus