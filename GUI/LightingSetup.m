function varargout = LightingSetup(varargin)
% LIGHTINGSETUP MATLAB code for LightingSetup.fig
%      LIGHTINGSETUP, by itself, creates a new LIGHTINGSETUP or raises the existing
%      singleton*.
%
%      H = LIGHTINGSETUP returns the handle to a new LIGHTINGSETUP or the handle to
%      the existing singleton*.
%
%      LIGHTINGSETUP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LIGHTINGSETUP.M with the given input arguments.
%
%      LIGHTINGSETUP('Property','Value',...) creates a new LIGHTINGSETUP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LightingSetup_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LightingSetup_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LightingSetup

% Last Modified by GUIDE v2.5 06-Sep-2016 14:59:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
addpath([pwd '\Functions']);
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LightingSetup_OpeningFcn, ...
                   'gui_OutputFcn',  @LightingSetup_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end


% --- Executes just before LightingSetup is made visible.
function LightingSetup_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LightingSetup (see VARARGIN)
addpath([pwd '\Functions']);
% Choose default command line output for LightingSetup
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LightingSetup wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = LightingSetup_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end


% --- Executes during object creation, after setting all properties.
function lightsImage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lightsImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate lightsImage
    
    global positionsLightsImage
    global lightsInformation
    global handleAxisImage
    
    lightsInformation= {}; %The information of the lights will be stored in a cell array
    %in the following format: [x y Brightness]
    positionsLightsImage= [50 171 167 173 295 173 51 94 168 94 294 95 51 16 168 16 295 16];
    
    handleAxisImage= hObject;
    axis(hObject);
    i= imread('GUI_Images/llums.png');
    imshow(i);
    hold on;
    for i=1:2:length(positionsLightsImage) %print Light
        rectangle('Position',[positionsLightsImage(i) positionsLightsImage(i+1) 26 26],'FaceColor',[0 0 0],'Curvature',[1 1]);
        lightsInformation{ceil(i/2)} = [0.3127 0.326 0];
    end
    
    hold off;
end

function refreshColors(lightNumber)
%handles    structure with handles and user data
%lightNumber number of the light we want to refresh, 0 if all the lights.
    global lightsInformation
    global positionsLightsImage
    global handleAxisImage
    axis(handleAxisImage);
    hold on;
    if(lightNumber== 0)
        for i=1:2:length(positionsLightsImage) %print Light
            info= lightsInformation{ceil(i/2)};
            rgb= xyY2rgb([info(1) info(2) info(3)]);
            rectangle('Position',[positionsLightsImage(i) positionsLightsImage(i+1) 26 26],'FaceColor',[rgb(1) rgb(2) rgb(3)],'Curvature',[1 1]);
        end
    else
        info= lightsInformation{lightNumber};
        i= (lightNumber-1)*2 +1;
        rgb= xyY2rgb([info(1) info(2) info(3)]);
        rectangle('Position',[positionsLightsImage(i) positionsLightsImage(i+1) 26 26],'FaceColor',[rgb(1) rgb(2) rgb(3)],'Curvature',[1 1]); 
    end
    hold off;
end
function  setXValue(value,lightNumber,handles)

    global lightsInformation
    [max,min]= findyLimits(double(value));
    
    info= lightsInformation{lightNumber}
    set(handles.ySlider,'Value',info(2));
    valueSlider= get(handles.ySlider,'Value');
    if(min>valueSlider)
        set(handles.ySlider,'Value',min);
        set(handles.yValue,'String',sprintf('%.2f',min));
    elseif(max<valueSlider)
        set(handles.ySlider,'Value',max);
        set(handles.yValue,'String',sprintf('%.2f',max));
    end
    set(handles.ySlider,'Max',max);
    set(handles.yValue,'Max',max);
    set(handles.ySlider,'Min',min);
    set(handles.yValue,'Min',min);
    
    textLimits= sprintf('(%.2f-%.2f)',min,max);
    set(handles.TextYLimits,'String',textLimits);
    
    set(handles.xValue,'Value',value);
    set(handles.xValue,'String',sprintf('%.2f',value));
    set(handles.xSlider,'Value',value);
   

    info(1)= value;
    info(2)= get(handles.ySlider,'Value');
    lightsInformation{lightNumber}= info;
    refreshColors(lightNumber);
    
