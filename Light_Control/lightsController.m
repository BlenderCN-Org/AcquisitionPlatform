classdef lightsController < handle
    %lightController This class is provided to control the lights connected
    %to the philips bridge.
    
    properties(Hidden= true)
        
    end
    
    properties(SetAccess = private)
        numberOfLights= 4; 
        Philips_IP= '0.0.0.0';
    end
    
    properties(SetAccess= public)
        defaultBrightness= 255;

    end
    
    methods
        function this =  lightsController (varargin)
            %%lightController-- Constructor of the class to control several
            %%lights using the philips bridge.
            %%INPUTS:0
            %%OUTPUTS:0
            
            this.Philips_IP= Lights('discover');
            Lights(1,'ip',this.Philips_IP);
            
            %find how many lights are avaliable
            lightsAvailable= 1;
            this.numberOfLights= 0;
            while(lightsAvailable)

                try
                    Lights(this.numberOfLights+1);
                    this.numberOfLights= this.numberOfLights+ 1;
                catch
                    lightsAvailable= 0;
                end
            end
            this.set('all','on');
        end
        
        function delete(this,varargin)
            this.set('all','off');
        end
        
        function set(this,varargin)
        %%SET-- Use this function to set all the lights propierties.
        %%Basic Uses:
        %%-- set(struct). sets the lights to the propierties given in the
        %%struct. The struct can be an array of structs (all the lights),
        %%or only one struct.
        %%-- set('all','on') : Turns on all the lights
        %%-- set('all', b) : Set the brightness b to all the lights
        %%-- set('all', [x y]): Set the x y cromatic coordinates to all the
        %%lights
        %%-- set('all',[x y b]): Set the x y cromatic coordinates and the
        %%brigthness b to all the lights
        %%-- set('all', 'rgb', [255 255 255]): Set all the lights to have
        %%the cromatic coordinates corresponding with the 255, 255, 255
        %%(white) RGB colour. Any combination can be used.
        %%-- The same commands can be used to set propierties of one specific 
        %% light. For example: set(L,[x y b]): set the x y cromatic coordinates
        %% and the brightness b to the light L.
            if(length(varargin) == 1)
                %%case of struct passed 
                if(~isstruct(varargin{1}))
                    error('The input passed has to be a struct, if only one input is passed. Please check the input is a struct.')
                end
                
                for i=1:size(varargin{1},2)
                    number= varargin{1}(i).LightNumber;
                    if(strcmp(varargin{1}(i).On,'true'))
                        state= 'on';
                    else
                        state= 'off';
                    end
                    Lights(number, state);
                    Lights(number, [varargin{1}(i).xyCoordinates varargin{1}(i).Brightness]);
                end

            else
                if(strcmp(varargin{1},'all'))
                %case of setting all the lights
                    if(strcmp(varargin{2},'rgb'))
                        xyY= rgb2xyY(varargin{3});
                        for i=1:this.numberOfLights
                            Lights(i,xyY);
                            Lights(i,this.defaultBrightness);
                        end
                    else
                        for i=1:this.numberOfLights
                            Lights(i,varargin{2});
                            Lights(i,this.defaultBrightness);
                        end
                    end
                else
                %case of setting only one light
                    if(strcmp(varargin{2},'rgb'))
                        xyY= rgb2xyY(varargin{3});
                        Lights(varargin{1},xyY);
                        Lights(varargin{1},this.defaultBrightness);
                    else
                        Lights(varargin{1},varargin{2});
                        Lights(varargin{1},this.defaultBrightness);
                    end
                end
            end
        end
        
        function lightParameters= get(this,varargin)
            %%GET-- Use this function to get the light propierties.
            %%INPUT:0. Get an array of structs, of total length of the
            %%number of lights connected to the bridge.
            %%INPUT 1: Number of light of which you want to get the
            %%propierties.
            lightParameters= [];
            if (length(varargin)==1)
                if(isnumeric(varargin{1}))
                    if(varargin{1} <= this.numberOfLights && varargin{1}>0)
                        lightParameters= Lights(varargin{1});
                        lightParameters.LightNumber= varargin{1};
                    else
                        error('Number of Light entered doesnt exist. Please change the light number you entered.');
                    end
                end
            else
                for i=1:this.numberOfLights
                    tmp=Lights(i);
                    tmp.LightNumber= i;
                    lightParameters= [lightParameters tmp];
                end
            end
        end
        
    end
    
end

