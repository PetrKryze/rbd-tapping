function varargout = DataEditor(varargin)
% DATAEDITOR M-file for DataEditor.fig
%      DATAEDITOR, by itself, creates a new DATAEDITOR or raises the existing
%      singleton*.
%
%      H = DATAEDITOR returns the handle to a new DATAEDITOR or the handle to
%      the existing singleton*.
%
%      DATAEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATAEDITOR.M with the given input arguments.
%
%      DATAEDITOR('Property','Value',...) creates a new DATAEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DataEditor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DataEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DataEditor

% Last Modified by GUIDE v2.5 13-Sep-2016 14:17:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DataEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @DataEditor_OutputFcn, ...
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


% --- Executes just before DataEditor is made visible.
function DataEditor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DataEditor (see VARARGIN)

% Choose default command line output for DataEditor
handles.output = hObject;
handles.ActualPath = '.';
handles.ActualPath = 'C:\Users\Petr\Desktop\Diplomka\RBDTapping';
%handles.ActualData.Grafstart = 0;
%handles.ActualData.Grafstop = 0;
handles.DataSet = [];
handles.ActualData = [];
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DataEditor wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DataEditor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function editFrom_Callback(hObject, eventdata, handles)
% hObject    handle to editFrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFrom as text
%        str2double(get(hObject,'String')) returns contents of editFrom as a double
datastart = str2double(get(handles.editFrom,'String'));
handles.ActualData.Data.SetFromTime(datastart);
handles.ActualData.Data.ComputeAll();

guidata(hObject, handles);
prekresli(hObject,handles);


% --- Executes during object creation, after setting all properties.
function editFrom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editTo_Callback(hObject, eventdata, handles)
% hObject    handle to editTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTo as text
%        str2double(get(hObject,'String')) returns contents of editTo as a double
dataend = str2double(get(handles.editTo,'String'));
handles.ActualData.Data.SetToTime(dataend);
handles.ActualData.Data.ComputeAll();
guidata(hObject, handles);
prekresli(hObject,handles);

% --- Executes during object creation, after setting all properties.
function editTo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnSaveAs.
function btnSaveAs_Callback(hObject, eventdata, handles)
% hObject    handle to btnSaveAs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 [file path] = uiputfile('*.dat','Save Image As',cat(2,handles.ActualData.FileName,'.dat'));
 
 if ~isequal(file,0) && ~isequal(path,0)
     handles.ActualData.Data.Save(fullfile(path,file));
 end
 
 % --- Executes on button press in saveAll.
function saveAll_Callback(hObject, eventdata, handles)
% hObject    handle to saveAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
path = uigetdir();
for k = 1:length(handles.DataSet)
 if ~isequal(path,0)
     handles.DataSet(k).Data.SaveToPath(path);
 end
end


% --- Executes on button press in btnLoad.
function btnLoad_Callback(hObject, eventdata, handles)
% hObject    handle to btnLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[files, pathname] = uigetfile({'*.txt;*.dat;*.csv','Data Files (*.txt,*.dat,*.csv)'},'Select Files','MultiSelect','On',handles.ActualPath);

if( ~isequal(files,0))
    handles.ActualPath = pathname;
    if(~iscell(files))
       files = {files};    
    end
    
    for filename = files
        filename = filename{1};

        ld = PDData();
        ld = ld.Load(fullfile(pathname,filename));            
        dv = PDDataView(ld);
        handles.DataSet = [handles.DataSet;dv];
        handles.ActualData = dv;


    end
    
    guidata(hObject, handles);
    prekresli(hObject,handles);
    listbox1_Update(hObject,handles);
end


function btnSaveToImage_Callback(hObject, eventdata, handles)
% hObject    handle to btnSaveToImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rect_pos = get(handles.axes1,'position');
rect_pos = rect_pos + [ -45 -45 +50 +50];
f = getframe(handles.figure1, rect_pos); %Capture screen shot area defined by rect_pos

[im,map] = frame2im(f);
[file path] = uiputfile('*.png','Save Image As',cat(2,handles.actualData.filename,'.png'));
imwrite(im,[path,file]);