end

function setYValue(value, lightNumber,handles)

    global lightsInformation
    [max,min]= findxLimits(double(value));
    
    set(handles.xSlider,'Max',max);
    set(handles.xValue,'Max',max);
    set(handles.xSlider,'Min',min);
    set(handles.xValue,'Min',min);
    
    info= lightsInformation{lightNumber};
    set(handles.xSlider,'Value',info(1));
    
    valueSlider= get(handles.xSlider,'Value');
    if(min>valueSlider)
        set(handles.xSlider,'Value',min);
        set(handles.xValue,'String',sprintf('%.2f',min));
    elseif(max<valueSlider)
        set(handles.xSlider,'Value',max);
        set(handles.xValue,'String',sprintf('%.2f',max));
    end

    
    textLimits= sprintf('(%.2f-%.2f)',min,max);
    set(handles.TextXLimits,'String',textLimits);
    
    set(handles.yValue,'Value',value);
    set(handles.yValue,'String',sprintf('%.2f',value));
    set(handles.ySlider,'Value',value);
   
    info(1)=get(handles.xSlider,'Value');
    info(2)= value;
    lightsInformation{lightNumber}= info;
    refreshColors(lightNumber);
end

function refreshLights(handles,lightNumber)
    global activeLights
    global lightsInformation
    index= find(activeLights==lightNumber);
    if(~isempty(index))
        activeLights(index)=[];
    else
        activeLights= [activeLights lightNumber];
        lightsInformation(lightNumber)={[0.3127,0.326,1]};
    end
    info= lightsInformation{lightNumber};
    
    if(isempty(activeLights))
        set(handles.ActiveLightsText,'String','None');
        set(handles.lightNumberSelector,'String','?');
        set(handles.lightNumberSelector,'Value',1);
        set(handles.xValue,'String','?');
        set(handles.yValue,'String','?');
        set(handles.BValue,'String','?');
        info(3)= 0;
        set(handles.xValue,'String',sprintf('-'));
        set(handles.yValue,'String',sprintf('-'));
        set(handles.BValue,'String',sprintf('-'));
    else
        activeLights= sort(activeLights);
        index= find(activeLights==lightNumber);
        activeLightsString= sprintf('%.d, ', activeLights);
        %activeLightsString= activeLightsString(1:end-2);
        set(handles.ActiveLightsText,'String',activeLightsString);
        numberSelectable= sprintf('%.d \n',activeLights);
        numberSelectable= numberSelectable(1:end-2);
        set(handles.lightNumberSelector,'String',numberSelectable);
        
        if(isempty(index)) 
            %if the light is off
            info(3)= 0;
            set(handles.lightNumberSelector,'Value',1);
            light2=lightSelected(handles);
            info2= lightsInformation{light2};
            setXValue(info2(1),lightNumber,handles);
            setYValue(info2(2),lightNumber,handles);
            set(handles.BValue,'String',sprintf('%0.3f',info2(3)));
            
        else
            %if the light is on
            info(3)=1;
            info(2)= 0.326;
            info(1)= 0.3127;
            setXValue(info(1),lightNumber,handles);
            setYValue(info(2),lightNumber,handles);
            set(handles.xValue,'String',sprintf('%0.3f',info(1)));
            set(handles.yValue,'String',sprintf('%0.3f',info(2)));
            set(handles.BValue,'String',sprintf('%0.3f',info(3))); 
            set(handles.lightNumberSelector,'Value',index);
        end

    end
    lightsInformation{lightNumber}= info;
    refreshColors(lightNumber);
