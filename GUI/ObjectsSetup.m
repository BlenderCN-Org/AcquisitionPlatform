function varargout = ObjectsSetup(varargin)
% OBJECTSSETUP MATLAB code for ObjectsSetup.fig
%      OBJECTSSETUP, by itself, creates a new OBJECTSSETUP or raises the existing
%      singleton*.
%
%      H = OBJECTSSETUP returns the handle to a new OBJECTSSETUP or the handle to
%      the existing singleton*.
%
%      OBJECTSSETUP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OBJECTSSETUP.M with the given input arguments.
%
%      OBJECTSSETUP('Property','Value',...) creates a new OBJECTSSETUP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ObjectsSetup_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ObjectsSetup_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ObjectsSetup

% Last Modified by GUIDE v2.5 06-Sep-2016 14:34:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ObjectsSetup_OpeningFcn, ...
                   'gui_OutputFcn',  @ObjectsSetup_OutputFcn, ...
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


% --- Executes just before ObjectsSetup is made visible.
function ObjectsSetup_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ObjectsSetup (see VARARGIN)

% Choose default command line output for ObjectsSetup
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ObjectsSetup wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = ObjectsSetup_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end



% --- Executes on selection change in ObjectsAvailableList.
function ObjectsAvailableList_Callback(hObject, eventdata, handles)
% hObject    handle to ObjectsAvailableList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ObjectsAvailableList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ObjectsAvailableList
end

% --- Executes during object creation, after setting all properties.
function ObjectsAvailableList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ObjectsAvailableList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

    global positions_x
    global positions_y
    global orientations
    positions_x= {};
    positions_y= {};
    orientations = {};

    %Read available objects
    objects= {'Test Object 1', 'Test Object 2', 'Test Object 3'};
    objects= sort(objects);
    set(hObject,'String',objects);
    
    

end


% --- Executes on button press in ToActiveObjects.
function ToActiveObjects_Callback(hObject, eventdata, handles)
% hObject    handle to ToActiveObjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    global positions_x
    global positions_y
    global orientations

    %X position 
    xAvailables= get(handles.XPositionAvailable,'String');
    xValue= get(handles.XPositionAvailable, 'Value');

    %Y position
    yAvailables= get(handles.YPositionAvailable,'String');
    yValue= get(handles.YPositionAvailable,'Value');

    %orientations
    orientationAvailable= get(handles.OrientationAvailable,'String');
    orientationValue= get(handles.OrientationAvailable,'Value');
    
    if(isempty(find(strcmp([positions_x(:)],xAvailables(xValue)))) || isempty(find(strcmp([positions_y(:)],yAvailables(yValue)))))
        positions_x= [positions_x xAvailables(xValue)];
        positions_y= [positions_y yAvailables(yValue)];
        orientations= [orientations orientationAvailable(orientationValue)];
        %Name Object
        namesObjects= get(handles.ObjectsAvailableList,'String');
        valueName= get(handles.ObjectsAvailableList,'Value');
        set(handles.ObjectsInTableList,'String',[get(handles.ObjectsInTableList,'String'); namesObjects(valueName)]);
        namesObjects(valueName)=[];
        set(handles.ObjectsAvailableList,'String',namesObjects);
        ObjectsInTableList_Callback(handles.ObjectsInTableList,[],handles);
        set(handles.ObjectsInTableList,'Value',1);
        set(handles.ObjectsAvailableList,'Value',1);
    else
        errordlg('The table already has an object at that position. Please select another position.','Position occupied');
    end

    
    

    
    %Orientation
    
end

% --- Executes on button press in ToDeactivedObjects.
function ToDeactivedObjects_Callback(hObject, eventdata, handles)
% hObject    handle to ToDeactivedObjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global positions_x
    global positions_y
    global orientations
    
    names= get(handles.ObjectsInTableList,'String');
    value= get(handles.ObjectsInTableList,'Value');
    if(~isempty(names))
        availableObjects= get(handles.ObjectsAvailableList,'String');
        availableObjects= sort([availableObjects; names(value)]);
        set(handles.ObjectsAvailableList,'String',availableObjects);
        set(handles.ObjectsInTableList,'Value',1);
        set(handles.ObjectsAvailableList,'Value',1);
        names(value) = [];
        set(handles.ObjectsInTableList,'String',names);
        positions_x(value)=[];
        positions_y(value)=[];
        orientations(value)= [];
        
    end
    ObjectsInTableList_Callback(handles.ObjectsInTableList,[],handles);
    
end

% --- Executes on selection change in ObjectsInTableList.
function ObjectsInTableList_Callback(hObject, eventdata, handles)
% hObject    handle to ObjectsInTableList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ObjectsInTableList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ObjectsInTableList

    global positions_x
    global positions_y
    global orientations
    
    names= get(hObject,'String');
    value= get(hObject,'Value');
    if(isempty(names))
        set(handles.XPositionDisplay,'String','?');
        set(handles.YPositionDisplay,'String','?');
        set(handles.OrientationDisplay,'String','?');
    else
        set(handles.XPositionDisplay,'String',positions_x(value));
        set(handles.YPositionDisplay,'String',positions_y(value));
        set(handles.OrientationDisplay,'String',orientations(value));
    end
end

% --- Executes during object creation, after setting all properties.
function ObjectsInTableList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ObjectsInTableList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
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
