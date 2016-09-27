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

% Last Modified by GUIDE v2.5 27-Sep-2016 14:02:10

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

handles.lightsInformation= {}; %The information of the lights will be stored in a cell array
%in the following format: [x1 y1 Brightness1, x2 y2 Brightness2, x3 y3 Brightness3, etc..]
handles.positionsLightsImage = [50 171 167 173 295 173 51 94 168 94 294 95 51 16 168 16 295 16];
handles.activeLights= [];

axis(handles.lightsImage);
i= imread('GUI_Images/llums.png');
hold on;
imshow(i);
for i=1:2:length(handles.positionsLightsImage) %print Light
    rectangle('Position',[handles.positionsLightsImage(i) handles.positionsLightsImage(i+1) 26 26],'FaceColor',[0 0 0],'Curvature',[1 1]);
    handles.lightsInformation{ceil(i/2)} = [0.3127 0.326 0];
end
    
hold off;

axes(handles.chromacityDiagram);
hold on
chromaticDiagram();
hold on
handles.handlePoint=plot(0,0,'k+');
handles.handleFinalPoint= plot(0,0,'k*');
set(handles.handlePoint,'Visible','off');
set(handles.handleFinalPoint,'Visible','off');
hold off
hold off
makeObjectsClickable(handles.chromacityDiagram);
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


%     
%     handles.lightsInformation= {}; %The information of the lights will be stored in a cell array
%     %in the following format: [x1 y1 Brightness1, x2 y2 Brightness2, x3 y3 Brightness3, etc..]
%     handles.positionsLightsImage = [50 171 167 173 295 173 51 94 168 94 294 95 51 16 168 16 295 16];
% 
%     axis(hObject);
%     i= imread('GUI_Images/llums.png');
%     hold on;
%     imshow(i);
%     for i=1:2:length(handles.positionsLightsImage) %print Light
%         rectangle('Position',[handles.positionsLightsImage(i) handles.positionsLightsImage(i+1) 26 26],'FaceColor',[0 0 0],'Curvature',[1 1]);
%         handles.lightsInformation{ceil(i/2)} = [0.3127 0.326 0];
%     end
%     
%     hold off;

end