end
% --- Executes on button press in Light1Selector.
function Light1Selector_Callback(hObject, eventdata, handles)
% hObject    handle to Light1Selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Light1Selector
    refreshLights(handles,1);
end


% --- Executes on button press in Light4Selector.
function Light4Selector_Callback(hObject, eventdata, handles)
% hObject    handle to Light4Selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Light4Selector

    refreshLights(handles,4);
end

% --- Executes on button press in Light7Selector.
function Light7Selector_Callback(hObject, eventdata, handles)
% hObject    handle to Light7Selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Light7Selector

    
    refreshLights(handles,7);
end


% --- Executes on button press in Light8Selector.
function Light8Selector_Callback(hObject, eventdata, handles)
% hObject    handle to Light8Selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Light8Selector
    
    refreshLights(handles,8);
end

% --- Executes on button press in Light5Selector.
function Light5Selector_Callback(hObject, eventdata, handles)
% hObject    handle to Light5Selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Light5Selector
    
    refreshLights(handles,5);
end

% --- Executes on button press in Light2Selector.
function Light2Selector_Callback(hObject, eventdata, handles)
% hObject    handle to Light2Selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Light2Selector

    refreshLights(handles,2);
end

% --- Executes on button press in Light9Selector.
function Light9Selector_Callback(hObject, eventdata, handles)
% hObject    handle to Light9Selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Light9Selector

    refreshLights(handles,9);
end

% --- Executes on button press in Light6Selector.
function Light6Selector_Callback(hObject, eventdata, handles)
% hObject    handle to Light6Selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Light6Selector

    
    refreshLights(handles,6);
end

% --- Executes on button press in Light3Selector.
function Light3Selector_Callback(hObject, eventdata, handles)
% hObject    handle to Light3Selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Light3Selector

    
    refreshLights(handles,3);
end

function [max,min] = findxLimits(y)
%FINDLIMITS To find the x limits for a given y of a given gamut 

    step= 0.001;
    gamut=[0.675 0.322; 0.409 0.518; 0.167 0.04;0.675 0.322];
    for min=0:step:1
        in= inpolygon(min,y,gamut(:,1),gamut(:,2));
        if(in)
            break;
        end
    end

    for max=1:-step:0
        in= inpolygon(max,y,gamut(:,1),gamut(:,2));
        if(in)
            break;
        end
    end

end

function [max,min] = findyLimits(x)
%FINDLIMITS To find the y limits for a given x of a given gamut 

    step= 0.001;
    gamut=[0.675 0.322; 0.409 0.518; 0.167 0.04;0.675 0.322];
    for min=0:step:1
        in= inpolygon(x,min,gamut(:,1),gamut(:,2));
        if(in)
            break;
        end
    end

    for max=1:-step:0
        in= inpolygon(x,max,gamut(:,1),gamut(:,2));
        if(in)
            break;
        end
    end

end

function number= lightSelected(handles)
    global activeLights
    if(~isempty(activeLights))
        value= get(handles.lightNumberSelector,'Value');
        number= activeLights(value);
    else 
        number= -1;
    end
    
end

% --- Executes on slider movement.
function xSlider_Callback(hObject, eventdata, handles)
% hObject    handle to xSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    lightNumber= lightSelected(handles);
    value= get(hObject,'Value');
    setXValue(value,lightNumber,handles);
    
end


function xValue_Callback(hObject, eventdata, handles)
% hObject    handle to xValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xValue as text
%        str2double(get(hObject,'String')) returns contents of xValue as a double
    lightNumber= lightSelected(handles);
    value= str2double(get(hObject,'String'));
    min= get(hObject,'Min');
    max = get(hObject,'Max');
    if(isnumeric(value) && value>=min && value <=max)
        setXValue(value,lightNumber, handles);
    else
        if((value-min) < (max-value))
            setXValue(min,lightNumber,handles);
        else
            setXValue(max,lightNumber,handles);
        end
    end
    
    
end



