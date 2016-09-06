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

% Last Modified by GUIDE v2.5 05-Sep-2016 17:58:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
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
addpath('Lighting');
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

function MinimumValueRot_Callback(hObject, eventdata, handles)
% hObject    handle to MinimumValueRot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinimumValueRot as text
%        str2double(get(hObject,'String')) returns contents of MinimumValueRot as a double
    global maxDegreeRotationValue
    global maxStepRotationValue
    global lastUnitRot
    maxRot= str2double(get(handles.MaximumValueRot,'String'));
    minRot= str2double(get(hObject,'String'));
    
    if(strcmp(lastUnitRot,'Degrees'))
        %case of Degrees
        if(minRot>maxDegreeRotationValue)
            minRot= maxDegreeRotationValue;
            set(hObject,'String',num2str(minRot));
        end
        
        if(minRot<0)
            minRot= 0;
            set(hObject,'String',num2str(minRot));
        end
    else
        %case of Steps
        if(minRot>maxStepRotationValue)
            minRot= maxStepRotationValue;
            set(hObject,'String',num2str(minRot));
        end
        
        if(minRot<0)
            minRot= 0;
            set(hObject,'String',num2str(minRot));
        end
    end
    
    if(minRot>=maxRot)
        set(handles.MaximumValueRot,'String',num2str(minRot));
        set(handles.TotalStepsValueRot,'String',num2str(0));
        set(handles.StepValueRot,'String',num2str(0));
    else
        set(handles.TotalStepsValueRot,'String',num2str(1));        
    end
    
    TotalStepsValueRot_Callback(handles.TotalStepsValueRot,[],handles);
end

% --- Executes during object creation, after setting all properties.
function MinimumValueRot_CreateFcn(hObject, eventdata, handles)

% hObject    handle to MinimumValueRot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    set(hObject,'String',num2str(0));
end

% --- Executes on selection change in ConversionRot.
function ConversionRot_Callback(hObject, eventdata, handles)
% hObject    handle to ConversionRot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ConversionRot contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ConversionRot
    global lastUnitRot
    conversionDegree2Steps= 8000/360;
    conversion= get(hObject,'Value');
    maxRot= handles.MaximumValueRot;
    minRot= handles.MinimumValueRot;
    stepPanel= handles.StepPanelRot;
    stepValue= handles.StepValueRot;
    if(conversion==1)
        conversion= 'Degrees';
    else
        conversion= 'Engine Steps';
    end
    if(~strcmp(conversion,lastUnitRot))
        previousMaxValue= str2double(get(maxRot,'String'));
        previousMinValue= str2double(get(minRot,'String'));
        previousStep=str2double(get(stepValue,'String'));
        if(strcmp(lastUnitRot,'Degrees'))
            %conversionToSteps
            set(maxRot,'String',num2str(previousMaxValue*conversionDegree2Steps));
            set(minRot,'String',num2str(previousMinValue*conversionDegree2Steps));
            set(stepPanel,'Title','Step (Engine Steps)');
            set(stepValue,'String',num2str(previousStep*conversionDegree2Steps));
        else
            %conversionToDeg
            set(maxRot,'String',num2str(previousMaxValue*1/conversionDegree2Steps));
            set(minRot,'String',num2str(previousMinValue*1/conversionDegree2Steps));
            set(stepPanel,'Title','Step (Degrees)');
            set(stepValue,'String',num2str(previousStep*1/conversionDegree2Steps));
        end 
    end
    lastUnitRot= conversion;
end

% --- Executes during object creation, after setting all properties.
function ConversionRot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ConversionRot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    global lastUnitRot
    lastUnitRot='Degrees';
end

function MaximumValueRot_Callback(hObject, eventdata, handles)
% hObject    handle to MaximumValueRot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaximumValueRot as text
%        str2double(get(hObject,'String')) returns contents of MaximumValueRot as a double
    global maxDegreeRotationValue
    global maxStepRotationValue
    global lastUnitRot
    maxRot= str2double(get(hObject,'String'));
    minRot= str2double(get(handles.MinimumValueRot,'String'));
    
    if(strcmp(lastUnitRot,'Degrees'))
        %case of Degrees
        if(maxRot>maxDegreeRotationValue)
            maxRot= maxDegreeRotationValue;
            set(hObject,'String',num2str(maxRot));
        end
        
        if(maxRot<0)
            maxRot= 0;
            set(hObject,'String',num2str(maxRot));
        end
    else
        %case of Steps
        if(maxRot>maxStepRotationValue)
            maxRot= maxStepRotationValue;
            set(hObject,'String',num2str(maxRot));
        end
        
        if(maxRot<0)
            maxRot= 0;
            set(hObject,'String',num2str(maxRot));
        end
    end

    if(minRot>=maxRot)
        set(handles.MinimumValueRot,'String',num2str(maxRot));
        set(handles.TotalStepsValueRot,'String',num2str(0));
        set(handles.StepValueRot,'String',num2str(0));
    else
        set(handles.TotalStepsValueRot,'String',num2str(1));
    end
    TotalStepsValueRot_Callback(handles.TotalStepsValueRot,[],handles);