function refreshColors(lightNumber,lightsInformation, positionsLightsImage, handleAxisImage)
%handles    structure with handles and user data
%lightNumber number of the light we want to refresh, 0 if all the lights.
     
    axes(handleAxisImage);
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
function  setXValue(value,lightNumber, handles)
    %function called when setting the X value.
    %   value--> the value for setting the x
    %   lightNumber --> number of light being set
    %   xType --> 0 or 1 depending if the initial X or the final X is being
    %   set.
    %   handles --> handles of the GUI
    
    
    [max,min]= findyLimits(double(value));
    
    info= handles.lightsInformation{lightNumber};
    
    xType= get(handles.selectedPoint,'Value');
    linStepsValue= get(handles.linearStepsValue,'String');
    if (strcmp('1',linStepsValue))
        both= 1;
    else
        both= 0;
    end
    
    if (xType ==1 || both)
        %if the initial point is being set
        set(handles.yValue,'Max',max);
        set(handles.yValue,'Min',min);
    
        textLimits= sprintf('(%.2f-%.2f)',min,max);
        set(handles.TextYLimits,'String',textLimits);
    
        set(handles.xValue,'Value',value);
        set(handles.xValue,'String',sprintf('%.3f',value));
   
        info(1)= value;
        handles.lightsInformation{lightNumber}= info;
        refreshColors(lightNumber, handles.lightsInformation, handles.positionsLightsImage, handles.lightsImage);
    
        set(handles.handlePoint,'Visible','on');
        set(handles.handlePoint','XData',value);
    end
    
    if (xType ==2 || both)
        set(handles.yFinalValue,'Max',max);
        set(handles.yFinalValue,'Min',min);
    
        textLimits= sprintf('(%.2f-%.2f)',min,max);
        set(handles.textFinalYLimits,'String',textLimits);
    
        set(handles.xFinalValue,'Value',value);
        set(handles.xFinalValue,'String',sprintf('%.3f',value));
   
    
        set(handles.handleFinalPoint,'Visible','on');
        set(handles.handleFinalPoint','XData',value);
        %if the final point is being set
    end

end

function setYValue(value, lightNumber,handles)

    [max,min]= findxLimits(double(value));
   
    info= handles.lightsInformation{lightNumber};
    
    yType= get(handles.selectedPoint,'Value');
    linStepsValue= get(handles.linearStepsValue,'String');
    
    if (strcmp('1',linStepsValue))
        both= 1;
    else
        both= 0;
    end
    
    if (yType==1|| both)
        set(handles.xValue,'Max',max);
        set(handles.xValue,'Min',min);
    
        textLimits= sprintf('(%.2f-%.2f)',min,max);
        set(handles.TextXLimits,'String',textLimits);
    
        set(handles.yValue,'Value',value);
        set(handles.yValue,'String',sprintf('%.3f',value));
   
        info(2)= value;
        handles.lightsInformation{lightNumber}= info;
        refreshColors(lightNumber, handles.lightsInformation, handles.positionsLightsImage, handles.lightsImage);
    
        set(handles.handlePoint,'Visible','on');
        set(handles.handlePoint','YData',value);
    end
    
    if (yType==2||both)
        set(handles.xFinalValue,'Max',max);
        set(handles.xFinalValue,'Min',min);
    
        textLimits= sprintf('(%.2f-%.2f)',min,max);
        set(handles.xFinalLimits,'String',textLimits);
    
        set(handles.yFinalValue,'Value',value);
        set(handles.yFinalValue,'String',sprintf('%.3f',value));
    
        set(handles.handleFinalPoint,'Visible','on');
        set(handles.handleFinalPoint','YData',value);
    end
end

function refreshLights(handles,lightNumber)

    activeLights= handles.activeLights
    index= find(activeLights==lightNumber)
    
    if(~isempty(index))
        activeLights(index)= []; 
    else
        activeLights= [activeLights lightNumber]
        if(isempty(handles.lightsInformation(lightNumber)))
            lightsInformation(lightNumber)={[0.3127,0.326,1]};
        end
        set(handles.linearStepsValue,'String','1');
        set(handles.linearStepsValue,'Value',1);
        set(handles.xFinalValue,'String','?');
        set(handles.yFinalValue,'String','?');
        set(handles.finalBrightnessValue,'String','?');
        set(handles.TextXLimits,'String','(0-1)');
        set(handles.TextYLimits,'String','(0-1)');
    end
    info= handles.lightsInformation{lightNumber};
    
    if(isempty(handles.activeLights))
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
        handles.activeLights= sort(handles.activeLights);
        index= find(handles.activeLights==lightNumber);
        activeLightsString= sprintf('%.d, ', handles.activeLights);
        %activeLightsString= activeLightsString(1:end-2);
        set(handles.ActiveLightsText,'String',activeLightsString);
        numberSelectable= sprintf('%.d \n',handles.activeLights);
        numberSelectable= numberSelectable(1:end-2);
        set(handles.lightNumberSelector,'String',numberSelectable);
        
        if(isempty(index)) 
            %if the light is off
            info(3)= 0;
            set(handles.lightNumberSelector,'Value',1);
            light2=lightSelected(handles);
            info2= handles.lightsInformation{light2};
            setXValue(info2(1),lightNumber,handles);
            setYValue(info2(2),lightNumber,handles);
            set(handles.BValue,'String',sprintf('%0.3f',info2(3)));
            
        else
            %if the light is on
            info(3)=1;
            %info(2)= 0.326;
            %info(1)= 0.3127;
            setXValue(info(1),lightNumber,handles);
            setYValue(info(2),lightNumber,handles);
            set(handles.xValue,'String',sprintf('%0.3f',info(1)));
            set(handles.yValue,'String',sprintf('%0.3f',info(2)));
            set(handles.BValue,'String',sprintf('%0.3f',info(3))); 
            set(handles.lightNumberSelector,'Value',index);
        end

    end
    handles.lightsInformation{lightNumber}= info;
    refreshColors(lightNumber, handles.lightsInformation, handles.positionsLightsImage, handles.lightsImage);
    handles.activeLights= activeLights
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

    if(~isempty(handles.activeLights))
        value= get(handles.lightNumberSelector,'Value');
        number= handles.activeLights(value);
    else 
        number= -1;
    end
    
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
    

    
end

% --- Executes on selection change in lightNumberSelector.
function lightNumberSelector_Callback(hObject, eventdata, handles)
% hObject    handle to lightNumberSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lightNumberSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lightNumberSelector
    
    value= get(hObject,'Value');
    lightNumber= handles.activeLights(value);
    lightInfo= handles.lightsInformation{lightNumber};
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


% --- Executes during object creation, after setting all properties.
function chromacityDiagram_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chromacityDiagram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate chromacityDiagram


end

function makeObjectsClickable(axisHandles)
    children= axisHandles.Children;
    for i=1:length(children)
        set(children(i),'HitTest','off');
    end
end

% --- Executes on mouse press over axes background.
function chromacityDiagram_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to chromacityDiagram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if(~isempty(handles.activeLights))
        lightNumber= lightSelected(handles);
        p= get(hObject,'CurrentPoint');
        gamut=[0.675 0.322; 0.409 0.518; 0.167 0.04;0.675 0.322];
        p= p(1,:);
        if(inpolygon(p(1),p(2),gamut(:,1),gamut(:,2)))
            setXValue(p(1),lightNumber,handles);
            setYValue(p(2),lightNumber,handles);
        else
            [~,x,y]= p_poly_dist(p(1),p(2),gamut(:,1),gamut(:,2));
            if(lightNumber~=-1)
                setXValue(x,lightNumber,handles);
                setYValue(y,lightNumber,handles);
            end
        end

    else
        set(handles.handlePoint,'Visible','off');
        set(handles.handleFinalPoint,'Visible','off');
    end
end


% --- Executes on button press in previewConfiguration.
function previewConfiguration_Callback(hObject, eventdata, handles)
% hObject    handle to previewConfiguration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --- Executes on button press in saveConfiguration.
function saveConfiguration_Callback(hObject, eventdata, handles)
% hObject    handle to saveConfiguration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --- Executes on selection change in lightSteps.
function lightSteps_Callback(hObject, eventdata, handles)
% hObject    handle to lightSteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lightSteps contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lightSteps

end
% --- Executes during object creation, after setting all properties.
function lightSteps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lightSteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in previewLightConfiguration.
function previewLightConfiguration_Callback(hObject, eventdata, handles)
% hObject    handle to previewLightConfiguration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --- Executes on button press in addToSteps.
function addToSteps_Callback(hObject, eventdata, handles)
% hObject    handle to addToSteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
end


% --- Executes on slider movement.
function slider6_Callback(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
end

% --- Executes during object creation, after setting all properties.
function slider6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end


% --- Executes on selection change in popupmenu14.
function popupmenu14_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu14 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu14
end

% --- Executes during object creation, after setting all properties.
function popupmenu14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function yFinalValue_Callback(hObject, eventdata, handles)
% hObject    handle to yFinalValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yFinalValue as text
%        str2double(get(hObject,'String')) returns contents of yFinalValue as a double
end

% --- Executes during object creation, after setting all properties.
function yFinalValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yFinalValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function xFinalValue_Callback(hObject, eventdata, handles)
% hObject    handle to xFinalValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xFinalValue as text
%        str2double(get(hObject,'String')) returns contents of xFinalValue as a double
end

% --- Executes during object creation, after setting all properties.
function xFinalValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xFinalValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function finalBrightnessValue_Callback(hObject, eventdata, handles)
% hObject    handle to finalBrightnessValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of finalBrightnessValue as text
%        str2double(get(hObject,'String')) returns contents of finalBrightnessValue as a double
end

% --- Executes during object creation, after setting all properties.
function finalBrightnessValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to finalBrightnessValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function linearStepsValue_Callback(hObject, eventdata, handles)
% hObject    handle to linearStepsValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of linearStepsValue as text
%        str2double(get(hObject,'String')) returns contents of linearStepsValue as a double
    
    if(strcmp(get(hObject,'String'),'1'))
        value= get(handles.lightNumberSelector,'Value');
        lightNumber= handles.activeLights(value);
        lightInfo= handles.lightsInformation{lightNumber};
        setXValue(lightInfo(1),lightNumber, handles);
        setYValue(lightInfo(2),lightNumber, handles);
    end
end

% --- Executes during object creation, after setting all properties.
function linearStepsValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to linearStepsValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on selection change in selectedPoint.
function selectedPoint_Callback(hObject, eventdata, handles)
% hObject    handle to selectedPoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns selectedPoint contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selectedPoint
end

% --- Executes during object creation, after setting all properties.
function selectedPoint_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectedPoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on slider movement.
function previewSpeed_Callback(hObject, eventdata, handles)
% hObject    handle to previewSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
end

% --- Executes during object creation, after setting all properties.
function previewSpeed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to previewSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end
