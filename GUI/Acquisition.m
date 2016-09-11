function varargout = Acquisition(varargin)
% ACQUISITION MATLAB code for Acquisition.fig
%      ACQUISITION, by itself, creates a new ACQUISITION or raises the existing
%      singleton*.
%
%      H = ACQUISITION returns the handle to a new ACQUISITION or the handle to
%      the existing singleton*.
%
%      ACQUISITION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ACQUISITION.M with the given input arguments.
%
%      ACQUISITION('Property','Value',...) creates a new ACQUISITION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Acquisition_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Acquisition_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Acquisition

% Last Modified by GUIDE v2.5 09-Sep-2016 14:22:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
addpath([pwd '\Functions']);
addpath([pwd '\GUI_Images']);
addpath([pwd '\Logs']);

gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Acquisition_OpeningFcn, ...
                   'gui_OutputFcn',  @Acquisition_OutputFcn, ...
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


% --- Executes just before Acquisition is made visible.
function Acquisition_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Acquisition (see VARARGIN)

% Choose default command line output for Acquisition
global simulationStop
simulationStop= false;

refreshTableFiles(handles);
newTableConfiguration(handles);

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Acquisition wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = Acquisition_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end



% --- Executes on button press in startButton.
function startButton_Callback(hObject, eventdata, handles)
% hObject    handle to startButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    %TO DO
end

% --- Executes on button press in pauseButton.
function pauseButton_Callback(hObject, eventdata, handles)
% hObject    handle to pauseButton (see GCBO)
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
    LightingSetup
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
function log_CreateFcn(hObject, eventdata, handles)
% hObject    handle to log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global logHandle
    logHandle= hObject;
    add2Log('User interface opened');
    
end

% --- Executes on button press in stopButton.
function stopButton_Callback(hObject, eventdata, handles)
% hObject    handle to stopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --- Executes on button press in pushButton.
function pushButton_Callback(hObject, eventdata, handles)
% hObject    handle to pushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --- Executes on slider movement.
function simulationSpeed_Callback(hObject, eventdata, handles)
% hObject    handle to simulationSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
end

% --- Executes during object creation, after setting all properties.
function simulationSpeed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to simulationSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end


% --- Executes on selection change in selectorTableConfiguration.
function selectorTableConfiguration_Callback(hObject, eventdata, handles)
% hObject    handle to selectorTableConfiguration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns selectorTableConfiguration contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selectorTableConfiguration
    newTableConfiguration(handles);
end

% --- Executes during object creation, after setting all properties.
function selectorTableConfiguration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectorTableConfiguration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global Positions;
Positions= [];
end

function changeInclination(newInclination, handles)
    axes(handles.inclinationPlot);
    m= -5.1667;
    n= 237.5;
    y= newInclination*m+n;
    speedPreview= get(handles.previewSpeedTable,'Value');
    
    hold on
    rectangle('Position',[5,y,70,20],'FaceColor',[0 0.8 0.2]);
    drawnow
    hold off
end

function changeRotation(newRotation,handles)
    axes(handles.rotationPlot);
    
    stringRotation= get(handles.currentRotationString,'String');
    currentRotation= str2double(stringRotation);
    
    rotationChange= newRotation- currentRotation;
    speedPreview= get(handles.previewSpeedTable,'Value');
    
    step= 0.01*speedPreview;
    hold on
    for rotation=1:step:rotationChange
        camroll(step);
        %drawnow;
    end
    pause(0.5/speedPreview);
    hold off
end

function newTableConfiguration(handles)
    global Positions;
    index= get(handles.selectorTableConfiguration,'Value');
    files= dir('Setups/Table');
    files= files(4:end);
    [~,ind]= sort({files.date});
    files= files(ind);
    file= strcat('Setups/Table/',files(index).name);
    Positions= dlmread(file);
    
    set(handles.movesDoneString,'String','0');
    set(handles.movesLeftString,'String',num2str(size(Positions,1)-1));
    set(handles.currentRotationString,'String',num2str(Positions(1,1)));
    set(handles.currentInclinationString,'String',num2str(Positions(1,2)));
    
    changeRotation(Positions(1,1),handles);
    changeInclination(Positions(1,2),handles);
    add2Log(strcat('New table configuration loaded. (',files(index).name,')'));
end

function refreshTableFiles(handles)
    files= dir('Setups/Table');
    files= files(4:end);
    [~,ind]=sort({files.date});
    files= files(ind);
    list= {};
    for i=1:length(files)
        string= [files(i).name(1:end-4), '   (Created at ', files(i).date,' )'];
        list= [list; {string} ];
    end