function prekresli(hObject,handles)
    
    cla(handles.axes1);    
    axes(handles.axes1);
    if(isobject(handles.ActualData) && ~isempty(handles.ActualData))
        
        ad = handles.ActualData(1,1);
        
        if(get(handles.chbSpeed,'Value') ~= 0)
            ad.PlotDeriv();
            grid on
             set(handles.editFrom,'String',num2str(ad.Data.FromTime));
        set(handles.editTo,'String',num2str(ad.Data.ToTime))
            return;
        end
        h = ad.PlotData('b');
        set(h, 'ButtonDownFcn',@(hObject,eventdata)DataEditor('axes1_ButtonDownFcn',hObject,eventdata,guidata(hObject)))
        hold on
        h = ad.PlotMax();
        set(h, 'ButtonDownFcn',@(hObject,eventdata)DataEditor('axes1_ButtonDownFcn',hObject,eventdata,guidata(hObject)))
        h = ad.PlotMin();       
        set(h, 'ButtonDownFcn',@(hObject,eventdata)DataEditor('axes1_ButtonDownFcn',hObject,eventdata,guidata(hObject)))
        
        set(handles.editFrom,'String',num2str(ad.Data.FromTime));
        set(handles.editTo,'String',num2str(ad.Data.ToTime))
        hold off      
        grid on
        set(handles.axes1, 'ButtonDownFcn',@(hObject,eventdata)DataEditor('axes1_ButtonDownFcn',hObject,eventdata,guidata(hObject)))
        
    end

% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
val = get(hObject,'Value') ;
handles.ActualData = handles.DataSet(val);
guidata(hObject, handles);
prekresli(hObject,handles);


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function listbox1_Update(hObject,handles)
c ={};
if(~isempty(handles.DataSet))
    files = {handles.DataSet.ListName};
    val = get(handles.listbox1,'Value');
    if(~isempty(files))
        if(val > length(files))
            val = length(files);
        end
        if(length(files) == 1)
           c = files{1}; 
        else
            c = files;  
        end
    else
       val = 1; 
    end

    set(handles.listbox1,'Value',val);
    set(handles.listbox1,'String',c); 

else
    set(handles.listbox1,'Value',[]);
    set(handles.listbox1,'String',''); 
end
% --- Executes on key press with focus on listbox1 and none of its controls.
function listbox1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
if(strcmp(eventdata.Key,'delete'))
    
              
    if(~isempty (handles.DataSet))
        val = get(hObject,'Value') ;
        if(val <= length(handles.DataSet))
            if (isequal(handles.DataSet(val), handles.ActualData))
                handles.ActualData =[];
            end
            handles.DataSet(val) = [];
        end
       
        guidata(hObject, handles);
        listbox1_Update(hObject,handles);
        prekresli(hObject,handles);
    end
end


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in btnDataClear.
function btnDataClear_Callback(hObject, eventdata, handles)
% hObject    handle to btnDataClear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(isobject(handles.ActualData))
        n = str2num(get(handles.etidClear,'String'));
        if ~isnumeric(n)
            n = 5;
        end
        handles.ActualData.ClearBadValues(n);
        
        prekresli(hObject,handles);
 end