% --- Executes on slider movement.
function ySlider_Callback(hObject, eventdata, handles)
% hObject    handle to ySlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    lightNumber= lightSelected(handles);
    value= get(hObject,'Value');
    setYValue(value,lightNumber,handles);
end



function yValue_Callback(hObject, eventdata, handles)
% hObject    handle to yValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yValue as text
%        str2double(get(hObject,'String')) returns contents of yValue as a double
    lightNumber= lightSelected(handles);
    value= str2double(get(hObject,'String'));
    min= get(hObject,'Min');
    max = get(hObject,'Max');
    if(isnumeric(value) && value>=min && value <=max)
        setYValue(value,lightNumber, handles);
    else
        if((value-min) < (max-value))
            setYValue(min,lightNumber,handles);
        else
            setYValue(max,lightNumber,handles);
        end
    end
end



% --- Executes on slider movement.
function BSlider_Callback(hObject, eventdata, handles)
% hObject    handle to BSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
end


function BValue_Callback(hObject, eventdata, handles)
% hObject    handle to BValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BValue as text
%        str2double(get(hObject,'String')) returns contents of BValue as a double
end


% --- Executes during object creation, after setting all properties.
function ActiveLightsText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ActiveLightsText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
    
    global activeLights
    activeLights= [];
    
end

% --- Executes on selection change in lightNumberSelector.
function lightNumberSelector_Callback(hObject, eventdata, handles)
% hObject    handle to lightNumberSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lightNumberSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lightNumberSelector
    
    global activeLights
    global lightsInformation
    value= get(hObject,'Value');
    lightNumber= activeLights(value);
    setXValue(lightInfo(1),lightNumber, handles);
    setYValue(lightInfo(2),lightNumber, handles);
end


% --- Executes on selection change in modeColour.
function modeColour_Callback(hObject, eventdata, handles)
% hObject    handle to modeColour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns modeColour contents as cell array
%        contents{get(hObject,'Value')} returns selected item from modeColour

end


% --- Executes on selection change in BrightnessMode.
function BrightnessMode_Callback(hObject, eventdata, handles)
% hObject    handle to BrightnessMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns BrightnessMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from BrightnessMode


end

% --- Executes on selection change in ChangeApplyMenu.
function ChangeApplyMenu_Callback(hObject, eventdata, handles)
% hObject    handle to ChangeApplyMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ChangeApplyMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ChangeApplyMenu
end

% --- Executes on button press in startButton.
function startButton_Callback(hObject, eventdata, handles)
% hObject    handle to startButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    %TO DO
end

% --- Executes on button press in previewButton.
function previewButton_Callback(hObject, eventdata, handles)
% hObject    handle to previewButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    %TO DO
end


% --------------------------------------------------------------------
function ExperimentMenu_Callback(hObject, eventdata, handles)
% hObject    handle to ExperimentMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function HelpMenu_Callback(hObject, eventdata, handles)
% hObject    handle to HelpMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function AboutMenu_Callback(hObject, eventdata, handles)
% hObject    handle to AboutMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function LightingMenu_Callback(hObject, eventdata, handles)
% hObject    handle to LightingMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    LightningSetup
end

% --------------------------------------------------------------------
function CamerasMenu_Callback(hObject, eventdata, handles)
% hObject    handle to CamerasMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function ObjectsMenu_Callback(hObject, eventdata, handles)
% hObject    handle to ObjectsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    ObjectsSetup
end

% --------------------------------------------------------------------
function RotatoryTableMenu_Callback(hObject, eventdata, handles)
% hObject    handle to RotatoryTableMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    rotatoryTableSetup
end


% --------------------------------------------------------------------
function SetupMenu_Callback(hObject, eventdata, handles)
% hObject    handle to SetupMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end


% --------------------------------------------------------------------
function newMenu_Callback(hObject, eventdata, handles)
% hObject    handle to newMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function saveMenu_Callback(hObject, eventdata, handles)
% hObject    handle to saveMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function loadMenu_Callback(hObject, eventdata, handles)
% hObject    handle to loadMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end