%     currentText= cellstr(get(logHandle,'String'));
%     text= [{string};currentText];
    set(handles.selectorTableConfiguration,'String',list);
end

function refreshTableConfiguration_Callback(hObject, eventdata, handles)
% hObject    handle to refreshTableConfiguration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    refreshTableFiles(handles);
    newTableConfiguration(handles);
end

% --- Executes on selection change in selectorLightsConfiguration.
function selectorLightsConfiguration_Callback(hObject, eventdata, handles)
% hObject    handle to selectorLightsConfiguration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns selectorLightsConfiguration contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selectorLightsConfiguration
    
end

% --- Executes during object creation, after setting all properties.
function selectorLightsConfiguration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectorLightsConfiguration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in refreshLightsConfiguration.
function refreshLightsConfiguration_Callback(hObject, eventdata, handles)
% hObject    handle to refreshLightsConfiguration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --- Executes on selection change in selectorConfigurationCamera.
function selectorConfigurationCamera_Callback(hObject, eventdata, handles)
% hObject    handle to selectorConfigurationCamera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns selectorConfigurationCamera contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selectorConfigurationCamera
end

% --- Executes during object creation, after setting all properties.
function selectorConfigurationCamera_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectorConfigurationCamera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in refreshCameraConfigurations.
function refreshCameraConfigurations_Callback(hObject, eventdata, handles)
% hObject    handle to refreshCameraConfigurations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end


% --- Executes on selection change in selectorObjectConfiguration.
function selectorObjectConfiguration_Callback(hObject, eventdata, handles)
% hObject    handle to selectorObjectConfiguration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns selectorObjectConfiguration contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selectorObjectConfiguration
end

% --- Executes during object creation, after setting all properties.
function selectorObjectConfiguration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectorObjectConfiguration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in refreshObjectConfiguration.
function refreshObjectConfiguration_Callback(hObject, eventdata, handles)
% hObject    handle to refreshObjectConfiguration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --- Executes on selection change in ObjectSelector.
function ObjectSelector_Callback(hObject, eventdata, handles)
% hObject    handle to ObjectSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ObjectSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ObjectSelector
end

% --- Executes during object creation, after setting all properties.
function ObjectSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ObjectSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in previewCamerasButton.
function previewCamerasButton_Callback(hObject, eventdata, handles)
% hObject    handle to previewCamerasButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --- Executes on slider movement.
function previewSpeedCameras_Callback(hObject, eventdata, handles)
% hObject    handle to previewSpeedCameras (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
end

% --- Executes during object creation, after setting all properties.
function previewSpeedCameras_CreateFcn(hObject, eventdata, handles)
% hObject    handle to previewSpeedCameras (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end


% --- Executes on button press in previewButtonTable.
function previewButtonTable_Callback(hObject, eventdata, handles)
% hObject    handle to previewButtonTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global simulationStop;
    global Positions;
    movesDone=1;
    movesLeft= size(Positions,1)-1;
    
    set(handles.movesDoneString,'String',num2str(movesDone));
    set(handles.movesLeftString,'String',num2str(movesLeft));
    
    while(movesLeft~=0 && ~simulationStop)
        if(Positions(movesDone+1,1)~=Positions(movesDone,1))
            changeRotation(Positions(movesDone+1,1),handles);
        end
        
        if(Positions(movesDone+1,2)~=Positions(movesDone,2))
            changeInclination(Positions(movesDone+1,2),handles);
        end
        movesDone= movesDone+1;
        movesLeft= movesLeft-1;
        set(handles.movesDoneString,'String',num2str(movesDone));
        set(handles.movesLeftString,'String',num2str(movesLeft));
    end
    
end

% --- Executes on slider movement.
function previewSpeedTable_Callback(hObject, eventdata, handles)
% hObject    handle to previewSpeedTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
end

% --- Executes during object creation, after setting all properties.
function previewSpeedTable_CreateFcn(hObject, eventdata, handles)
% hObject    handle to previewSpeedTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end


% --- Executes during object creation, after setting all properties.
function inclinationPlot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inclinationPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate inclinationPlot
    
    axes(hObject);
    hold on
    imshow('GUI_Images/inclination.png');
    hold off
end


% --- Executes during object creation, after setting all properties.
function rotationPlot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotationPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate rotationPlot

    axes(hObject);
    hold on
    imshow('GUI_Images/tableSmall.png');
    hold off
end


% --- Executes on selection change in log.
function log_Callback(hObject, eventdata, handles)
% hObject    handle to log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns log contents as cell array
%        contents{get(hObject,'Value')} returns selected item from log
end
