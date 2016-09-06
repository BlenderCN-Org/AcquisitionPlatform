function varargout = rotatoryTableSetup(varargin)
% ROTATORYTABLESETUP MATLAB code for rotatoryTableSetup.fig
%      ROTATORYTABLESETUP, by itself, creates a new ROTATORYTABLESETUP or raises the existing
%      singleton*.
%
%      H = ROTATORYTABLESETUP returns the handle to a new ROTATORYTABLESETUP or the handle to
%      the existing singleton*.
%
%      ROTATORYTABLESETUP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROTATORYTABLESETUP.M with the given input arguments.
%
%      ROTATORYTABLESETUP('Property','Value',...) creates a new ROTATORYTABLESETUP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before rotatoryTableSetup_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to rotatoryTableSetup_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help rotatoryTableSetup

% Last Modified by GUIDE v2.5 05-Sep-2016 18:14:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rotatoryTableSetup_OpeningFcn, ...
                   'gui_OutputFcn',  @rotatoryTableSetup_OutputFcn, ...
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


% --- Executes just before rotatoryTableSetup is made visible.
function rotatoryTableSetup_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to rotatoryTableSetup (see VARARGIN)

% Choose default command line output for rotatoryTableSetup
addpath('Lighting');
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes rotatoryTableSetup wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = rotatoryTableSetup_OutputFcn(hObject, eventdata, handles) 
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