% --- Executes on button press in btnDataRepair.
function btnDataRepair_Callback(hObject, eventdata, handles)
% hObject    handle to btnDataRepair (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(isobject(handles.ActualData))
        if(length(handles.ActualData) == 2)
            if(get(handles.chbReverse,'Value') == 0)
                handles.ActualData(1,1).RepairBadValues(handles.ActualData(2,1));
                handles.ActualData(2,1).RepairBadValues(handles.ActualData(1,1));
            else                
                handles.ActualData(2,1).RepairBadValues(handles.ActualData(1,1));
                handles.ActualData(1,1).RepairBadValues(handles.ActualData(2,1));
            end
        end
        prekresli(hObject,handles);
 end
  

% --- Executes on button press in pbSaveData.
function pbSaveData_Callback(hObject, eventdata, handles)
% hObject    handle to pbSaveData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dataSet = {};

for k = 1:length(handles.DataSet)
    dataSet{k} = handles.DataSet(k).Data;
   
end

save('data.mat','dataSet')


% --- Executes on button press in btnMedian.
function btnMedian_Callback(hObject, eventdata, handles)
% hObject    handle to btnMedian (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(isobject(handles.ActualData) && ~isempty(handles.ActualData))
    n = str2num(get(handles.editProp,'String'));
    if ~isnumeric(n)
        n = 4;
    end
    handles.ActualData.MedianFilter(n);   
end
prekresli(hObject,handles);


% --- Executes on button press in btnBack.
function btnBack_Callback(hObject, eventdata, handles)
% hObject    handle to btnBack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(isobject(handles.ActualData) && ~isempty(handles.ActualData))
   handles.ActualData.MemBack();   
end
prekresli(hObject,handles);

% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   if(isempty(eventdata))
    coordinates = get(gca,'CurrentPoint'); 
    coordinates = coordinates(1,1:2);
    hf = get(hObject,'parent');
    b = get(handles.figure1,'selectiontype')
    x = coordinates(1,1);
    y = coordinates(1,2);    
    bt = 0;
    if strcmpi(b,'normal')
      bt = 1;
    elseif strcmpi(b,'alt')
        bt = 3;
      end
   else
      x= eventdata.IntersectionPoint(1);
      y= eventdata.IntersectionPoint(2);
      bt = eventdata.Button;
   end
   

if(bt==1)
    if(isobject(handles.ActualData) && ~isempty(handles.ActualData))
        if(get(handles.chbRepair,'Value') == 1)
            handles.ActualData.AddPoint([x y]);   
        elseif(get(handles.chbMinMax,'Value') == 1)
            handles.ActualData.AddMinMax([x y]); 
        else
             handles.ActualData.Data.SetFromTime(x);
             handles.ActualData.Data.ComputeAll();
        end
    end
end
if(bt==3)
    if(isobject(handles.ActualData) && ~isempty(handles.ActualData))
        if(get(handles.chbRepair,'Value') == 1)
            handles.ActualData.RemovePoint([x y]);   
        elseif(get(handles.chbMinMax,'Value') == 1)
            handles.ActualData.RemoveMinMax([x y]); 
        else
             handles.ActualData.Data.SetToTime(x);
             handles.ActualData.Data.ComputeAll();
        end
    end
end
prekresli(hObject,handles);
       


% --- Executes during object creation, after setting all properties.
function editProp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editProp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnFrw.
function btnFrw_Callback(hObject, eventdata, handles)
% hObject    handle to btnFrw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(isobject(handles.ActualData) && ~isempty(handles.ActualData))
   handles.ActualData.MemFw();   
end
prekresli(hObject,handles);


function editProp_Callback(hObject, eventdata, handles)
% hObject    handle to etidClear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etidClear as text
%        str2double(get(hObject,'String')) returns contents of etidClear as a double

function etidClear_Callback(hObject, eventdata, handles)
% hObject    handle to etidClear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etidClear as text
%        str2double(get(hObject,'String')) returns contents of etidClear as a double


% --- Executes during object creation, after setting all properties.
function etidClear_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etidClear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnSave.
function btnSave_Callback(hObject, eventdata, handles)
% hObject    handle to btnSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.ActualData.Data.Save();
handles.ActualData.Data.ReLoad();
prekresli(hObject,handles);

% --- Executes on button press in btnReload.
function btnReload_Callback(hObject, eventdata, handles)
% hObject    handle to btnReload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.ActualData.Data.ReLoad();
prekresli(hObject,handles);



% --- Executes on button press in pbSaveMinMax.
function pbSaveMinMax_Callback(hObject, eventdata, handles)
% hObject    handle to pbSaveMinMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.ActualData.Data.SaveMinMax();
prekresli(hObject,handles);


% --- Executes on button press in chbMinMax.
function chbMinMax_Callback(hObject, eventdata, handles)
% hObject    handle to chbMinMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chbMinMax


% --- Executes on button press in btnRprSpeed.
function btnRprSpeed_Callback(hObject, eventdata, handles)
% hObject    handle to btnRprSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in chbSpeed.
function chbSpeed_Callback(hObject, eventdata, handles)
% hObject    handle to chbSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chbSpeed
prekresli(hObject,handles);