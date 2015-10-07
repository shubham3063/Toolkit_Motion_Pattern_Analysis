function varargout = Toolkit_MPA(varargin)
% TOOLKIT_MPA code for Toolkit_MPA.fig
%      TOOLKIT_MPA, by itself, creates a new TOOLKIT_MPA or raises the existing
%      singleton*.
%
%      H = TOOLKIT_MPA returns the handle to a new TOOLKIT_MPA or the handle to
%      the existing singleton*.
%
%      TOOLKIT_MPA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TOOLKIT_MPA.M with the given input arguments.
%
%      TOOLKIT_MPA('Property','Value',...) creates a new TOOLKIT_MPA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Toolkit_MPA_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Toolkit_MPA_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Toolkit_MPA

% Last Modified by GUIDE v2.5 01-Sep-2013 17:01:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Toolkit_MPA_OpeningFcn, ...
                   'gui_OutputFcn',  @Toolkit_MPA_OutputFcn, ...
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


% --- Executes just before Toolkit_MPA is made visible.
function Toolkit_MPA_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Toolkit_MPA (see VARARGIN)

% Choose default command line output for Toolkit_MPA
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Toolkit_MPA wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Default Rotation Parameters 
setappdata(0,'h',4);
setappdata(0,'cx',0);
setappdata(0,'cy',0);
setappdata(0,'rounds',1);

% Default Image Parameters
setappdata(0,'resizeValue',512);
setappdata(0,'resizeFlag',0);

% Load the same image if new GMP is opened and an image was present
% in the previous GMP
GMPCount = getappdata(0,'GMPCount');

InputImage = getappdata(0,'InputImage');
if(gt(GMPCount,1))    
    tStep = getappdata(0,'tStep');
    tStep{GMPCount} = 10;
    setappdata(0,'tStep',tStep);
    if(~isempty(InputImage))
        imshow(InputImage);
    end
end

% First Time GUI Parameters, Definitions
% Not to be used in further GMPs

if(isempty(GMPCount))
    % GMP
    GMPCount=1;
    setappdata(0,'GMPCount',GMPCount);
    % Final Output
    FinalImages = {};
    setappdata(0,'FinalImages',FinalImages);
    
    % Translation
    tOrigin = {};
    tDest = {};
    tStep = {};
    tStep{GMPCount} = 10;
    setappdata(0,'tStep',tStep);
    

    tTranslatedImages = {};
    tNImages = {};    
    
    setappdata(0,'tOrigin',tOrigin);
    setappdata(0,'tDest',tDest);
    setappdata(0,'tStep',tStep);
    setappdata(0,'tTranslatedImages',tTranslatedImages);
    setappdata(0,'tNImages',tNImages);
end

% set(handles.saveCoalesceResults,'String',pwd);