end


% --- Executes during object creation, after setting all properties.
function MaximumValueRot_CreateFcn(hObject, eventdata, handles)
    global maxDegreeRotationValue
    maxDegreeRotationValue= 360;
    global maxStepRotationValue
    maxStepRotationValue= 8000;
    
    maxDegreeInclinationValue= 45;
    minDegreeInclinationValue= -45;
    % hObject    handle to MaximumValueRot (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    set(hObject,'String',num2str(maxDegreeRotationValue));
end



function StepValueRot_Callback(hObject, eventdata, handles)
% hObject    handle to StepValueRot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StepValueRot as text
%        str2double(get(hObject,'String')) returns contents of StepValueRot as a double

    maxRot= str2double(get(handles.MaximumValueRot,'String'));
    minRot= str2double(get(handles.MinimumValueRot,'String'));
    step= str2double(get(hObject,'String'));
    if(step<0)
        step=maxRot-minRot;
    end
    
    if(step~=0)
        totalSteps= round((maxRot-minRot)/step);
        set(handles.TotalStepsValueRot,'String',num2str(totalSteps));
        set(hObject,'String',num2str((maxRot-minRot)/totalSteps));
    else
        set(handles.TotalStepsValueRot,'String',num2str(0));
    end
    
end

% --- Executes during object creation, after setting all properties.
function StepValueRot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StepValueRot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



end


function TotalStepsValueRot_Callback(hObject, eventdata, handles)
% hObject    handle to TotalStepsValueRot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TotalStepsValueRot as text
%        str2double(get(hObject,'String')) returns contents of TotalStepsValueRot as a double

    maxRot= str2double(get(handles.MaximumValueRot,'String'));
    minRot= str2double(get(handles.MinimumValueRot,'String'));
    totalStepValue= str2double(get(hObject,'String'));
    if(totalStepValue<0)
        totalStepValue=1;
    end
    if(totalStepValue~=0)    
        set(handles.StepValueRot,'String',num2str((maxRot-minRot)/totalStepValue));
    else
        set(handles.StepValueRot,'String',num2str(0));
    end


end

% --- Executes during object creation, after setting all properties.
function TotalStepsValueRot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TotalStepsValueRot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on selection change in ConversionInc.
function ConversionInc_Callback(hObject, eventdata, handles)
% hObject    handle to ConversionInc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ConversionInc contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ConversionInc
    global lastUnitInc
    conversionDegree2Steps= 8000/360;
    conversion= get(hObject,'Value');
    maxInc= handles.MaximumValueInc;
    minInc= handles.MinimumValueInc;
    stepPanel= handles.StepPanelInc;
    stepValue= handles.StepValueInc;
    if(conversion==1)
        conversion= 'Degrees';
    else
        conversion= 'Engine Steps';
    end
    if(~strcmp(conversion,lastUnitInc))
        previousMaxValue= str2double(get(maxInc,'String'));
        previousMinValue= str2double(get(minInc,'String'));
        previousStep=str2double(get(stepValue,'String'));
        if(strcmp(lastUnitInc,'Degrees'))
            %conversionToSteps
            set(maxInc,'String',num2str(previousMaxValue*conversionDegree2Steps));
            set(minInc,'String',num2str(previousMinValue*conversionDegree2Steps));
            set(stepPanel,'Title','Step (Engine Steps)');
            set(stepValue,'String',num2str(previousStep*conversionDegree2Steps));
        else
            %conversionToDeg
            set(maxInc,'String',num2str(previousMaxValue*1/conversionDegree2Steps));
            set(minInc,'String',num2str(previousMinValue*1/conversionDegree2Steps));
            set(stepPanel,'Title','Step (Degrees)');
            set(stepValue,'String',num2str(previousStep*1/conversionDegree2Steps));
        end 
    end
    lastUnitInc= conversion;
end

% --- Executes during object creation, after setting all properties.
function ConversionInc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ConversionInc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    global lastUnitInc
    lastUnitInc='Degrees';
end


function TotalStepsValueInc_Callback(hObject, eventdata, handles)
% hObject    handle to TotalStepsValueInc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TotalStepsValueInc as text
%        str2double(get(hObject,'String')) returns contents of TotalStepsValueInc as a double
    maxInc= str2double(get(handles.MaximumValueInc,'String'));
    minInc= str2double(get(handles.MinimumValueInc,'String'));
    totalStepValue= str2double(get(hObject,'String'));
    if(totalStepValue<0)
        totalStepValue= 1;
    end
    if(totalStepValue~=0)    
        set(handles.StepValueInc,'String',num2str((maxInc-minInc)/totalStepValue));
    else
        set(handles.StepValueInc,'String',num2str(0));
    end

end

% --- Executes during object creation, after setting all properties.
function TotalStepsValueInc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TotalStepsValueInc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


function StepValueInc_Callback(hObject, eventdata, handles)
% hObject    handle to StepValueInc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StepValueInc as text
%        str2double(get(hObject,'String')) returns contents of StepValueInc as a double
    maxInc= str2double(get(handles.MaximumValueInc,'String'));
    minInc= str2double(get(handles.MinimumValueInc,'String'));
    step= str2double(get(hObject,'String'));
    if(step<0)
        step= maxInc-minInc;
    end
    
    if(step~=0)
        totalSteps= round((maxInc-minInc)/step);
        set(handles.TotalStepsValueInc,'String',num2str(totalSteps));
        set(hObject,'String',num2str((maxInc-minInc)/totalSteps));
    else
        set(handles.TotalStepsValueInc,'String',num2str(0));
    end
    

end

% --- Executes during object creation, after setting all properties.
function StepValueInc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StepValueInc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


function MaximumValueInc_Callback(hObject, eventdata, handles)
% hObject    handle to MaximumValueInc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaximumValueInc as text
%        str2double(get(hObject,'String')) returns contents of MaximumValueInc as a double
    global maxDegreeInclinationValue
    global maxStepInclinationValue
    global minDegreeInclinationValue
    global minStepInclinationValue
    global lastUnitInc
    maxInc= str2double(get(hObject,'String'));
    minInc= str2double(get(handles.MinimumValueInc,'String'));
    
    if(strcmp(lastUnitInc,'Degrees'))
        %case of Degrees
        if(maxInc>maxDegreeInclinationValue)
            maxInc= maxDegreeInclinationValue;
            set(hObject,'String',num2str(maxInc));
        end
        
        if(maxInc<minDegreeInclinationValue)
            maxInc= 0;
            set(hObject,'String',num2str(maxInc));
        end
    else
        %case of Steps
        if(maxInc>maxStepInclinationValue)
            maxInc= maxStepInclinationValue;
            set(hObject,'String',num2str(maxInc));
        end
        
        if(maxInc<minStepInclinationValue)
            maxInc= 0;
            set(hObject,'String',num2str(maxInc));
        end
    end

    if(minInc>=maxInc)
        set(handles.MinimumValueInc,'String',num2str(maxInc));
        set(handles.TotalStepsValueInc,'String',num2str(0));
        set(handles.StepValueInc,'String',num2str(0));
    else
        set(handles.TotalStepsValueInc,'String',num2str(1));
    end
    TotalStepsValueInc_Callback(handles.TotalStepsValueInc,[],handles);
end

% --- Executes during object creation, after setting all properties.
function MaximumValueInc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaximumValueInc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    global maxDegreeInclinationValue
    maxDegreeInclinationValue= 45;
    global maxStepInclinationValue
    maxStepInclinationValue= 1000;
   
    % hObject    handle to MaximumValueInc (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    set(hObject,'String',num2str(maxDegreeInclinationValue));
    
end


function MinimumValueInc_Callback(hObject, eventdata, handles)
% hObject    handle to MinimumValueInc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinimumValueInc as text
%        str2double(get(hObject,'String')) returns contents of MinimumValueInc as a double

    global maxDegreeInclinationValue
    global maxStepInclinationValue
    global minDegreeInclinationValue
    global minStepInclinationValue
    global lastUnit
    maxInc= str2double(get(handles.MaximumValueInc,'String'));
    minInc= str2double(get(hObject,'String'));
    
    if(strcmp(lastUnit,'Degrees'))
        %case of Degrees
        if(minInc>maxDegreeInclinationValue)
            minInc= maxDegreeInclinationValue;
            set(hObject,'String',num2str(minInc));
        end
        
        if(minInc<minDegreeInclinationValue)
            minInc= minDegreeInclinationValue;
            set(hObject,'String',num2str(minInc));
        end
    else
        %case of Steps
        if(minInc>maxStepInclinationValue)
            minInc= maxStepInclinationValue;
            set(hObject,'String',num2str(minInc));
        end
        
        if(minInc<minStepInclinationValue)
            minInc= minStepInclinationValue;
            set(hObject,'String',num2str(minInc));
        end
    end
    
    if(minInc>=maxInc)
        set(handles.MaximumValueInc,'String',num2str(minInc));
        set(handles.TotalStepsValueInc,'String',num2str(0));
        set(handles.StepValueInc,'String',num2str(0));
    else
        set(handles.TotalStepsValueInc,'String',num2str(1));        
    end
    
    TotalStepsValueInc_Callback(handles.TotalStepsValueInc,[],handles);
end

% --- Executes during object creation, after setting all properties.
function MinimumValueInc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinimumValueInc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    global minDegreeInclinationValue
    global minStepInclinationValue
    minDegreeInclinationValue= -45;
    minStepInclinationValue= -1000;
    set(hObject,'String',num2str(0));
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