% --- Outputs from this function are returned to the command line.
function varargout = Toolkit_MPA_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in browse.
function browse_Callback(hObject, eventdata, handles)
% hObject    handle to browse (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    structure with handles and user data (see GUIDATA)

[fileName,pathName,filterIndex] = uigetfile({'*.*'},'File Selector');
set(handles.pathName,'String',pathName);
Input = imread(strcat(pathName,fileName));

resizeFlag = getappdata(0,'resizeFlag');
resizeValue = getappdata(0,'resizeValue');
[nrowsOriginal ncolsOriginal nPlanesOriginal] = size(Input);
if(resizeFlag==1)
    if(nrowsOriginal <= ncolsOriginal)
        Input = imresize(Input,'OutputSize',[resizeValue NaN]);
    else
        Input = imresize(Input,'OutputSize',[NaN resizeValue]);
    end
end


imshow(Input)
set(handles.dim,'String',strcat(int2str(size(Input,1)),'x',int2str(size(Input,2))));
setappdata(0,'fileName',fileName);
setappdata(0,'pathName',fileName);
setappdata(0,'InputImage',Input);





% --- Executes on button press in rotate.
function rotate_Callback(hObject, eventdata, handles)
% hObject    handle to rotate (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    structure with handles and user data (see GUIDATA)
I = getappdata(0,'InputImage');

nrowsOriginal = size(I,1);
ncolsOriginal = size(I,2);
nplanesOriginal = size(I,3);
if(nplanesOriginal>1)
    I = rgb2gray(I);
end
resizeFlag = getappdata(0,'resizeFlag');
resizeValue = getappdata(0,'resizeValue');
if(resizeFlag==1)
    if(nrowsOriginal <= ncolsOriginal)
        I = imresize(I,'OutputSize',[resizeValue NaN]);
    else
        I = imresize(I,'OutputSize',[NaN resizeValue]);
    end
end

[nrows ncols] = size(I);

ox = floor(ncols/2);
oy = floor(nrows/2);

cx = getappdata(0,'cx');
cy = getappdata(0,'cy');

tx = cx-ox;
ty = cy-oy;

atx = abs(tx);
aty = abs(ty);

J = zeros(nrows+2*aty,ncols+2*atx);

if tx>=0 && ty>=0
    J(1:nrows,1:ncols) = im2double(I);
elseif tx>0 && ty<0
    J(2*aty+1:end,1:ncols) = im2double(I);
elseif tx<0 && ty>0
    J(1:nrows,2*atx+1:end) = im2double(I);
elseif tx<0 && ty<0
    J(2*aty+1:end,2*atx+1:end) = im2double(I);
end


RotatedImages={};
h = getappdata(0,'h');
step = floor(360/h);
rounds = getappdata(0,'rounds');
th = step;
i=1;
wait = waitbar(0, 'Generating Rotated Images...');
while th<=360*rounds
    thRad = deg2rad(th);
    rot = [cos(thRad) -sin(thRad) 0; sin(thRad) cos(thRad) 0; 0 0 1];
    T = maketform('affine',rot);
    rotatedImage = imtransform(J,T);
    RotatedImages{i} = rotatedImage;
    i=i+1;
    th = th + step;    
    waitbar(th/(360*rounds));
end

% set(wait, 'WindowStyle','modal', 'CloseRequestFcn','');
close(wait);

maxRow=0;
maxCol=0;
n = size(RotatedImages,2);
FinalImages = cell(1,n);
for i=1:n
    if maxRow<size(RotatedImages{i},1)
        maxRow = size(RotatedImages{i},1);
    end
    if maxCol<size(RotatedImages{i},2)
        maxCol = size(RotatedImages{i},2);
    end
     
end
originY = floor(maxRow/2);
originX = floor(maxCol/2);

rotatedImages = zeros(maxRow,maxCol,n);

for i=1:n
    rotatedImage = RotatedImages{i};
    sizeImage = size(rotatedImage);
    center = floor(size(rotatedImage)/2);
    rescaledImage = (zeros(maxRow,maxCol));
    rescaledImage(originY - center(1) + 1: originY - center(1) + sizeImage(1) ...
    , originX - center(2) + 1: originX - center(2) + sizeImage(2))= rotatedImage;
    rescaledImage(originY,originX) = 255;
    rotatedImages(:,:,i) = rescaledImage;
end

GMPCount    = getappdata(0,'GMPCount');
FinalImages = getappdata(0,'FinalImages');
FinalImages{GMPCount} = rotatedImages;
% setappdata(0,'RotatedImages',RotatedImages);
setappdata(0,'FinalImages',FinalImages);
% setappdata(0,'n',n);
% setappdata(0,'FinalSize',[maxRow maxCol]);




function Step_Callback(hObject, eventdata, handles)
% hObject    handle to Step (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Step as text
%        str2double(get(hObject,'String')) returns contents of Step as a double
h = str2double(get(hObject,'String'));
setappdata(0,'h',h);

% --- Executes during object creation, after setting all properties.
function Step_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Step (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in saveRotation.
function saveRotation_Callback(hObject, eventdata, handles)
% hObject    handle to saveRotation (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    structure with handles and user data (see GUIDATA)
% Save
% Create a directory
RotatedImages = getappdata(0,'RotatedImages');
FinalImages = getappdata(0,'FinalImages');

saveCoalesceFlag = getappdata(0,'saveCoalesceFlag');
Name = strtok(getappdata(0,'fileName'),'.');
x = getappdata(0,'cx');
y = getappdata(0,'cy');
step = getappdata(0,'h');
rounds = getappdata(0,'rounds');
dirName = strcat(Name,'_',...
    '_x=',int2str(x),'_y=',int2str(y),...
    '_Step=',int2str(step),'_rounds=',int2str(rounds));
if saveCoalesceFlag==1
    saveDirectory = getappdata(0,'saveDirectory');
    dirName = strcat(saveDirectory,'/',dirName);
end
    
if ~ exist(dirName,'dir')
    mkdir(dirName);
end
th = step;
wait = waitbar(0, 'Saving Rotated Images...', 'windowstyle','modal');
for i=1:size(RotatedImages,2)
    imwrite(FinalImages{i},strcat(dirName,'/',int2str(th),'.jpg'),'jpg');
    th = th + step;
    waitbar(i/size(RotatedImages,2));
end
close(wait);

% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in chooseFunction.
function chooseFunction_Callback(hObject, eventdata, handles)
% hObject    handle to chooseFunction (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns chooseFunction contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chooseFunction
% func = get(hObject,'String');
% setappdata(0,'func',func);

% --- Executes during object creation, after setting all properties.
function chooseFunction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chooseFunction (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
func = get(hObject,'String');
setappdata(0,'func',func);

% --- Executes on button press in coalease.
function coalease_Callback(hObject, eventdata, handles)
% hObject    handle to coalease (see GCBO)
% eventdata  reserved - to be defined in a future version.
% handles    structure with handles and user data (see GUIDATA)
S = ['Average';'Min-Max';'Maximum';'Minimum'];
setappdata(0,'FunctionList',S);
[Selection,ok] = listdlg('ListString',S,'SelectionMode','Single');
if ok==1
    GMPCount = getappdata(0,'GMPCount');
    FinalImages = getappdata(0,'FinalImages');    
%     Size = getappdata(0,'FinalSize');
    sizeAllImages = zeros(size(FinalImages,2),3);
    for i=1:GMPCount
        if(~isempty(FinalImages{i}))
            sizeAllImages(i,:) = size(FinalImages{i});
        end
    end
    maxRowSize = max(sizeAllImages(:,1));
    maxColSize = max(sizeAllImages(:,2));
    totalNumImages = sum(sizeAllImages(:,3));
    Images = zeros(maxRowSize,maxColSize,totalNumImages);
    k=1;
    for i=1:GMPCount
        if(~isempty(FinalImages{i}))
            images = FinalImages{i};
            dimensions = size(images);
            rowDiff = maxRowSize - dimensions(1);
            colDiff = maxColSize - dimensions(2);
            rowDiffPart1 = floor(rowDiff/2);
            rowDiffPart2 = rowDiff - floor(rowDiff/2);
            colDiffPart1 = floor(colDiff/2);
            colDiffPart2 = colDiff - floor(colDiff/2);
            j=1;
            while j<=dimensions(3)
                tempImage = padarray(images(:,:,j),[rowDiffPart1 colDiffPart1],0,'pre');
                Images(:,:,k) = padarray(tempImage,[rowDiffPart2 colDiffPart2],0,'post');
                j=j+1;
                k=k+1;
            end
        end
    end
        
      
    setappdata(0,'Selection',Selection);
    if Selection == 1 % Average
        CoaleaseResult = mean(Images,3);
        
    elseif Selection == 2 % Min-Max
        tempMin = min(Images,[],3);
        tempMax = max(Images,[],3);
        CoaleaseResult = (tempMax+tempMin)/2;        
    
    elseif Selection == 3 % Max
        CoaleaseResult = max(Images,[],3);
        
    elseif Selection == 4 % Min
        CoaleaseResult = min(Images,[],3);
    
    end 
        
    
    % Save file if the save Coalesce flag is set
    saveCoalesceFlag = getappdata(0,'saveCoalesceFlag');
    Name = strtok(getappdata(0,'fileName'),'.');
    x = getappdata(0,'cx');
    y = getappdata(0,'cy');
    step = getappdata(0,'h');
    rounds = getappdata(0,'rounds');
    parameters = strcat(Name,'_',S(Selection,:),...
        '_x=',int2str(x),'_y=',int2str(y),...
        '_Step=',int2str(step),'_rounds=',int2str(rounds));
    setappdata(0,'Parameters',parameters);
    if(saveCoalesceFlag==1)
        saveDirectory = getappdata(0,'saveDirectory');       
        imwrite(CoaleaseResult,strcat(saveDirectory,'/',parameters,'.jpg'),'jpg');
    end 
    
    setappdata(0,'CoaleaseResult',CoaleaseResult);
    Coalease
end



function pathName_Callback(hObject, eventdata, handles)
% hObject    handle to pathName (see GCBO)
% eventdata  reserved - to be defined in a future version.
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pathName as text
%        str2double(get(hObject,'String')) returns contents of pathName as a double



% --- Executes during object creation, after setting all properties.
function pathName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pathName (see GCBO)
% eventdata  reserved - to be defined in a future version.
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in closeGUI.
function closeGUI_Callback(hObject, eventdata, handles)
% hObject    handle to closeGUI (see GCBO)
% eventdata  reserved - to be defined in a future version.
% handles    structure with handles and user data (see GUIDATA)
app=getappdata(0); %get all the appdata of 0
%and then
appdatas = fieldnames(app);
for kA = 1:length(appdatas)
  rmappdata(0,char(appdatas(kA)));
end
close(gcbf)




% --- Executes on button press in SelectCenter.
function SelectCenter_Callback(hObject, eventdata, handles)
% hObject    handle to SelectCenter (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    structure with handles and user data (see GUIDATA)
[x,y] = ginput(1);
setappdata(0,'cx',floor(x));
setappdata(0,'cy',floor(y));
set(handles.center,'String',strcat('(x=',int2str(x),', y=',int2str(y),')'));




% --- Executes on button press in restartToolkit.
function restartToolkit_Callback(hObject, eventdata, handles)
% hObject    handle to restartToolkit (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    structure with handles and user data (see GUIDATA)
app=getappdata(0); %get all the appdata of 0
%and then
appdatas = fieldnames(app);
for kA = 1:length(appdatas)
  rmappdata(0,char(appdatas(kA)));
end
close(gcbf)
Toolkit_MPA


% --- Executes on button press in resetParameters.
function resetParameters_Callback(hObject, eventdata, handles)
% hObject    handle to resetParameters (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    structure with handles and user data (see GUIDATA)
setappdata(0,'h',4);
setappdata(0,'cx',0);
setappdata(0,'cy',0);
set(handles.Step,'String',4);
set(handles.resizeValue,'String',512);
set(handles.rounds,'String',1);
set(handles.center,'String','(x=0, y=0)');


% --- Executes on button press in resizeFlag.
function resizeFlag_Callback(hObject, eventdata, handles)
% hObject    handle to resizeFlag (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of resizeFlag
check = get(hObject,'Value');
setappdata(0,'resizeFlag',check);
Input = getappdata(0,'InputImage');
if(check==1 && ~isempty(Input))    
    [nrowsOriginal ncolsOriginal nPlanesOriginal] = size(Input);
    resizeValue = getappdata(0,'resizeValue');
    if(nrowsOriginal <= ncolsOriginal)
        Input = imresize(Input,'OutputSize',[resizeValue NaN]);
    else
        Input = imresize(Input,'OutputSize',[NaN resizeValue]);
    end
    setappdata(0,'InputImage',Input);
    imshow(Input);
    set(handles.dim,'String',strcat(int2str(size(Input,1)),'x',int2str(size(Input,2))));
end



function resizeValue_Callback(hObject, eventdata, handles)
% hObject    handle to resizeValue (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of resizeValue as text
%        str2double(get(hObject,'String')) returns contents of resizeValue as a double
resizeVal = str2double(get(hObject,'String'));
setappdata(0,'resizeValue',resizeVal);

% --- Executes during object creation, after setting all properties.
function resizeValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resizeValue (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SaveDirectory.
function SaveDirectory_Callback(hObject, eventdata, handles)
% hObject    handle to SaveDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    structure with handles and user data (see GUIDATA)
folderName = uigetdir;
set(handles.saveCoalesceResults,'String',folderName);
setappdata(0,'saveDirectory',folderName);



% --- Executes on button press in saveCoalesceFlag.
function saveCoalesceFlag_Callback(hObject, eventdata, handles)
% hObject    handle to saveCoalesceFlag (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of saveCoalesceFlag
saveCoalesceFlag = get(hObject,'Value');
setappdata(0,'saveCoalesceFlag',saveCoalesceFlag);



function saveCoalesceResults_Callback(hObject, eventdata, handles)
% hObject    handle to saveCoalesceResults (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of saveCoalesceResults as text
%        str2double(get(hObject,'String')) returns contents of saveCoalesceResults as a double


% --- Executes during object creation, after setting all properties.
function saveCoalesceResults_CreateFcn(hObject, eventdata, handles)
% hObject    handle to saveCoalesceResults (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function transformationMatrix_Callback(hObject, eventdata, handles)
% hObject    handle to transformationMatrix (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of transformationMatrix as text
%        str2double(get(hObject,'String')) returns contents of transformationMatrix as a double
M = get(hObject,'String');


% --- Executes during object creation, after setting all properties.
function transformationMatrix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to transformationMatrix (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rounds_Callback(hObject, eventdata, handles)
% hObject    handle to rounds (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rounds as text
%        str2double(get(hObject,'String')) returns contents of rounds as a double
rounds = str2double(get(hObject,'String'));
setappdata(0,'rounds',rounds);

% --- Executes during object creation, after setting all properties.
function rounds_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rounds (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dim_Callback(hObject, eventdata, handles)
% hObject    handle to dim (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dim as text
%        str2double(get(hObject,'String')) returns contents of dim as a double


% --- Executes during object creation, after setting all properties.
function dim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dim (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in translate_origin.
function translate_origin_Callback(hObject, eventdata, handles)
% hObject    handle to translate_origin (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    structure with handles and user data (see GUIDATA)
[x,y] = ginput(1);
GMPCount = getappdata(0,'GMPCount');
tOrigin = getappdata(0,'tOrigin');
tOrigin{GMPCount} = [floor(x),floor(y)];
setappdata(0,'tOrigin',tOrigin);
set(handles.translate_origin_coord,'String',strcat('(x=',int2str(x),', y=',int2str(y),')'));


% --- Executes on button press in translate_save_results.
function translate_save_results_Callback(hObject, eventdata, handles)
% hObject    handle to translate_save_results (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in translate_translate.
function translate_translate_Callback(hObject, eventdata, handles)
% hObject    handle to translate_translate (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    structure with handles and user data (see GUIDATA)
I = getappdata(0,'InputImage');

nrowsOriginal = size(I,1);
ncolsOriginal = size(I,2);
nplanesOriginal = size(I,3);
if(nplanesOriginal>1)
    I = rgb2gray(I);
end
% resizeFlag = getappdata(0,'resizeFlag');
% resizeValue = getappdata(0,'resizeValue');
% if(resizeFlag==1)
%     if(nrowsOriginal <= ncolsOriginal)
%         I = imresize(I,'OutputSize',[resizeValue NaN]);
%     else
%         I = imresize(I,'OutputSize',[NaN resizeValue]);
%     end
% end

[nrows ncols] = size(I);
GMPCount = getappdata(0,'GMPCount');
tOrigin = getappdata(0,'tOrigin');

ox = tOrigin{GMPCount}(1);
oy = tOrigin{GMPCount}(2);

tDest = getappdata(0,'tDest');
dx = tDest{GMPCount}(1);
dy = tDest{GMPCount}(2);


tx = dx-ox;
ty = dy-oy;

atx = abs(tx);
aty = abs(ty);

J = zeros(nrows+aty,ncols+atx);


if tx>=0 && ty>=0
    J(1:nrows,1:ncols) = im2double(I);
elseif tx>0 && ty<0
    J(aty+1:end,1:ncols) = im2double(I);
elseif tx<0 && ty>0
    J(1:nrows,atx+1:end) = im2double(I);
elseif tx<0 && ty<0
    J(aty+1:end,atx+1:end) = im2double(I);
end
% figure,imshow(J);


tTranslatedImages = getappdata(0,'tTranslatedImages');
tNImages = getappdata(0,'tNImages');
tStep = getappdata(0,'tStep');
step = tStep{GMPCount};


iter = 1;
translatedImages = {};
row_shift = floor(aty/step)*(ty/aty);
col_shift = floor(atx/step)*(tx/atx);
translatedImages = zeros(size(J,1),size(J,2),step);
wait = waitbar(0, 'Generating Translated Images...');
while iter<=step    
    %trans = [0 0 0; 0 0 0; floor(atx/step)*(tx/atx) floor(aty/step)*(ty/aty) 1];
%     translatedImage = imtranslate(J,[row_shift col_shift]);
%     T = maketform('affine',trans);
%     translatedImage = imtransform(double(J),T,'XData',[1 size(J,2)],...
%         'YData',[1 size(J,1)]);    
    translatedImages(:,:,iter) = imtranslate(J,[row_shift col_shift]);
    iter = iter + 1;    
    row_shift = row_shift + floor(aty/step)*(ty/aty);
    col_shift = col_shift + floor(atx/step)*(tx/atx);
    waitbar(iter/step);
end

tTranslatedImages{GMPCount} = translatedImages;
setappdata(0,'tTranslatedImages',tTranslatedImages);
FinalImages = getappdata(0,'FinalImages');
FinalImages{GMPCount} = translatedImages;
setappdata(0,'FinalImages',FinalImages);
% set(wait, 'WindowStyle','modal', 'CloseRequestFcn','');
close(wait);
% 
% maxRow=0;
% maxCol=0;
% n = size(RotatedImages,2);
% FinalImages = cell(1,n);
% for i=1:n
%     if maxRow<size(RotatedImages{i},1)
%         maxRow = size(RotatedImages{i},1);
%     end
%     if maxCol<size(RotatedImages{i},2)
%         maxCol = size(RotatedImages{i},2);
%     end
%      
% end
% originY = floor(maxRow/2);
% originX = floor(maxCol/2);
% for i=1:n
%     rotatedImage = RotatedImages{i};
%     sizeImage = size(rotatedImage);
%     center = floor(size(rotatedImage)/2);
%     rescaledImage = (zeros(maxRow,maxCol));
%     rescaledImage(originY - center(1) + 1: originY - center(1) + sizeImage(1) ...
%     , originX - center(2) + 1: originX - center(2) + sizeImage(2))= rotatedImage;
%     rescaledImage(originY,originX) = 255;
%     FinalImages{i} = rescaledImage;
% end
% 
% 
% setappdata(0,'RotatedImages',RotatedImages);
% setappdata(0,'FinalImages',FinalImages);
% setappdata(0,'n',n);
% setappdata(0,'FinalSize',[maxRow maxCol]);



function translate_step_size_Callback(hObject, eventdata, handles)
% hObject    handle to translate_step_size (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of translate_step_size as text
%        str2double(get(hObject,'String')) returns contents of translate_step_size as a double

GMPCount = getappdata(0,'GMPCount');
tStep{GMPCount} = str2double(get(hObject,'String'));
setappdata(0,'tStep',tStep);



% --- Executes during object creation, after setting all properties.
function translate_step_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to translate_step_size (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in translate_destination.
function translate_destination_Callback(hObject, eventdata, handles)
% hObject    handle to translate_destination (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    structure with handles and user data (see GUIDATA)
[x,y] = ginput(1);
GMPCount = getappdata(0,'GMPCount');
tDest = getappdata(0,'tDest');
tDest{GMPCount} = [floor(x),floor(y)];
setappdata(0,'tDest',tDest);
set(handles.translate_dest_coord,'String',strcat('(x=',int2str(x),', y=',int2str(y),')'));


% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton19.
function pushbutton19_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    structure with handles and user data (see GUIDATA)



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in New_GMP.
function New_GMP_Callback(hObject, eventdata, handles)
% hObject    handle to New_GMP (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    structure with handles and user data (see GUIDATA)
GMPCount = getappdata(0,'GMPCount');
GMPCount = GMPCount+1;
setappdata(0,'GMPCount',GMPCount);
Toolkit_MPA;


% --- Executes on button press in remove_from_finalImages.
function remove_from_finalImages_Callback(hObject, eventdata, handles)
% hObject    handle to remove_from_finalImages (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    structure with handles and user data (see GUIDATA)
GMPCount = getappdata(0,'GMPCount');
FinalImages = getappdata(0,'FinalImages');
FinalImages{GMPCount} = {};
setappdata(0,'FinalImages',FinalImages);


% --- Executes on button press in crop_image.
function crop_image_Callback(hObject, eventdata, handles)
% hObject    handle to crop_image (see GCBO)
% eventdata  reserved - to be defined in a future version
% handles    structure with handles and user data (see GUIDATA)
Input = getappdata(0,'InputImage');
Input = imcrop(Input);
imshow(Input);
setappdata(0,'InputImage',Input);
