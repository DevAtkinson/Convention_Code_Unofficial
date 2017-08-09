function [vargout] = Convetion_Code(varargin)
handles.fig = figure(...
    'MenuBar','None');
handles.axes = axes('Parent',handles.fig ,...
    'Layer' ,'Top');
box(handles.axes,'on');
axis(handles.axes,'tight');
axis(handles.axes,'equal');
set(handles.axes,'DataAspectRatio',[1 1 1],'Layer','top');
% declare variables for storing processing information
mask_visible=0;
roicount = 0;
isDVC=0;
xmax=[];
ymax=[];
zmax=[];
roi(1).handle = [];
roi(1).act = [];
roi(1).coord = [];
roi(1).shape = [];
roi(1).clude = 'include';
%create initial plot on figure - will be replaced by actual data
if nargin==0
	Z = peaks(51);
	imghandle = imagesc(Z,...
	                    'Parent',handles.axes);
else 
	X=varargin{1};
	Y=varargin{2};
	Z=varargin{3};
	imghandle = imagesc(X,Y,Z,...
	                    'Parent',handles.axes);
end
%set the toolbar to show so that zoom and pan options become available
set(handles.fig,'toolbar','figure');
% set(h,'menubar','figure');

%% Set new menu for figure.
% Data menu
MHData      = uimenu(handles.fig ,'Label','Data');
uimenu_data_type=uimenu(MHData,'Label','Select data');
uimenu_data_type_DIC=uimenu(uimenu_data_type,'Label','2D DIC','Callback',@MHData_type_2DIC);
uimenu_data_type_DIC=uimenu(uimenu_data_type,'Label','3D DIC','Callback',@MHData_type_3DIC);
uimenu_data_type_DVC=uimenu(uimenu_data_type,'Label','DVC','Callback',@MHData_type_DVC);
uimenu_data_type_FEM=uimenu(uimenu_data_type,'Label','FEM','Callback',@MHData_type_FEM);
uimenu(MHData,'Label','Load output file','Separator','on','Callback',@MHData_Load_maskfile);
uimenu(MHData,'Label','Edit masks','Callback',@MHData_edit_masks);
uimenu(MHData,'Label','Save and close','Callback',@MHData_Close,...
    'Separator','on','Accelerator','Q');
uimenu(MHData,'Label','Create field output','Callback',@MHData_Close_field);


% Crop menu
MHCrop      = uimenu(handles.fig ,'Label','Crop');
uimenu(MHCrop,'Label','Rectangle','Callback',@MHCrop_Rect);
uimenu(MHCrop,'Label','Delete','Callback',@MHCrop_Del,...
    'Separator','on');

% Mask menu
MHMask      = uimenu(handles.fig ,'Label','Mask');
uimenu(MHMask,'Label','Rectangle','Callback',@MHMask_Rect);
uimenu(MHMask,'Label','Polygon','Callback',@MHMask_Poly);
uimenu(MHMask,'Label','Ellipse','Callback',@MHMask_Ellip);
uimenu(MHMask,'Label','Delete all','Callback',@MHMask_Del,...
    'Separator','on');

% Region of interest menu
MHROI       = uimenu(handles.fig ,'Label','ROI');
uimenu(MHROI,'Label','Rectangle','Callback',@MHROI_Rect);
uimenu(MHROI,'Label','Polygon','Callback',@MHROI_Poly);
uimenu(MHROI,'Label','Ellipse','Callback',@MHROI_Ellip);
uimenu(MHROI,'Label','Delete','Callback',@MHROI_Del,...
    'Separator','on');

% Reference point menu
MHRefpoint	= uimenu(handles.fig ,'Label','Ref. point');
uimenu(MHRefpoint,'Label','Point','Callback',@MHRefpoint_Point);
uimenu(MHRefpoint,'Label','Delete','Callback',@MHRefpoint_Del,...
    'Separator','on');

% Options menu
MHOpts      = uimenu(handles.fig ,'Label','Options');
uimenu(MHOpts,'Label','Set options','Callback',@MHOptions_Set);
% uimenu(MHOpts,'Label','Toggle mask visibility','Callback',@MHOptions_mask);
uimenu(MHOpts,'Label','Show processed data','Callback',@MHOptions_show_data);
% uimenu(MHOpts,'Label','Remove deleted operations','Callback',@remove_deleted_operations);
uimenu(MHOpts,'Label','Write to workspace','Callback',@MHOptions_Show,...
    'Separator','on','Accelerator','S');
uimenu(MHOpts,'Label','Hatch over removed data','Callback',@MHOptions_hatch);

% Graphing menu - so can change what is viewed
MHGraph      = uimenu(handles.fig ,'Label','Graph');
% change what is diplayed as contour
MHGraph_Zdisplay=uimenu(MHGraph,'Label','Z display');
uimenu(MHGraph_Zdisplay,'Label','uX','Callback',@MHDisp_uX);
uimenu(MHGraph_Zdisplay,'Label','uY','Callback',@MHDisp_uY);
uimenu(MHGraph_Zdisplay,'Label','uZ','Callback',@MHDisp_uZ);
% change the orientation of the data in the figure
MHGraph_Axis=uimenu(MHGraph,'Label','Axes');
uimenu(MHGraph_Axis,'Label','X=PosX  Y=PosY','Callback',@MHGraph_XposX_YposY);
uimenu(MHGraph_Axis,'Label','X=PosX  Y=PosZ','Callback',@MHGraph_XposX_YposZ);
uimenu(MHGraph_Axis,'Label','X=PosY  Y=PosZ','Callback',@MHGraph_XposY_YposZ);
% change the viewing height along the 3 axes
MHGraph_height=uimenu(MHGraph,'Label','3D position');
uimenu(MHGraph_height,'Label','X height','Callback',@MHGraph_Xheight);
uimenu(MHGraph_height,'Label','Y height','Callback',@MHGraph_Yheight);
uimenu(MHGraph_height,'Label','Z height','Callback',@MHGraph_Zheight);

% % creat menu for removing rigid body motions
% MH_RBM=uimenu(handles.fig,'Label','RBM');
% uimenu(MH_RBM,'Label','Remove rigid body motions','Callback',@MH_RigidBodyMotions)

% --------------------------------------------------------------------
% Suporting functions:
% --------------------------------------------------------------------
% function to import 2D DIC data
function MHData_type_2DIC(hObject,~,handles)
    % update handles
    handles=guidata(hObject);
    fprintf('~ DIC has been selected as the data type\n');
    %open a ui to locate the data file
    [filename pathname]=uigetfile({'*.*';'*.dat';'*.vc7'},'File Selector');
    if filename~=0
        handles.procdata.filename=filename;
        handles.procdata.pathname=pathname;
        handles.procdata.data_type='DIC';
        handles.procdata.dic_type='2D';
        handles.procdata.RBM=0;
        handles.procdata.which_operations=[];
        %check what file extension it is
        dat_check=findstr(filename,'.dat');
        vc7_check=findstr(filename,'.vc7');

        if dat_check~=0 %if file is a .dat file then use getDICdata to obtain data
            fprintf('~ Loading dataset %s ...',filename);
            %import DIC data
            field=getDICdata(pathname,filename);
            fprintf('done\n');
            %store data in 'handles' variable
            handles.field=field;
            %update figure to show correct data
            imghandle = imagesc(sort([field.PosX(1,1),field.PosX(1,end)]),sort([field.PosY(1,1),field.PosY(end,1)]),field.uY);
            % stop imagesc from inverting y axis
            set(gca,'YDir','normal')
            xlabel('PosX')
            ylabel('PosY')
            title('uY')
            handles.procdata.Xaxis='PosX';
            handles.procdata.Yaxis='PosY';
            handles.procdata.Contour='uY';
            handles.procdata.zheight=1;
            handles.procdata.xheight=1;
            handles.procdata.yheight=1;
        elseif vc7_check>0 %if file is a vc7 file
            fprintf('~ Loading dataset %s ...',filename);
            % import data
            [field,useless_field]=getVC7data2D(filename,pathname);
            fprintf('done\n');
            % pass imported data to correctly named variables
            handles.field.PosX=field.POSX;
            handles.field.PosY=field.POSY;
            handles.field.PosZ=field.POSZ;
            handles.field.uX=field.UX;
            handles.field.uY=field.UY;
            %create a matrix of zeros for uZ since no uZ data will be available in the VC7 file
            [r,c]=size(handles.field.uX);
            handles.field.uZ=zeros(r,c);
            % update figure to show correct data
            imghandle = imagesc(sort([field.POSX(1,1),field.POSX(1,end)]),sort([field.POSY(1,1),field.POSY(end,1)]),field.UY);
            % stop imagesc from inverting y axis
            set(gca,'YDir','normal')
            xlabel('PosX')
            ylabel('PosY')
            title('uY')
            handles.procdata.Xaxis='PosX';
            handles.procdata.Yaxis='PosY';
            handles.procdata.Contour='uY';
            handles.procdata.zheight=1;
            handles.procdata.xheight=1;
            handles.procdata.yheight=1;
        end
        axis equal tight
        handles.procdata.which_operations=-1;
    else 
        fprintf('~ No data file was selected\n');
    end
    % update handles
    guidata(hObject, handles);
end

% function to import 3D DIC data
function MHData_type_3DIC(hObject,~,handles)
    handles=guidata(hObject);
    fprintf('~ DIC has been selected as the data type\n');
    %open a ui to locate the data file
    [filename pathname]=uigetfile({'*.*';'*.dat';'*.vc7'},'File Selector');
    if filename~=0
        handles.procdata.filename=filename;
        handles.procdata.pathname=pathname;
        handles.procdata.data_type='DIC';
        handles.procdata.dic_type='3D';
        handles.procdata.RBM=0;
        handles.procdata.which_operations=[];
        %check what file extension it is
        dat_check=findstr(filename,'.dat');
        vc7_check=findstr(filename,'.vc7');

        if dat_check~=0 %if file is a dat file then use getDICdata to obtain data
            fprintf('~ Loading dataset %s ...',filename);
            field=getDICdata(pathname,filename);
            fprintf('done\n');
            %store data in 'handles' variable
            handles.field=field;
            %update figure to show correct data
            imghandle = imagesc(sort([field.PosX(1,1),field.PosX(1,end)]),sort([field.PosY(1,1),field.PosY(end,1)]),field.uY);
            set(gca,'YDir','normal')
            xlabel('PosX')
            ylabel('PosY')
            title('uY')
            handles.procdata.Xaxis='PosX';
            handles.procdata.Yaxis='PosY';
            handles.procdata.Contour='uY';
            handles.procdata.zheight=1;
            handles.procdata.xheight=1;
            handles.procdata.yheight=1;
        elseif vc7_check>0 %if file is a vc7 file
            fprintf('~ Loading dataset %s ...',filename);
            [field,useless_field]=getVC7data(filename,pathname);
            fprintf('done\n');
            handles.field.PosX=field.POSX;
            handles.field.PosY=field.POSY;
            handles.field.PosZ=field.POSZ;
            handles.field.uX=field.UX;
            handles.field.uY=field.UY;
            handles.field.uZ=field.UZ;
            imghandle = imagesc(sort([field.POSX(1,1),field.POSX(1,end)]),sort([field.POSY(1,1),field.POSY(end,1)]),field.UY);
            set(gca,'YDir','normal')
            xlabel('PosX')
            ylabel('PosY')
            title('uY')
            handles.procdata.Xaxis='PosX';
            handles.procdata.Yaxis='PosY';
            handles.procdata.Contour='uY';
            handles.procdata.zheight=1;
            handles.procdata.xheight=1;
            handles.procdata.yheight=1;
        end
        axis equal tight
        handles.procdata.which_operations=-1;
    else
        fprintf('~ No data file was selected\n');
    end
    guidata(hObject, handles);
end

% function to import DVC data
function MHData_type_DVC(hObject,~,handles)
    handles=guidata(hObject);
    fprintf('~ DVC has been selected as the data type\n');
    %open a ui to locate the data file
    [filename pathname]=uigetfile({'*.*';'*.dat';'*.vc7'},'File Selector');
    if filename~=0
        handles.procdata.filename=filename;
        handles.procdata.pathname=pathname;
        fprintf('%s',filename)
        fprintf('%s',pathname)
        handles.procdata.data_type='DVC';
        isDVC=1;
        handles.procdata.RBM=0;
        handles.procdata.which_operations=[];


        %check what file extension it is
        dat_check=findstr(filename,'.dat');
        vc7_check=findstr(filename,'.vc7');
        if dat_check~=0
            fprintf('~ Loading dataset %s ...',filename);
            [field,gridspacing]=getDVCdata6(filename,pathname);
            fprintf('done\n');
            %store data in handles variable
            handles.field=field;
            %create variables for DVC data to be corrected to a format easier for displaying
            fprintf('Rearanging the DVC data for display purposes...')
            handles.field.PosX_c=Correct_DVC_data(field.PosX);
            handles.field.PosY_c=Correct_DVC_data(field.PosY);
            handles.field.PosZ_c=Correct_DVC_data(field.PosZ);
            handles.field.uX_c=Correct_DVC_data(field.uX);
            handles.field.uY_c=Correct_DVC_data(field.uY);
            handles.field.uZ_c=Correct_DVC_data(field.uZ);
            fprintf('done\n')
            %update figure to show correct data
            imghandle=imagesc([field.PosX(1,1,1),field.PosX(1,end,1)],[field.PosY(1,1,1),field.PosY(end,1,1)],field.uY(:,:,floor(max(size(field.uY(1,1,:)))/2)));
            set(gca,'YDir','normal')
            xlabel('PosX')
            ylabel('PosY')
            title('uY')
            handles.procdata.Xaxis='PosX';
            handles.procdata.Yaxis='PosY';
            handles.procdata.Contour='uY';
            handles.procdata.zheight=floor(max(size(field.uY(1,1,:)))/2);
            handles.procdata.xheight=floor(max(size(field.uY(1,:,1)))/2);
            handles.procdata.yheight=floor(max(size(field.uY(:,1,1)))/2);
            handles.procdata.zmax=max(size(field.uY(1,1,:)));
            handles.procdata.xmax=max(size(field.uY(1,:,1)));
            handles.procdata.ymax=max(size(field.uY(:,1,1)));
        elseif vc7_check~=0
            fprintf('~ Loading dataset %s ...',filename);
            [field,useless_field]=getVC7data(filename,pathname);
            fprintf('done\n');
            handles.field.PosX=field.POSX;
            handles.field.PosY=field.POSY;
            handles.field.PosZ=field.POSZ;
            handles.field.uX=field.UX;
            handles.field.uY=field.UY;
            handles.field.uZ=field.UZ;
            %create variables for DVC data to be corrected to a format easier for displaying
            fprintf('Rearanging the DVC data for display purposes...')
            handles.field.PosX_c=Correct_DVC_data(field.POSX);
            handles.field.PosY_c=Correct_DVC_data(field.POSY);
            handles.field.PosZ_c=Correct_DVC_data(field.POSZ);
            handles.field.uX_c=Correct_DVC_data(field.UX);
            handles.field.uY_c=Correct_DVC_data(field.UY);
            handles.field.uZ_c=Correct_DVC_data(field.UZ);
            fprintf('done\n')

            imghandle = imagesc([field.POSX(1,1,1),field.POSX(1,end,1)],[field.POSY(1,1,1),field.POSY(end,1,1)],field.UY(:,:,floor(max(size(field.UY(1,1,:)))/2)));
            set(gca,'YDir','normal')
            xlabel('PosX')
            ylabel('PosY')
            title('uY')
            handles.procdata.Xaxis='PosX';
            handles.procdata.Yaxis='PosY';
            handles.procdata.Contour='uY';
            handles.procdata.zheight=floor(max(size(field.UY(1,1,:)))/2);
            handles.procdata.xheight=floor(max(size(field.UY(1,:,1)))/2);
            handles.procdata.yheight=floor(max(size(field.UY(:,1,1)))/2);
            handles.procdata.zmax=max(size(field.UY(1,1,:)));
            handles.procdata.xmax=max(size(field.UY(1,:,1)));
            handles.procdata.ymax=max(size(field.UY(:,1,1)));
        end
        xmax=handles.procdata.xmax;
        ymax=handles.procdata.ymax;
        zmax=handles.procdata.zmax;
        axis equal tight
        handles.uistuff.slider=uicontrol('Style','slider','Position',[20,100,20,300],'min',1,'max',handles.procdata.zmax,'value',handles.procdata.zheight,'Callback',@Slider_callback);
        handles.uistuff.textbox=uicontrol('Style','text','Position',[5,50,60,20],'String',num2str(handles.field.PosZ(1,1,handles.procdata.zheight)),'ToolTipString',sprintf('The currently viewed plane''s value'));
        handles.uistuff.textbox2=uicontrol('Style','text','Position',[5,30,60,20],'String',sprintf('%d/%d',handles.procdata.zheight,handles.procdata.zmax),'ToolTipString',sprintf('The currently viewed plane out of how many panes exist in this direction'));

        set(handles.uistuff.slider,'SliderStep',[1 1]/(handles.procdata.zmax-1));
        handles.procdata.which_operations=-1;
    else
        fprintf('~ No data file was selected\n');
    end
    guidata(hObject, handles);
end

%function to allow the slider to change the height viewed with regards to DVC data
function Slider_callback(hObject,eventdata,handles)
    handles=guidata(hObject);py
    value=floor(get(handles.uistuff.slider,'value'));
    set(handles.uistuff.slider,'Value',value);
    if (handles.procdata.Xaxis=='PosX')&(handles.procdata.Yaxis=='PosY')
        handles.procdata.zheight=value;
        set(handles.uistuff.textbox,'string',num2str(handles.field.PosZ(1,1,value)));
        set(handles.uistuff.textbox2,'string',sprintf('%d/%d',handles.procdata.zheight,handles.procdata.zmax))
    elseif (handles.procdata.Xaxis=='PosX')&(handles.procdata.Yaxis=='PosZ')
        handles.procdata.yheight=value;
        set(handles.uistuff.textbox,'string',num2str(handles.field.PosY(value,1,1)));
        set(handles.uistuff.textbox2,'string',sprintf('%d/%d',handles.procdata.yheight,handles.procdata.ymax))
    elseif (handles.procdata.Xaxis=='PosY')&(handles.procdata.Yaxis=='PosZ')
        handles.procdata.xheight=value;
        set(handles.uistuff.textbox,'string',num2str(handles.field.PosX(1,value,1)));
        set(handles.uistuff.textbox2,'string',sprintf('%d/%d',handles.procdata.xheight,handles.procdata.xmax))
    end
    % set(handles.uistuff.textbox,'string',num2str(value));
    [handles,roi]=update_figure(roi,roicount,handles,handles.procdata.Xaxis,handles.procdata.Yaxis,handles.procdata.Contour,handles.procdata.xheight,handles.procdata.yheight,handles.procdata.zheight);
    guidata(hObject, handles);
end

%function to import FEM data into the gui
function MHData_type_FEM(hObject,~,handles)
    handles=guidata(hObject);
    fprintf('~ FEM has been selected as the data type\n~ For FEM data select the .dat file when selecting the data\n');
    handles.procdata.RBM=0;
    handles.procdata.which_operations=[];
    %open a ui to locate the data file
    [filename pathname]=uigetfile({'*.*';'*.dat';'*.vc7'},'File Selector');
    if filename~=0
        handles.procdata.filename=filename;
        handles.procdata.pathname=pathname;
        handles.procdata.data_type='FEM';
        dat_check=findstr(filename,'.dat');
        if dat_check~=0
            filename=[filename(1:dat_check-1), filename(dat_check+4:end)];
        end

        fullfilename=strcat(pathname,filename);
        idmask=[nan,nan,nan,nan,nan,nan];
        fprintf('~ Loading dataset %s ...\n',filename);
        [fieldfem,crackfem] = getFEMdata7(fullfilename,1,idmask);
        fprintf('~ Loading dataset %s ... done\n',filename);
        handles.field.PosX=fieldfem.POSX;
        handles.field.PosY=fieldfem.POSY;
        handles.field.PosZ=fieldfem.POSZ;
        handles.field.uX=fieldfem.UX;
        handles.field.uY=fieldfem.UY;
        handles.field.uZ=fieldfem.UZ;
        plot3(handles.field.PosX,handles.field.PosY,handles.field.PosZ,'.')
        handles.procdata.Xaxis='PosX';
        handles.procdata.Yaxis='PosY';
        handles.procdata.Contour='uY';
        axis equal tight
        handles.procdata.which_operations=-1;
    else
        fprintf('~ No data file was selected\n');
    end
    guidata(hObject, handles);
end

%function to laod old masks into the gui
function MHData_Load_maskfile(hObject,eventdata,handles)
    handles = guidata(hObject);
    fprintf('~ To load a masking file select the ''.mat'' file that contains the variable procdata\n');
    [filename pathname]=uigetfile({'*.mat'},'File Selector');
    %___________________________read input file
    %open file to read data from
    if filename~=0
        Old_folder=cd(pathname);
        warning off
        load(filename);
        warning on
        
        %navigate back to original folder
        cd(Old_folder);
        [field,procdata]=import_data(procdata,procdata.filename,procdata.pathname);
        handles.field=field;
        handles.procdata=procdata;
        %____________________________sort data from input file
        % handles.procdata.current
        [r,c,k]=size(field.PosZ);
        handles.procdata.zmax=k;
        handles.procdata.xmax=c;
        handles.procdata.ymax=r;
        for i=1:handles.procdata.current
            roi(i).act=procdata.op(i).act;
            roi(i).shape=procdata.op(i).shape;
            roi(i).coord=procdata.op(i).coord;
            roi(i).clude=procdata.op(i).clude;
            if handles.procdata.data_type=='DVC'
                roi(i).Xaxis=procdata.op(i).Xaxis;
                roi(i).Yaxis=procdata.op(i).Yaxis;
                roi(i).mask_range=procdata.op(i).mask_range;
                roi(i).height=procdata.op(i).height;
            end
        end
        if handles.procdata.data_type=='DVC'
            if (handles.procdata.Xaxis=='PosX')&(handles.procdata.Yaxis=='PosY')
                handles.uistuff.slider=uicontrol('Style','slider','Position',[20,100,20,300],'min',1,'max',handles.procdata.zmax,'value',handles.procdata.zheight,'Callback',@Slider_callback);
                handles.uistuff.textbox=uicontrol('Style','text','Position',[5,50,60,30],'String',num2str(handles.field.PosZ(1,1,handles.procdata.zheight)),'ToolTipString',sprintf('The currently viewed plane''s value'));
                handles.uistuff.textbox2=uicontrol('Style','text','Position',[5,30,60,20],'String',sprintf('%d/%d',handles.procdata.zheight,handles.procdata.zmax),'ToolTipString',sprintf('The currently viewed plane out of how many panes exist in this direction'));
                slider_step=[1 1]/(handles.procdata.zmax-1);
            elseif (handles.procdata.Xaxis=='PosX')&(handles.procdata.Yaxis=='PosZ')
                handles.uistuff.slider=uicontrol('Style','slider','Position',[20,100,20,300],'min',1,'max',handles.procdata.ymax,'value',handles.procdata.yheight,'Callback',@Slider_callback);
                handles.uistuff.textbox=uicontrol('Style','text','Position',[5,50,60,30],'String',num2str(handles.field.PosY(handles.procdata.yheight,1,1)),'ToolTipString',sprintf('The currently viewed plane''s value'));
                handles.uistuff.textbox2=uicontrol('Style','text','Position',[5,30,60,20],'String',sprintf('%d/%d',handles.procdata.yheight,handles.procdata.ymax),'ToolTipString',sprintf('The currently viewed plane out of how many panes exist in this direction'));
                slider_step=[1 1]/(handles.procdata.ymax-1);
            elseif (handles.procdata.Xaxis=='PosY')&(handles.procdata.Yaxis=='PosZ')
                handles.uistuff.slider=uicontrol('Style','slider','Position',[20,100,20,300],'min',1,'max',handles.procdata.xmax,'value',handles.procdata.xheight,'Callback',@Slider_callback);
                handles.uistuff.textbox=uicontrol('Style','text','Position',[5,50,60,30],'String',num2str(handles.field.PosX(1,handles.procdata.xheight,1)),'ToolTipString',sprintf('The currently viewed plane''s value'));
                handles.uistuff.textbox2=uicontrol('Style','text','Position',[5,30,60,20],'String',sprintf('%d/%d',handles.procdata.xheight,handles.procdata.xmax),'ToolTipString',sprintf('The currently viewed plane out of how many panes exist in this direction'));
                slider_step=[1 1]/(handles.procdata.xmax-1);
            end
        end
        set(handles.uistuff.slider,'SliderStep',slider_step);
        roicount=procdata.current;

        [handles1,roi]=update_figure(roi,roicount,handles,handles.procdata.Xaxis,handles.procdata.Yaxis,handles.procdata.Contour,handles.procdata.xheight,handles.procdata.yheight,handles.procdata.zheight);
    else
        fprintf('~ No file was selected\n');
    end
    %update 'handles'
    guidata(hObject, handles);
    
end

%function to make old masks loaded from an output file editable
function MHData_edit_masks(hObject,eventdata,handles)
    handles = guidata(hObject);
    if handles.procdata.data_type=='DIC'
        cla(gca)
        x_tick=sort([handles.field.PosX(1,1),handles.field.PosX(1,end)]);
        y_tick=sort([handles.field.PosY(1,1),handles.field.PosY(end,1)]);
        switch handles.procdata.Contour
            case 'uX'
                imghandle =imagesc(x_tick,y_tick,handles.field.uX);
                title('uX')
            case 'uY'
                imghandle =imagesc(x_tick,y_tick,handles.field.uY);
                title('uY')
            case 'uZ'
                imghandle =imagesc(x_tick,y_tick,handles.field.uZ);
                title('uZ')
        end
        set(gca,'YDir','normal')
        xlabel('PosX')
        ylabel('PosY')
        axis equal tight
        
        roi_new_count=0;
        for i=1:roicount
            switch roi(i).shape
            case 'rectangle'
                roi_new_count=roi_new_count+1;
                fprintf('~ Creating rectangular mask\n');
                %create dragable rectangle
                roi(i).handle = imrect(gca,roi(i).coord);
                set( get(roi(i).handle,'Children'),'UIContextMenu','' );
                roi(i).act='mask';
                roi(i).shape = 'rectangle';
                roi(i).coord = getPosition(roi(i).handle);
                if roi(i).clude=='include'
                    setColor(roi(i).handle,'g');
                else
                    setColor(roi(i).handle,'r');
                end
                addNewPositionCallback(roi(i).handle,@(pos)callbackroi(i));
                handles.roi(i).coord=roi(i).coord;

            case 'ellipse'
                fprintf('~ Creating elliptical mask\n');
                %create dragable rectangle
                roi_new_count = roi_new_count+1;
                roi(i).handle = imellipse(gca,roi(i).coord);
                set( get(roi(i).handle,'Children'),....
                        'UIContextMenu','' );
                roi(i).act='mask';
                roi(i).shape = 'ellipse';
                roi(i).coord = getPosition(roi(i).handle);
                if roi(i).clude=='include'
                    setColor(roi(i).handle,'g');
                else
                    setColor(roi(i).handle,'r');
                end
                addNewPositionCallback(roi(i).handle,@(pos)callbackroi(i));
                handles.roi(i).coord=roi(i).coord;
            case 'polygon'
                fprintf('~ Creating polygon mask\n');
                %create dragable rectangle
                roi_new_count = roi_new_count+1;
                roi(i).handle = impoly(gca,roi(i).coord);
                set( get(roi(i).handle,'Children'),....
                        'UIContextMenu','' );
                roi(i).act='mask';
                roi(i).shape = 'polygon';
                roi(i).coord = getPosition(roi(i).handle);
                if roi(i).clude=='include'
                    setColor(roi(i).handle,'g');
                else
                    setColor(roi(i).handle,'r');
                end
                addNewPositionCallback(roi(i).handle,@(pos)callbackroi(i));
                handles.roi(i).coord=roi(i).coord;
            case 'point'
                fprintf('~ Creating reference point\n');
                %create dragable rectangle
                roi_new_count = roi_new_count+1;
                roi(i).handle = impoint(gca,roi(i).coord);
                set( get(roi(i).handle,'Children'),....
                        'UIContextMenu','' );
                roi(i).act='ref';
                roi(i).shape = 'point';
                position=getPosition(roi(i).handle);
                if handles.procdata.data_type=='DIC'
                    [valx,indx]=min(abs(handles.field.PosX(1,:)-position(1)));
                    [valy,indy]=min(abs(handles.field.PosY(:,1)-position(2)));
                    p_out(1)=handles.field.PosX(1,indx);
                    p_out(2)=handles.field.PosY(indy,1);
                    roi(i).coord = p_out;
                end
                if roi(i).clude=='include'
                    setColor(roi(i).handle,'g');
                else
                    setColor(roi(i).handle,'r');
                end
                addNewPositionCallback(roi(i).handle,@(pos)callbackroi(i));
                handles.roi(i).coord=roi(i).coord;
            end
        end
    elseif handles.procdata.data_type=='DVC'
        cla(gca) %clear axes
        if (handles.procdata.Xaxis=='PosX')&(handles.procdata.Yaxis=='PosY')
            x_tick=sort([handles.field.PosX(1,1,1),handles.field.PosX(1,end,1)]);
            y_tick=sort([handles.field.PosY(1,1,1),handles.field.PosY(end,1,1)]);
            switch handles.procdata.Contour
                case 'uX'
                    dispX(:,:)=squeeze(handles.field.uX(:,:,handles.procdata.zheight));
                    imghandle =imagesc(x_tick,y_tick,dispX);
                    set(gca,'YDir','normal');
                case 'uY'
                    dispY(:,:)=squeeze(handles.field.uY(:,:,handles.procdata.zheight));
                    imghandle =imagesc(x_tick,y_tick,dispY);
                    set(gca,'YDir','normal');
                case 'uZ'
                    dispZ(:,:)=squeeze(handles.field.uZ(:,:,handles.procdata.zheight));
                    imghandle =imagesc(x_tick,y_tick,dispZ);
                    set(gca,'YDir','normal');
            end
        elseif (handles.procdata.Xaxis=='PosX')&(handles.procdata.Yaxis=='PosZ')
            x_tick=sort([handles.field.PosX(1,1,1),handles.field.PosX(1,end,1)]);
            y_tick=sort([handles.field.PosZ(1,1,1),handles.field.PosZ(1,1,end)]);
            switch handles.procdata.Contour
                case 'uX'
                    dispX(:,:)=squeeze(handles.field.uX_c(:,handles.procdata.yheight,:));
                    imghandle =imagesc(x_tick,y_tick,dispX);
                    set(gca,'YDir','normal');
                case 'uY'
                    dispY(:,:)=squeeze(handles.field.uY_c(:,handles.procdata.yheight,:));
                    imghandle =imagesc(x_tick,y_tick,dispY);
                    set(gca,'YDir','normal');
                case 'uZ'
                    dispZ(:,:)=squeeze(handles.field.uZ_c(:,handles.procdata.yheight,:));
                    imghandle =imagesc(x_tick,y_tick,dispZ);
                    set(gca,'YDir','normal');
            end
        elseif (handles.procdata.Xaxis=='PosY')&(handles.procdata.Yaxis=='PosZ')
            x_tick=sort([handles.field.PosY(1,1,1),handles.field.PosY(end,1,1)]);
            y_tick=sort([handles.field.PosZ(1,1,1),handles.field.PosZ(1,1,end)]);
            switch handles.procdata.Contour
                case 'uX'
                    dispX(:,:)=squeeze(handles.field.uX_c(:,:,handles.procdata.xheight));
                    imghandle =imagesc(x_tick,y_tick,dispX);
                    set(gca,'YDir','normal');
                case 'uY'
                    dispY(:,:)=squeeze(handles.field.uY_c(:,:,handles.procdata.xheight));
                    imghandle =imagesc(x_tick,y_tick,dispY);
                    set(gca,'YDir','normal');
                case 'uZ'
                    dispZ(:,:)=squeeze(handles.field.uZ_c(:,:,handles.procdata.xheight));
                    imghandle =imagesc(x_tick,y_tick,dispZ);
                    set(gca,'YDir','normal');
            end
        end
        % set(gca,'YDir','normal')
        title(handles.procdata.Contour)
        xlabel(handles.procdata.Xaxis)
        ylabel(handles.procdata.Yaxis)
        roi_new_count=0;
        for i=1:roicount
            if ((roi(i).Xaxis==handles.procdata.Xaxis)&(roi(i).Yaxis==handles.procdata.Yaxis))|(findstr(roi(i).shape,'point'))
                if (roi(i).Xaxis=='PosX')&(roi(i).Yaxis=='PosY')
                    height=handles.procdata.zheight;
                elseif (roi(i).Xaxis=='PosX')&(roi(i).Yaxis=='PosZ')
                    height=handles.procdata.yheight;
                elseif (roi(i).Xaxis=='PosY')&(roi(i).Yaxis=='PosZ')
                    height=handles.procdata.xheight;
                end
                if (height>=min(roi(i).mask_range))&(height<=max(roi(i).mask_range))
                    switch roi(i).shape
                    case 'rectangle'
                        fprintf('~ Creating rectangular mask\n');
                        %create dragable rectangle
                        roi_new_count = roi_new_count+1;
                        roi(i).handle = imrect(gca,roi(i).coord);
                        set( get(roi(i).handle,'Children'),'UIContextMenu','' );
                        roi(i).act='mask';
                        roi(i).shape = 'rectangle';
                        roi(i).coord = getPosition(roi(i).handle);
                        if roi(i).clude=='include'
                            setColor(roi(i).handle,'g');
                        else
                            setColor(roi(i).handle,'r');
                        end
                        addNewPositionCallback(roi(i).handle,@(pos)callbackroi(i));
                        handles.roi(i).coord=roi(i).coord;
                    case 'ellipse'
                        fprintf('~ Creating elliptical mask\n');
                        %create dragable rectangle
                        roi_new_count = roi_new_count+1;
                        roi(i).handle = imellipse(gca,roi(i).coord);
                        set( get(roi(i).handle,'Children'),'UIContextMenu','' );
                        roi(i).act='mask';
                        roi(i).shape = 'ellipse';
                        roi(i).coord = getPosition(roi(i).handle);
                        if roi(i).clude=='include'
                            setColor(roi(i).handle,'g');
                        else
                            setColor(roi(i).handle,'r');
                        end
                        addNewPositionCallback(roi(i).handle,@(pos)callbackroi(i));
                        handles.roi(i).coord=roi(i).coord;
                    case 'polygon'
                        fprintf('~ Creating polygon mask\n');
                        %create dragable rectangle
                        roi_new_count = roi_new_count+1;
                        roi(i).handle = impoly(gca,roi(i).coord);
                        set( get(roi(i).handle,'Children'),'UIContextMenu','' );
                        roi(i).act='mask';
                        roi(i).shape = 'polygon';
                        roi(i).coord = getPosition(roi(i).handle);
                        if roi(i).clude=='include'
                            setColor(roi(i).handle,'g');
                        else
                            setColor(roi(i).handle,'r');
                        end
                        addNewPositionCallback(roi(i).handle,@(pos)callbackroi(i));
                        handles.roi(i).coord=roi(i).coord;
                    case 'point'
                        fprintf('~ Creating reference point\n');
                        %create dragable rectangle
                        roi_new_count = roi_new_count+1;
                        if (handles.procdata.Xaxis=='PosX')&(handles.procdata.Yaxis=='PosY')
                            if (roi(i).Xaxis=='PosX')&(roi(i).Yaxis=='PosY')
                                roi(i).handles=impoint(gca,roi(i).coord);
                            elseif (roi(i).Xaxis=='PosX')&(roi(i).Yaxis=='PosZ')
                                roi(i).handle=impoint(gca,[roi(i).coord(1),handles.field.PosY(roi(i).height,1,1)]);
                            elseif (roi(i).Xaxis=='PosY')&(roi(i).Yaxis=='PosZ')
                                roi(i).handle=impoint(gca,[handles.field.PosX(1,roi(i).height,1), roi(i).coord(1)]);
                            end
                        elseif (handles.procdata.Xaxis=='PosX')&(handles.procdata.Yaxis=='PosZ')
                            if (roi(i).Xaxis=='PosX')&(roi(i).Yaxis=='PosZ')
                                roi(i).handle=impoint(gca,roi(i).coord);
                            elseif (roi(i).Xaxis=='PosY')&(roi(i).Yaxis=='PosZ')
                                roi(i).handle=impoint(gca,[handles.field.PosX(1,roi(i).height), roi(i).coord(2)]);
                            elseif (roi(i).Xaxis=='PosX')&(roi(i).Yaxis=='PosY')
                                roi(i).handle=impoint(gca,[roi(i).coord(1), handles.field.PosZ(1,1,roi(i).height)]);
                            end
                        elseif (handles.procdata.Xaxis=='PosY')&(handles.procdata.Yaxis=='PosZ')
                            if (roi(i).Xaxis=='PosY')&(roi(i).Yaxis=='PosZ')
                                roi(i).handle=impoint(gca,roi(i).coord);
                            elseif (roi(i).Xaxis=='PosX')&(roi(i).Yaxis=='PosZ')
                                roi(i).handle=impoint(gca,[handles.field.PosY(roi(i).height,1,1), roi(i).coord(2)]);
                            elseif (roi(i).Xaxis=='PosX')&(roi(i).Yaxis=='PosY')
                                roi(i).handle=impoint(gca,[roi(i).coord(2), handles.field.PosZ(1,1,roi(i).height)]);
                            end
                        end
                        set( get(roi(i).handle,'Children'),'UIContextMenu','' );
                        roi(i).act='ref';
                        roi(i).shape = 'point';
                        position=getPosition(roi(i).handle);
                        if handles.procdata.data_type=='DIC'
                            [valx,indx]=min(abs(handles.field.PosX(1,:)-position(1)));
                            [valy,indy]=min(abs(handles.field.PosY(:,1)-position(2)));
                            p_out(1)=handles.field.PosX(1,indx);
                            p_out(2)=handles.field.PosY(indy,1);
                            roi(i).coord = p_out;
                        end
                        if roi(i).clude=='include'
                            setColor(roi(i).handle,'g');
                        else
                            setColor(roi(i).handle,'r');
                        end
                        addNewPositionCallback(roi(i).handle,@(pos)callbackroi(i));
                        handles.roi(i).coord=roi(i).coord;
                    end
                end
            end
        end
    end
    handles = guidata(hObject);
end 

% function to close the gui and write the relevant data to a .mat file for use in 'field_format'
function MHData_Close(hObject,~,handles)
    % hObject    handle to MHData_Close (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    handles = guidata(hObject);
    [roi,roicount]=remove_deleted_ops(roi,roicount);
    handles.procdata.current=roicount;
    for i=1:roicount
        handles.procdata.op(i).act=roi(i).act;
        handles.procdata.op(i).shape=roi(i).shape;
        handles.procdata.op(i).coord=roi(i).coord;
        handles.procdata.op(i).clude=roi(i).clude;
        if handles.procdata.data_type=='DVC'
            handles.procdata.op(i).Xaxis=roi(i).Xaxis;
            handles.procdata.op(i).Yaxis=roi(i).Yaxis;
            handles.procdata.op(i).mask_range=roi(i).mask_range;
            handles.procdata.op(i).height=roi(i).height;
        end
    end
    proc_save=handles.procdata;
    % assignin('base', 'procdata', proc_save);

    [FileNameSave,PathNameSave] = uiputfile({'*.mat'},sprintf('Save Field Operations As: (it should be saved as a ''.mat'' file)'),'GUI_outputfile.mat');
    Old_folder=cd(PathNameSave);
    procdata=proc_save;
    save(FileNameSave,'procdata');
    cd(Old_folder);
    close
    clear global
end

% function to close the gui and output field data to a selected file
function MHData_Close_field(hObject,~,handles)
    % hObject    handle to MHData_Close (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    handles = guidata(hObject);
    [roi,roicount]=remove_deleted_ops(roi,roicount);
    handles.procdata.current=roicount;
    for i=1:roicount
        handles.procdata.op(i).act=roi(i).act;
        handles.procdata.op(i).shape=roi(i).shape;
        handles.procdata.op(i).coord=roi(i).coord;
        handles.procdata.op(i).clude=roi(i).clude;
        if handles.procdata.data_type=='DVC'
            handles.procdata.op(i).Xaxis=roi(i).Xaxis;
            handles.procdata.op(i).Yaxis=roi(i).Yaxis;
            handles.procdata.op(i).mask_range=roi(i).mask_range;
            handles.procdata.op(i).height=roi(i).height;
        end
    end
    proc_save=handles.procdata;
    % assignin('base', 'procdata', proc_save);

    [FileNameSave,PathNameSave] = uiputfile({'*.mat'},sprintf('Save Field As: (it should be saved as a ''.mat'' file)'),'field.mat');
    Old_folder=cd(PathNameSave);
    procdata=proc_save;
    fprintf('~ Formatting displacement data according to operations\n');
    field=field_format(procdata);
    fprintf('~ Saving field data to file %s ...',FileNameSave);
    save(FileNameSave,'field');
    fprintf('done\n');
    cd(Old_folder);
end

%function to create rectangular mask
function MHCrop_Rect(hObject, eventdata, handles)
    % hObject    handle to MHData_Select (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % update handles
    handles = guidata(hObject);
    fprintf('~ Creating rectangular crop\n');
    %create dragable rectangle
    roicount = roicount+1;
    roi(roicount).handle = imrect;
    set( get(roi(roicount).handle,'Children'),....
            'UIContextMenu','' );
    roi(roicount).act='crop';
    roi(roicount).shape = 'rectangle';
    roi(roicount).coord = getPosition(roi(roicount).handle);
    roi(roicount).clude = 'include';
    if handles.procdata.data_type=='DVC' %if data is DVC data
        % save currently viewed axes
        roi(roicount).Xaxis=handles.procdata.Xaxis;
        roi(roicount).Yaxis=handles.procdata.Yaxis;
        % save range over which mask is valid
        if (roi(roicount).Xaxis=='PosX')&(roi(roicount).Yaxis=='PosY')
            roi(roicount).mask_range=sort([1 handles.procdata.zmax]);
            roi(roicount).height=handles.procdata.zheight;
        elseif (roi(roicount).Xaxis=='PosX')&(roi(roicount).Yaxis=='PosZ')
            roi(roicount).mask_range=sort([1 handles.procdata.ymax]);
            roi(roicount).height=handles.procdata.yheight;
        elseif (roi(roicount).Xaxis=='PosY')&(roi(roicount).Yaxis=='PosZ')
            roi(roicount).mask_range=sort([1 handles.procdata.xmax]);
            roi(roicount).height=handles.procdata.xheight;
        end
    end
    setColor(roi(roicount).handle,'g');
    addNewPositionCallback(roi(roicount).handle,@(pos)callbackroi(roicount));
    handles.roi(roicount).coord=roi(roicount).coord;


    handles = guidata(hObject);
end

% function to delete all crops created
function MHCrop_Del(hObject, eventdata, handles)
    % hObject    handle to MHData_Select (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    handles = guidata(hObject);
    fprintf('~ Deleting rectangular crop...');
    count=1;

    for i=1:roicount
        % check=findstr(roi(i).act,'crop')
        if findstr(roi(i).act,'crop')
            change(count)=i;
            count=count+1;
        end
    end
    count=0;
    for i=1:length(change)
        for j=1:roicount
            if (j>=change(i)-i+1)&(j<=roicount-i)
                roi(j-i+1)=roi(j+1);
            elseif (j>=change(i)-i+1)
                roi(j)=[];
            end
        end
    end
    roicount=roicount-length(change);
    [handles,roi]=update_figure(roi,roicount,handles,handles.procdata.Xaxis,handles.procdata.Yaxis,handles.procdata.Contour,handles.procdata.xheight,handles.procdata.yheight,handles.procdata.zheight);
    fprintf('deleted\n');
    guidata(hObject, handles);
end

% function to create rectangular mask
function MHMask_Rect(hObject, eventdata, handles)
    % hObject    handle to MHData_Select (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % update handles
    handles = guidata(hObject);
    fprintf('~ Creating rectangular mask\n');
    %create dragable rectangle
    roicount = roicount+1;
    roi(roicount).handle = imrect;
    set( get(roi(roicount).handle,'Children'),....
            'UIContextMenu','' );
    roi(roicount).act='mask';
    roi(roicount).shape = 'rectangle';
    roi(roicount).coord = getPosition(roi(roicount).handle);
    roi(roicount).clude = 'include';
    if handles.procdata.data_type=='DVC' %if data is DVC data
        % save currently viewed axes
        roi(roicount).Xaxis=handles.procdata.Xaxis;
        roi(roicount).Yaxis=handles.procdata.Yaxis;
        % save range over which mask is valid
        if (roi(roicount).Xaxis=='PosX')&(roi(roicount).Yaxis=='PosY')
            roi(roicount).mask_range=sort([1 handles.procdata.zmax]);
            roi(roicount).height=handles.procdata.zheight;
        elseif (roi(roicount).Xaxis=='PosX')&(roi(roicount).Yaxis=='PosZ')
            roi(roicount).mask_range=sort([1 handles.procdata.ymax]);
            roi(roicount).height=handles.procdata.yheight;
        elseif (roi(roicount).Xaxis=='PosY')&(roi(roicount).Yaxis=='PosZ')
            roi(roicount).mask_range=sort([1 handles.procdata.xmax]);
            roi(roicount).height=handles.procdata.xheight;
        end
    end
    setColor(roi(roicount).handle,'g');
    addNewPositionCallback(roi(roicount).handle,@(pos)callbackroi(roicount));
    handles.roi(roicount).coord=roi(roicount).coord;

    handles = guidata(hObject);
end

% function to create polygon mask
function MHMask_Poly(hObject, eventdata, handles)
    % hObject    handle to MHData_Select (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % update handles
    handles = guidata(hObject);
    fprintf('~ Creating polygon mask\n');
    %create dragable rectangle
    roicount = roicount+1;
    roi(roicount).handle = impoly;
    set( get(roi(roicount).handle,'Children'),....
            'UIContextMenu','' );
    roi(roicount).act='mask';
    roi(roicount).shape = 'polygon';
    roi(roicount).coord = getPosition(roi(roicount).handle);
    roi(roicount).clude = 'include';
    if handles.procdata.data_type=='DVC' %if data is DVC data
        % save currently viewed axes
        roi(roicount).Xaxis=handles.procdata.Xaxis;
        roi(roicount).Yaxis=handles.procdata.Yaxis;
        % save range over which mask is valid
        if (roi(roicount).Xaxis=='PosX')&(roi(roicount).Yaxis=='PosY')
            roi(roicount).mask_range=sort([1 handles.procdata.zmax]);
            roi(roicount).height=handles.procdata.zheight;
        elseif (roi(roicount).Xaxis=='PosX')&(roi(roicount).Yaxis=='PosZ')
            roi(roicount).mask_range=sort([1 handles.procdata.ymax]);
            roi(roicount).height=handles.procdata.yheight;
        elseif (roi(roicount).Xaxis=='PosY')&(roi(roicount).Yaxis=='PosZ')
            roi(roicount).mask_range=sort([1 handles.procdata.xmax]);
            roi(roicount).height=handles.procdata.xheight;
        end
    end
    setColor(roi(roicount).handle,'g');
    addNewPositionCallback(roi(roicount).handle,@(pos)callbackroi(roicount));
    handles.roi(roicount).coord=roi(roicount).coord;

    handles = guidata(hObject);
end

% function to create elliptical mask
function MHMask_Ellip(hObject, eventdata, handles)
    % hObject    handle to MHData_Select (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % update handles
    handles = guidata(hObject);
    fprintf('~ Creating elliptical mask\n');
    %create dragable rectangle
    roicount = roicount+1;
    roi(roicount).handle = imellipse;
    set( get(roi(roicount).handle,'Children'),....
            'UIContextMenu','' );
    roi(roicount).act='mask';
    roi(roicount).shape = 'ellipse';
    roi(roicount).coord = getPosition(roi(roicount).handle);
    roi(roicount).clude = 'include';
    if handles.procdata.data_type=='DVC' %if data is DVC data
        % save currently viewed axes
        roi(roicount).Xaxis=handles.procdata.Xaxis;
        roi(roicount).Yaxis=handles.procdata.Yaxis;
        % save range over which mask is valid
        if (roi(roicount).Xaxis=='PosX')&(roi(roicount).Yaxis=='PosY')
            roi(roicount).mask_range=sort([1 handles.procdata.zmax]);
            roi(roicount).height=handles.procdata.zheight;
        elseif (roi(roicount).Xaxis=='PosX')&(roi(roicount).Yaxis=='PosZ')
            roi(roicount).mask_range=sort([1 handles.procdata.ymax]);
            roi(roicount).height=handles.procdata.yheight;
        elseif (roi(roicount).Xaxis=='PosY')&(roi(roicount).Yaxis=='PosZ')
            roi(roicount).mask_range=sort([1 handles.procdata.xmax]);
            roi(roicount).height=handles.procdata.xheight;
        end
    end
    setColor(roi(roicount).handle,'g');
    addNewPositionCallback(roi(roicount).handle,@(pos)callbackroi(roicount));
    handles.roi(roicount).coord=roi(roicount).coord;

    handles = guidata(hObject);
end

% function to delete all the masks that were created
function MHMask_Del(hObject, eventdata, handles)
    % hObject    handle to MHData_Select (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    handles = guidata(hObject); %update handle
    fprintf('~ Deleting masks...');
    count=1;
    % check for operations corresponding to operation type to be deleted and store the indices of these in 'change'
    for i=1:roicount
        % check=findstr(roi(i).act,'mask')
        if findstr(roi(i).act,'mask')
            change(count)=i;
            count=count+1;
        end
    end
    count=0;
    % edit procdata so that the correct operations are removed and the rest of the operations are moved up accordingly
    for i=1:length(change)
        for j=1:roicount
            if (j>=change(i)-i+1)&(j<=roicount-i)
                roi(j-i+1)=roi(j+1);
            elseif (j>=change(i)-i+1)
                roi(j)=[];
            end
        end
    end
    % edit the count for the amount of operations
    roicount=roicount-length(change);
    % update the figure
    [handles,roi]=update_figure(roi,roicount,handles,handles.procdata.Xaxis,handles.procdata.Yaxis,handles.procdata.Contour,handles.procdata.xheight,handles.procdata.yheight,handles.procdata.zheight);
    fprintf('deleted\n');
    % update handles
    guidata(hObject, handles);
end

% function to create a rectangular ROI
function MHROI_Rect(hObject, eventdata, handles)
    % hObject    handle to MHData_Select (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % update handles
    handles = guidata(hObject);
    fprintf('~ Creating rectangular ROI\n');
    %create dragable rectangle
    roicount = roicount+1;
    roi(roicount).handle = imrect;
    set( get(roi(roicount).handle,'Children'),....
            'UIContextMenu','' );
    roi(roicount).act='roi';
    roi(roicount).shape = 'rectangle';
    roi(roicount).coord = getPosition(roi(roicount).handle);
    roi(roicount).clude = 'include';
    if handles.procdata.data_type=='DVC' %if data is DVC data
        % save currently viewed axes
        roi(roicount).Xaxis=handles.procdata.Xaxis;
        roi(roicount).Yaxis=handles.procdata.Yaxis;
        % save range over which mask is valid
        if (roi(roicount).Xaxis=='PosX')&(roi(roicount).Yaxis=='PosY')
            roi(roicount).mask_range=sort([1 handles.procdata.zmax]);
            roi(roicount).height=handles.procdata.zheight;
        elseif (roi(roicount).Xaxis=='PosX')&(roi(roicount).Yaxis=='PosZ')
            roi(roicount).mask_range=sort([1 handles.procdata.ymax]);
            roi(roicount).height=handles.procdata.yheight;
        elseif (roi(roicount).Xaxis=='PosY')&(roi(roicount).Yaxis=='PosZ')
            roi(roicount).mask_range=sort([1 handles.procdata.xmax]);
            roi(roicount).height=handles.procdata.xheight;
        end
    end
    setColor(roi(roicount).handle,'g');
    addNewPositionCallback(roi(roicount).handle,@(pos)callbackroi(roicount));
    handles.roi(roicount).coord=roi(roicount).coord;

    handles = guidata(hObject);
end

% function to create a ROI in the form of a polygon
function MHROI_Poly(hObject, eventdata, handles)
    % hObject    handle to MHData_Select (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % update handles
    handles = guidata(hObject);
    fprintf('~ Creating polygon ROI\n');
    %create dragable rectangle
    roicount = roicount+1;
    roi(roicount).handle = impoly;
    set( get(roi(roicount).handle,'Children'),....
            'UIContextMenu','' );
    roi(roicount).act='roi';
    roi(roicount).shape = 'polygon';
    roi(roicount).coord = getPosition(roi(roicount).handle);
    roi(roicount).clude = 'include';
    if handles.procdata.data_type=='DVC' %if data is DVC data
        % save currently viewed axes
        roi(roicount).Xaxis=handles.procdata.Xaxis;
        roi(roicount).Yaxis=handles.procdata.Yaxis;
        % save range over which mask is valid
        if (roi(roicount).Xaxis=='PosX')&(roi(roicount).Yaxis=='PosY')
            roi(roicount).mask_range=sort([1 handles.procdata.zmax]);
            roi(roicount).height=handles.procdata.zheight;
        elseif (roi(roicount).Xaxis=='PosX')&(roi(roicount).Yaxis=='PosZ')
            roi(roicount).mask_range=sort([1 handles.procdata.ymax]);
            roi(roicount).height=handles.procdata.yheight;
        elseif (roi(roicount).Xaxis=='PosY')&(roi(roicount).Yaxis=='PosZ')
            roi(roicount).mask_range=sort([1 handles.procdata.xmax]);
            roi(roicount).height=handles.procdata.xheight;
        end
    end
    setColor(roi(roicount).handle,'g');
    addNewPositionCallback(roi(roicount).handle,@(pos)callbackroi(roicount));
    handles.roi(roicount).coord=roi(roicount).coord;

    handles = guidata(hObject);
end

% function to create an elliptical ROI
function MHROI_Ellip(hObject, eventdata, handles)
    % hObject    handle to MHData_Select (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % update handles
    handles = guidata(hObject);
    fprintf('~ Creating elliptical ROI\n');
    %create dragable rectangle
    roicount = roicount+1;
    roi(roicount).handle = imellipse;
    set( get(roi(roicount).handle,'Children'),....
            'UIContextMenu','' );
    roi(roicount).act='roi';
    roi(roicount).shape = 'ellipse';
    roi(roicount).coord = getPosition(roi(roicount).handle);
    roi(roicount).clude = 'include';
    if handles.procdata.data_type=='DVC' %if data is DVC data
        % save currently viewed axes
        roi(roicount).Xaxis=handles.procdata.Xaxis;
        roi(roicount).Yaxis=handles.procdata.Yaxis;
        % save range over which mask is valid
        if (roi(roicount).Xaxis=='PosX')&(roi(roicount).Yaxis=='PosY')
            roi(roicount).mask_range=sort([1 handles.procdata.zmax]);
            roi(roicount).height=handles.procdata.zheight;
        elseif (roi(roicount).Xaxis=='PosX')&(roi(roicount).Yaxis=='PosZ')
            roi(roicount).mask_range=sort([1 handles.procdata.ymax]);
            roi(roicount).height=handles.procdata.yheight;
        elseif (roi(roicount).Xaxis=='PosY')&(roi(roicount).Yaxis=='PosZ')
            roi(roicount).mask_range=sort([1 handles.procdata.xmax]);
            roi(roicount).height=handles.procdata.xheight;
        end
    end
    setColor(roi(roicount).handle,'g');
    addNewPositionCallback(roi(roicount).handle,@(pos)callbackroi(roicount));
    handles.roi(roicount).coord=roi(roicount).coord;

    handles = guidata(hObject);
end

% function to delete all created ROI
function MHROI_Del(hObject, eventdata, handles)
    % hObject    handle to MHData_Select (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    handles = guidata(hObject); %update handle
    fprintf('~ Deleting masks...');
    count=1;
    % check for operations corresponding to operation type to be deleted and store the indices of these in 'change'
    for i=1:roicount
        % check=findstr(roi(i).act,'ROI');
        if findstr(roi(i).act,'ROI')
            change(count)=i;
            count=count+1;
        end
    end
    count=0;
    % edit procdata so that the correct operations are removed and the rest of the operations are moved up accordingly
    for i=1:length(change)
        for j=1:roicount
            if (j>=change(i)-i+1)&(j<=roicount-i)
                roi(j-i+1)=roi(j+1);
            elseif (j>=change(i)-i+1)
                roi(j)=[];
            end
        end
    end
    % edit the count for the amount of operations
    roicount=roicount-length(change);
    % update the figure
    [handles,roi]=update_figure(roi,roicount,handles,handles.procdata.Xaxis,handles.procdata.Yaxis,handles.procdata.Contour,handles.procdata.xheight,handles.procdata.yheight,handles.procdata.zheight);
    fprintf('deleted\n');
    % update handles
    guidata(hObject, handles);
end

% function to create the reference points
function MHRefpoint_Point(hObject, eventdata, handles)
    % hObject    handle to MHData_Select (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    handles = guidata(hObject);
    fprintf('~ Creating reference point\n');
    %create dragable rectangle
    roicount = roicount+1;
    roi(roicount).handle = impoint;
    set( get(roi(roicount).handle,'Children'),....
            'UIContextMenu','' );
    roi(roicount).act='ref';
    roi(roicount).shape = 'point';
    position=getPosition(roi(roicount).handle);
    if handles.procdata.data_type=='DIC'
        [valx,indx]=min(abs(handles.field.PosX(1,:)-position(1)));
        [valy,indy]=min(abs(handles.field.PosY(:,1)-position(2)));
        p_out(1)=handles.field.PosX(1,indx);
        p_out(2)=handles.field.PosY(indy,1);
        roi(roicount).coord = p_out;
    end


    roi(roicount).clude = 'include';
    if handles.procdata.data_type=='DVC' %if data is DVC data
        % save currently viewed axes
        roi(roicount).Xaxis=handles.procdata.Xaxis;
        roi(roicount).Yaxis=handles.procdata.Yaxis;
        % save range over which mask is valid
        if (roi(roicount).Xaxis=='PosX')&(roi(roicount).Yaxis=='PosY')
            [valx,indx]=min(abs(handles.field.PosX(1,:,1)-position(1)));
            [valy,indy]=min(abs(handles.field.PosY(:,1,1)-position(2)));
            p_out(1)=handles.field.PosX(1,indx,1);
            p_out(2)=handles.field.PosY(indy,1,1);
            roi(roicount).coord = p_out;
            roi(roicount).mask_range=[1 handles.procdata.zmax];
            roi(roicount).height=handles.procdata.zheight;
        elseif (roi(roicount).Xaxis=='PosX')&(roi(roicount).Yaxis=='PosZ')
            [valx,indx]=min(abs(handles.field.PosX(1,:,1)-position(2)));
            [valz,indz]=min(abs(handles.field.PosZ(1,1,:)-position(1)));
            p_out(2)=handles.field.PosX(1,indx,1);
            p_out(1)=handles.field.PosZ(1,1,indz);
            roi(roicount).coord = p_out;
            roi(roicount).mask_range=[1 handles.procdata.ymax];
            roi(roicount).height=handles.procdata.yheight;
        elseif (roi(roicount).Xaxis=='PosY')&(roi(roicount).Yaxis=='PosZ')
            [valy,indy]=min(abs(handles.field.PosY(:,1,1)-position(2)));
            [valz,indz]=min(abs(handles.field.PosZ(1,1,:)-position(1)));
            p_out(2)=handles.field.PosY(indy,1,1);
            p_out(1)=handles.field.PosZ(1,1,indz);
            roi(roicount).coord = p_out;
            roi(roicount).mask_range=[1 handles.procdata.xmax];
            roi(roicount).height=handles.procdata.xheight;
        end
    end
    setColor(roi(roicount).handle,'g');
    addNewPositionCallback(roi(roicount).handle,@(pos)callbackroi(roicount));
    handles.roi(roicount).coord=roi(roicount).coord;
    handles = guidata(hObject);
end

% function to deleted all the reference points
function MHRefpoint_Del(hObject, eventdata, handles)
    % hObject    handle to MHData_Select (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    handles = guidata(hObject); %update handle
    fprintf('~ Deleting reference point...');
    count=1;
    % check for operations corresponding to operation type to be deleted and store the indices of these in 'change'
    for i=1:roicount
        % check=findstr(roi(i).act,'ref');
        if findstr(roi(i).act,'ref')
            change(count)=i;
            count=count+1;
        end
    end
    count=0;
    % edit procdata so that the correct operations are removed and the rest of the operations are moved up accordingly
    for i=1:length(change)
        for j=1:roicount
            if (j>=change(i)-i+1)&(j<=roicount-i)
                roi(j-i+1)=roi(j+1);
            elseif (j>=change(i)-i+1)
                roi(j)=[];
            end
        end
    end
    % edit the count for the amount of operations
    roicount=roicount-length(change);
    % update the figure
    [handles,roi]=update_figure(roi,roicount,handles,handles.procdata.Xaxis,handles.procdata.Yaxis,handles.procdata.Contour,handles.procdata.xheight,handles.procdata.yheight,handles.procdata.zheight);
    fprintf('deleted\n');
    % update handles
    guidata(hObject, handles);
end

% function to set which operations are to be used to process the data
function MHOptions_Set(hObject, eventdata,handles)
    % hObject    handle to MHData_Select (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    handles = guidata(hObject);
    [roi,roicount]=remove_deleted_ops(roi,roicount);
    [operations,RBM]=options_set_gui(handles,roi,roicount);
    handles.procdata.which_operations=operations;
    handles.procdata.RBM=RBM;
    guidata(hObject, handles);
end

% function that runs backend to process data and displays the output data of the currently selected operations
function MHOptions_show_data(hObject,eventdata,handles)
    handles = guidata(hObject);
    [roi,roicount]=remove_deleted_ops(roi,roicount);
    if handles.procdata.which_operations==-1
        handles.procdata.which_operations=ones(roicount);
    end
    handles.procdata.current=roicount;
    for i=1:roicount
        handles.procdata.op(i).act=roi(i).act;
        handles.procdata.op(i).shape=roi(i).shape;
        handles.procdata.op(i).coord=roi(i).coord;
        handles.procdata.op(i).clude=roi(i).clude;
        if handles.procdata.data_type=='DVC'
            handles.procdata.op(i).Xaxis=roi(i).Xaxis;
            handles.procdata.op(i).Yaxis=roi(i).Yaxis;
            handles.procdata.op(i).mask_range=roi(i).mask_range;
            handles.procdata.op(i).height=roi(i).height;
        end
    end
    field=field_format(handles.procdata);
    if handles.procdata.data_type=='DIC'  
        x_tick=sort([field.PosX(1,1),field.PosX(1,end)]);
        y_tick=sort([field.PosY(1,1),field.PosY(end,1)]);
        switch handles.procdata.Contour
        case 'uX'
            figure
            imghandle =imagesc(x_tick,y_tick,field.uX);
            title('uX')
        case 'uY'
            figure
            imghandle =imagesc(x_tick,y_tick,field.uY);
            title('uY')
        case 'uZ'
            figure
            imghandle =imagesc(x_tick,y_tick,field.uZ);
            title('uZ')
        end
        axis equal tight
        set(gca,'YDir','normal')
        xlabel('PosX')
        ylabel('PosY')
    elseif handles.procdata.data_type=='DVC'
        x_tick=sort([field.PosX(1,1,1),field.PosX(1,end,1)]);
        y_tick=sort([field.PosY(1,1,1),field.PosY(end,1,1)]);
        switch handles.procdata.Contour
            case 'uX'
                disp1(:,:)=field.uX(:,:,handles.procdata.zheight);
                figure
                imghandle =imagesc(x_tick,y_tick,disp1);
                title('uX')
            case 'uY'
                disp1(:,:)=field.uY(:,:,handles.procdata.zheight);
                figure
                imghandle =imagesc(x_tick,y_tick,disp1);
                title('uY')
            case 'uZ'
                disp1(:,:)=field.uZ(:,:,handles.procdata.zheight);
                figure
                imghandle =imagesc(x_tick,y_tick,disp1);
                title('uZ')
        end
        set(gca,'YDir','normal')
        xlabel('PosX')
        ylabel('PosY')
        axis equal tight
        x_tick=sort([field.PosX(1,1,1),field.PosX(1,end,1)]);
        y_tick=sort([field.PosZ(1,1,1),field.PosZ(1,1,end)]);
        switch handles.procdata.Contour
            case 'uX'
                disp2(:,:)=field.uX(handles.procdata.yheight,:,:);
                figure
                imghandle =imagesc(x_tick,y_tick,disp2);
                title('uX')
            case 'uY'
                disp2(:,:)=field.uY(handles.procdata.yheight,:,:);
                figure
                imghandle =imagesc(x_tick,y_tick,disp2);
                title('uY')
            case 'uZ'
                disp2(:,:)=field.uZ(handles.procdata.yheight,:,:);
                figure
                imghandle =imagesc(x_tick,y_tick,disp2);
                title('uZ')
        end
        set(gca,'YDir','normal')
        xlabel('PosZ')
        ylabel('PosX')
        axis equal tight
        x_tick=sort([field.PosY(1,1,1),field.PosY(end,1,1)]);
        y_tick=sort([field.PosZ(1,1,1),field.PosZ(1,1,end)]);
        switch handles.procdata.Contour
            case 'uX'
                disp3(:,:)=rfield.uX(:,handles.procdata.xheight,:);
                figure
                imghandle =imagesc(x_tick,y_tick,disp3);
                title('uX')
            case 'uY'
                disp3(:,:)=field.uY(:,handles.procdata.xheight,:);
                figure
                imghandle =imagesc(x_tick,y_tick,disp3);
                title('uY')
            case 'uZ'
                disp3(:,:)=field.uZ(:,handles.procdata.xheight,:);
                figure
                imghandle =imagesc(x_tick,y_tick,disp3);
                title('uZ')
        end
        set(gca,'YDir','normal')
        xlabel('PosZ')
        ylabel('PosY')
        axis equal tight
    end
end

% function to assign the relevant data to the workspace
function MHOptions_Show(hObject,eventdata,handles)
    handles = guidata(hObject);
    handles.procdata.current=roicount;
    % [roi,roicount]=handles2roi(handles);
    [roi,roicount]=remove_deleted_ops(roi,roicount);
    fprintf('~ Assigning variables to workspace...');
    for i=1:roicount
        handles.procdata.op(i).act=roi(i).act;
        handles.procdata.op(i).shape=roi(i).shape;
        handles.procdata.op(i).coord=roi(i).coord;
        handles.procdata.op(i).clude=roi(i).clude;
        if handles.procdata.data_type=='DVC'
            handles.procdata.op(i).Xaxis=roi(i).Xaxis;
            handles.procdata.op(i).Yaxis=roi(i).Yaxis;
            handles.procdata.op(i).mask_range=roi(i).mask_range;
        end
    end
    assignin('base', 'handles', handles);
    procdata=handles.procdata;
    assignin('base', 'procdata', procdata);
    assignin('base', 'roi', roi);
    assignin('base', 'roicount', roicount);
    fprintf('done\n');
end

% function to hatch out the removed data
function MHOptions_hatch(hObject,eventdata,handles)
    handles = guidata(hObject);
    [roi,roicount]=remove_deleted_ops(roi,roicount);
    for i=1:roicount
        handles.procdata.op(i).act=roi(i).act;
        if findstr(roi(i).act,'ref')|(findstr(roi(i).act,'crop'))
            check_ref(i)=0;
        else
            check_ref(i)=1;
        end
        if findstr(roi(i).act,'ref')
            check_mask(i)=0;
        else
            check_mask(i)=1;
        end
        handles.procdata.op(i).shape=roi(i).shape;
        handles.procdata.op(i).coord=roi(i).coord;
        handles.procdata.op(i).clude=roi(i).clude;
        if handles.procdata.data_type=='DVC'
            handles.procdata.op(i).Xaxis=roi(i).Xaxis;
            handles.procdata.op(i).Yaxis=roi(i).Yaxis;
            handles.procdata.op(i).mask_range=roi(i).mask_range;
        end
    end
    handles.procdata.current=roicount;
    procdata=handles.procdata;

    field=field_format(handles.procdata,'which operations',check_ref);
    field2=field_format(handles.procdata,'which operations',check_mask);
    % Valid=isnan(field.uX);
    cla(gca)
    if handles.procdata.data_type=='DIC'
        Valid=isnan(field.uX);
        switch handles.procdata.Contour
        case 'uX'
            f=handles.field.uX;
            title_string='uX';
        case 'uY'
            f=handles.field.uY;
            title_string='uY';
        case 'uZ'
            f=handles.field.uZ;
            title_string='uZ';
        end
        f_min=min(min(f));
        f=f-f_min;
        m=max(max(f));
        f=f.*1/m;
        imagesc([handles.field.PosX(1,1) handles.field.PosX(1,end)],[handles.field.PosY(1,1),handles.field.PosY(end,1)],f,[0 1]);
        set(gca,'YDir','normal');
        xlabel('PosX');
        ylabel('PosY');
        title(title_string);
        axis equal tight
        hold on
        [c2,h2] = contourf(field.PosX(1,:),field.PosY(:,1),Valid,[1 1]);
        
        set(h2,'linestyle','none','Tag','HatchingRegion');
        hold off
        ax1 = gca;
        if verLessThan('matlab','8.4')
           hg1onlyopt = {'FaceColor','none'};
        else
           hg1onlyopt = {};
        end
        hp = findobj(ax1,'Tag','HatchingRegion');
        hh = hatchfill2(hp,'cross','LineWidth',1,hg1onlyopt{:});
    elseif handles.procdata.data_type=='DVC'
        [r,c,v]=size(handles.field.PosX)
        if (handles.procdata.Xaxis=='PosX')&(handles.procdata.Yaxis=='PosY')
            x_tick=sort([handles.field.PosX(1,1,1), handles.field.PosX(1,end,1)]);
            y_tick=sort([handles.field.PosY(1,1,1), handles.field.PosY(end,1,1)]);
            x_leg=zeros(c,1);
            y_leg=zeros(r,1);
            x_leg(:,1)=handles.field.PosX(1,:,1);
            y_leg(:,1)=handles.field.PosY(:,1,1);
            Valid_up(:,:)=isnan(field.uX(:,:,handles.procdata.zheight));
            switch handles.procdata.Contour
            case 'uX'
                f(:,:)=squeeze(handles.field.uX(:,:,handles.procdata.zheight));
                title_string='uX';
            case 'uY'
                f(:,:)=squeeze(handles.field.uY(:,:,handles.procdata.zheight));
                title_string='uY';
            case 'uZ'
                f(:,:)=squeeze(handles.field.uZ(:,:,handles.procdata.zheight));
                title_string='uZ';
            end
        elseif (handles.procdata.Xaxis=='PosX')&(handles.procdata.Yaxis=='PosZ')
            x_tick=sort([handles.field.PosX(1,1,1), handles.field.PosX(1,end,1)]);
            y_tick=sort([handles.field.PosZ(1,1,1), handles.field.PosZ(1,1,end)]);
            % y_leg=zeros(c,1);
            % x_leg=zeros(v,1);
            x_leg(:,1)=handles.field.PosX(1,:,1);
            y_leg(:,1)=handles.field.PosZ(1,1,:);
            Valid_up(:,:)=isnan(field.uX(handles.procdata.yheight,:,:));
            switch handles.procdata.Contour
            case 'uX'
                f(:,:)=squeeze(handles.field.uX_c(:,handles.procdata.yheight,:));
                title_string='uX';
            case 'uY'
                f(:,:)=squeeze(handles.field.uY_c(:,handles.procdata.yheight,:));
                title_string='uY';
            case 'uZ'
                f(:,:)=squeeze(handles.field.uZ_c(:,handles.procdata.yheight,:));
                title_string='uZ';
            end
            f=rot90(fliplr(f),1);
            Valid_up=rot90(fliplr(Valid_up),1);
        elseif (handles.procdata.Xaxis=='PosY')&(handles.procdata.Yaxis=='PosZ')
            x_tick=sort([handles.field.PosY(1,1,1), handles.field.PosY(end,1,1)]);
            y_tick=sort([handles.field.PosZ(1,1,1), handles.field.PosZ(1,1,end)]);
            % y_leg=zeros(r,1);
            % x_leg=zeros(v,1);
            x_leg(:,1)=handles.field.PosY(:,1,1);
            y_leg(:,1)=handles.field.PosZ(1,1,:);
            Valid_up(:,:)=isnan(field.uX(:,handles.procdata.xheight,:));

            switch handles.procdata.Contour
            case 'uX'
                f(:,:)=squeeze(handles.field.uX_c(:,:,handles.procdata.xheight));
                title_string='uX';
            case 'uY'
                f(:,:)=squeeze(handles.field.uY_c(:,:,handles.procdata.xheight));
                title_string='uY';
            case 'uZ'
                f(:,:)=squeeze(handles.field.uZ_c(:,:,handles.procdata.xheight));
                
                title_string='uZ';
            end
            f=transpose(f);
            Valid_up=transpose(Valid_up);
        end
        
        size(Valid_up)
        size(x_leg)
        size(y_leg)
        x_leg_max=max(x_leg)
        y_leg_max=max(y_leg)
        f_min=min(min(f));
        f=f-f_min;
        m=max(max(f));
        f=f.*1/m;
        %plot figure
        imagesc(x_tick,y_tick,f,[0 1]);
        set(gca,'YDir','normal');
        xlabel(handles.procdata.Xaxis)
        ylabel(handles.procdata.Yaxis)
        title(title_string);
        axis equal tight
        hold on
        [c2,h2] = contourf(x_leg,y_leg,Valid_up,[1 1]);
        
        set(h2,'linestyle','none','Tag','HatchingRegion');
        hold off
        ax1 = gca;
        if verLessThan('matlab','8.4')
           hg1onlyopt = {'FaceColor','none'};
        else
           hg1onlyopt = {};
        end
        hp = findobj(ax1,'Tag','HatchingRegion');
        hh = hatchfill2(hp,'cross','LineWidth',1,hg1onlyopt{:});
    end 

end

% function to change the data viewed to display the uX data
function MHDisp_uX(hObject, eventdata, handles)
    handles = guidata(hObject);
    [roi,roicount]=remove_deleted_ops(roi,roicount);
    [handles,roi]=update_figure(roi,roicount,handles,handles.procdata.Xaxis,handles.procdata.Yaxis,'uX',handles.procdata.xheight,handles.procdata.yheight,handles.procdata.zheight);
    guidata(hObject, handles);
end

% function to change the data viewed to display the uY data
function MHDisp_uY(hObject, eventdata, handles)
    handles = guidata(hObject);
    [roi,roicount]=remove_deleted_ops(roi,roicount);
    [handles,roi]=update_figure(roi,roicount,handles,handles.procdata.Xaxis,handles.procdata.Yaxis,'uY',handles.procdata.xheight,handles.procdata.yheight,handles.procdata.zheight);
    guidata(hObject, handles);
end

% function to change the data viewed to display the uZ data
function MHDisp_uZ(hObject, eventdata, handles)
    handles = guidata(hObject);
    [roi,roicount]=remove_deleted_ops(roi,roicount);
    [handles,roi]=update_figure(roi,roicount,handles,handles.procdata.Xaxis,handles.procdata.Yaxis,'uZ',handles.procdata.xheight,handles.procdata.yheight,handles.procdata.zheight);
    guidata(hObject, handles);
end

%function to change the data viewed with PosX on the x-axis and PosY on the y-axis
function MHGraph_XposX_YposY(hObject,eventdata,handles)
    handles = guidata(hObject);
    [roi,roicount]=remove_deleted_ops(roi,roicount);
    if handles.procdata.data_type=='DVC'
        set(handles.uistuff.textbox,'string',num2str(handles.field.PosZ(1,1,handles.procdata.zheight)));
        set(handles.uistuff.textbox2,'string',sprintf('%d/%d',handles.procdata.zheight,handles.procdata.zmax));
        set(handles.uistuff.slider,'max',handles.procdata.zmax);
        set(handles.uistuff.slider,'max',handles.procdata.zmax);
        set(handles.uistuff.slider,'value',handles.procdata.zheight);
        set(handles.uistuff.slider,'SliderStep',[1 1]/(handles.procdata.zmax-1));
        [handles,roi]=update_figure(roi,roicount,handles,'PosX','PosY',handles.procdata.Contour,handles.procdata.xheight,handles.procdata.yheight,handles.procdata.zheight);
    elseif handles.procdata.data_type=='DIC'
        fprintf('~ Changing what data is displayed on the axes is not recommended for DIC data\n');
    end
    guidata(hObject, handles);
end

%function to change the data viewed with PosX on the x-axis and PosZ on the y-axis
function MHGraph_XposX_YposZ(hObject,eventdata,handles)
    handles = guidata(hObject);
    [roi,roicount]=remove_deleted_ops(roi,roicount);
    if handles.procdata.data_type=='DVC'
        set(handles.uistuff.textbox,'string',num2str(handles.field.PosY(handles.procdata.yheight,1,1)));
        set(handles.uistuff.textbox2,'string',sprintf('%d/%d',handles.procdata.yheight,handles.procdata.ymax));
        set(handles.uistuff.slider,'max',handles.procdata.ymax);
        set(handles.uistuff.slider,'max',handles.procdata.ymax);
        set(handles.uistuff.slider,'value',handles.procdata.yheight);
        set(handles.uistuff.slider,'SliderStep',[1 1]/(handles.procdata.ymax-1));
        [handles,roi]=update_figure(roi,roicount,handles,'PosX','PosZ',handles.procdata.Contour,handles.procdata.xheight,handles.procdata.yheight,handles.procdata.zheight);
    elseif handles.procdata.data_type=='DIC'
        fprintf('~ Changing what data is displayed on the axes is not recommended for DIC data\n');
    end
    guidata(hObject, handles);
end

%function to change the data viewed with PosY on the x-axis and PosZ on the y-axis
function MHGraph_XposY_YposZ(hObject,eventdata,handles)
    handles = guidata(hObject);
    [roi,roicount]=remove_deleted_ops(roi,roicount);
    if handles.procdata.data_type=='DVC'
        set(handles.uistuff.textbox,'string',num2str(handles.field.PosX(1,handles.procdata.xheight,1)));
        set(handles.uistuff.textbox2,'string',sprintf('%d/%d',handles.procdata.xheight,handles.procdata.xmax));
        set(handles.uistuff.slider,'max',handles.procdata.xmax);
        set(handles.uistuff.slider,'max',handles.procdata.xmax);
        set(handles.uistuff.slider,'value',handles.procdata.xheight);
        set(handles.uistuff.slider,'SliderStep',[1 1]/(handles.procdata.xmax-1));
        [handles,roi]=update_figure(roi,roicount,handles,'PosY','PosZ',handles.procdata.Contour,handles.procdata.xheight,handles.procdata.yheight,handles.procdata.zheight);
    elseif handles.procdata.data_type=='DIC'
        fprintf('~ Changing what data is displayed on the axes is not recommended for DIC data\n');
    end
    guidata(hObject, handles);
end

% function to change the height in the x direction
function MHGraph_Xheight(hObject,eventdata,handles)
    handles = guidata(hObject);
    [roi,roicount]=remove_deleted_ops(roi,roicount);
    if handles.procdata.data_type=='DVC'
        [xval]=GUI_height('X',handles.procdata.xmax);
        % prompt=sprintf('~ Enter a value for the height along x ranging between 1 and %d\n\t~ ',handles.procdata.xmax);
        % xval=input(prompt);
        if xval<=handles.procdata.xmax
            handles.procdata.xheight=xval;
            if (handles.procdata.Xaxis=='PosY')&(handles.procdata.Yaxis=='PosZ')
                set(handles.uistuff.textbox,'string',num2str(handles.field.PosX(1,handles.procdata.xheight,1)));
                set(handles.uistuff.textbox2,'string',sprintf('%d/%d',handles.procdata.xheight,handles.procdata.xmax));
                set(handles.uistuff.slider,'Value',handles.procdata.xheight);
            end
            [handles,roi]=update_figure(roi,roicount,handles,handles.procdata.Xaxis,handles.procdata.Yaxis,handles.procdata.Contour,handles.procdata.xheight,handles.procdata.yheight,handles.procdata.zheight);
        else
            fprintf('~ Error: The value entered does not fall within the range of the data\n');
        end
    else
        fprintf('~ This function is only available for DVC data\n')
    end
        
    guidata(hObject, handles);
end

% function to change the height in the y direction
function MHGraph_Yheight(hObject,eventdata,handles)
    handles = guidata(hObject);
    [roi,roicount]=remove_deleted_ops(roi,roicount);
    if handles.procdata.data_type=='DVC'
        [yval]=GUI_height('Y',handles.procdata.ymax);
        % prompt=sprintf('~ Enter a value for the height along y ranging between 1 and %d\n\t~ ',handles.procdata.ymax);
        % yval=input(prompt);
        if yval<=handles.procdata.ymax
            handles.procdata.yheight=yval;
            if (handles.procdata.Xaxis=='PosX')&(handles.procdata.Yaxis=='PosZ')
                set(handles.uistuff.textbox,'string',num2str(handles.field.PosY(handles.procdata.yheight,1,1)));
                set(handles.uistuff.textbox2,'string',sprintf('%d/%d',handles.procdata.yheight,handles.procdata.ymax));
                set(handles.uistuff.slider,'Value',handles.procdata.yheight);
            end
            [handles,roi]=update_figure(roi,roicount,handles,handles.procdata.Xaxis,handles.procdata.Yaxis,handles.procdata.Contour,handles.procdata.xheight,handles.procdata.yheight,handles.procdata.zheight);
        else
            fprintf('~ Error: The value entered does not fall within the range of the data\n');
        end
    else
        fprintf('~ This function is only available for DVC data\n')
    end
    guidata(hObject, handles);
end

% function to change the height in the z direction
function MHGraph_Zheight(hObject,eventdata,handles)
    handles = guidata(hObject);
    [roi,roicount]=remove_deleted_ops(roi,roicount);
    if handles.procdata.data_type=='DVC'
        [zval]=GUI_height('Z',handles.procdata.zmax);
        % prompt=sprintf('~ Enter a value for the height along z ranging between 1 and %d\n\t~ ',handles.procdata.zmax);
        % zval=input(prompt);
        if zval<=handles.procdata.zmax
            handles.procdata.zheight=zval;
            if (handles.procdata.Xaxis=='PosX')&(handles.procdata.Yaxis=='PosY')
                set(handles.uistuff.textbox,'string',num2str(handles.field.PosZ(1,1,handles.procdata.zheight)));
                set(handles.uistuff.textbox2,'string',sprintf('%d/%d',handles.procdata.zheight,handles.procdata.zmax));
                set(handles.uistuff.slider,'Value',handles.procdata.zheight);
            end
            [handles,roi]=update_figure(roi,roicount,handles,handles.procdata.Xaxis,handles.procdata.Yaxis,handles.procdata.Contour,handles.procdata.xheight,handles.procdata.yheight,handles.procdata.zheight);
        else
            fprintf('~ Error: The value entered does not fall within the range of the data\n');
        end
    else
        fprintf('~ This function is only available for DVC data\n')
    end
    guidata(hObject, handles);
end

%function to allow the positions of the masks to be updated and provide the rightclickmenu for them
function callbackroi( roicount )
    % CALLBACKROI resets properties of current selected roi.
    %   CALLBACKROI(roicount) resets position, mask, colour and label for
    %   selected roi.
    
    % Set new positions
    roi(roicount).coord = getPosition(roi(roicount).handle);

    % Set new UI menu (right click).
    rightclickhandle = uicontextmenu('parent',handles.fig);
    uimenu(rightclickhandle,'Label','Include','Callback',@rightclickmenu);
    uimenu(rightclickhandle,'Label','Exclude','Callback',@rightclickmenu);
    uimenu(rightclickhandle,'Label','Delete' ,'Callback',@rightclickmenu);
    uimenu(rightclickhandle,'Label','Mask range' ,'Callback',@rightclickmenu);
    set(get(roi(roicount).handle,'Children'),'UIContextMenu',rightclickhandle);
    
    function rightclickmenu( source,~,~ ) %create a rightclickmenu with include/exclude/mask range options
        % RIGHTCLICKMENU options called in uicontextmenu and uimenu.
        %   RIGHTCLICKMENU(source,...,handle) are Matlab defined varargins.
        
        switch source.Label
            case 'Include'
                setColor(roi(roicount).handle,'g')
                roi(roicount).clude = 'include';
            case 'Exclude'
                setColor(roi(roicount).handle,'r')
                roi(roicount).clude = 'exclude';
            case 'Delete'
                delete(roi(roicount).handle);
                roi(roicount).act ='removed';
            case 'Mask range'
                if isDVC
                    if (roi(roicount).Xaxis=='PosX')&(roi(roicount).Yaxis=='PosY')
                        [mask_handle,out1,out2]=mask_range_gui(zmax)
                        max_check=zmax;
                    elseif (roi(roicount).Xaxis=='PosX')&(roi(roicount).Yaxis=='PosZ')
                        [mask_handle,out1,out2]=mask_range_gui(ymax)
                        max_check=ymax;
                    elseif (roi(roicount).Xaxis=='PosY')&(roi(roicount).Yaxis=='PosZ')
                        [mask_handle,out1,out2]=mask_range_gui(xmax)
                        max_check=xmax;
                    end
                    val1=out1;
                    val2=out2;
                    if (val1<=max_check)&(val2<=max_check)&(val1>0)&(val2>0)
                        roi(roicount).mask_range=sort([val1 val2]);
                    else
                        fprintf('~ Error: The selected range does not fall within the range of the data\n');
                    end
                else 
                    fprintf('Applying a mask range is only availabe for DVC and FEM data\n');
                end
        end
    end
end
end % end of ROI_GUI

% function to update roi so that operations removed by rightclickmenu are removed
function [roi,roicount]=remove_deleted_ops(roi,roicount)
    if roicount>0
        removed=0;
        for i=1:roicount
            if findstr(roi(i).act,'removed')
                removed=removed+1;
                for j=i:roicount-1
                    roi(j)=roi(j+1);
                end
            end
        end
        roicount=roicount-removed;
    else 
        fprintf('~ There are no operations currently stored\n');
    end
end

%function to plot the data on the axes and to plot the mask applicable to the orientation viewed (DVC)
function [handles,roi]=update_figure(roi,roicount,handles,Xaxis,Yaxis,Contour,xheight,yheight,zheight)
    cla(gca) %clear axis
    if handles.procdata.data_type=='DIC'
        x_tick=sort([handles.field.PosX(1,1),handles.field.PosX(1,end)]);
        y_tick=sort([handles.field.PosY(1,1),handles.field.PosY(end,1)]);
        handles.procdata.Contour=Contour;
        switch Contour
            case 'uX'
                imghandle =imagesc(x_tick,y_tick,handles.field.uX);
                set(gca,'YDir','normal');
                title('uX')
            case 'uY'
                imghandle =imagesc(x_tick,y_tick,handles.field.uY);
                set(gca,'YDir','normal');
                title('uY')
            case 'uZ'
                imghandle =imagesc(x_tick,y_tick,handles.field.uZ);
                set(gca,'YDir','normal');
                title('uZ')
        end
        set(gca,'YDir','normal')
        xlabel(Xaxis)
        ylabel(Yaxis)
        for i=1:roicount
            if findstr(roi(i).shape,'rectangle')>0
                roi(i).handle=imrect(gca,[roi(i).coord(1), roi(i).coord(2), roi(i).coord(3), roi(i).coord(4)]);
                if findstr(roi(i).clude,'include')
                    setColor(roi(i).handle,'g')
                else
                    setColor(roi(i).handle,'r')
                end
            elseif findstr(roi(i).shape,'polygon')>0
                roi(i).handle=impoly(gca,roi(i).coord);
                if findstr(roi(i).clude,'include')
                    setColor(roi(i).handle,'g')
                else
                    setColor(roi(i).handle,'r')
                end
            elseif findstr(roi(i).shape,'ellipse')>0
                roi(i).handle=imellipse(gca,[roi(i).coord(1), roi(i).coord(2), roi(i).coord(3), roi(i).coord(4)]);
                if findstr(roi(i).clude,'include')
                    setColor(roi(i).handle,'g')
                else
                    setColor(roi(i).handle,'r')
                end
            elseif findstr(roi(i).shape,'point')>0
                roi(i).handle=impoint(gca,[roi(i).coord(1), roi(i).coord(2)]);
                if findstr(roi(i).clude,'include')
                    setColor(roi(i).handle,'g')
                else
                    setColor(roi(i).handle,'r')
                end
            end
        end
    elseif handles.procdata.data_type=='DVC'
        handles.procdata.xheight=xheight;
        handles.procdata.yheight=yheight;
        handles.procdata.zheight=zheight;
        % fprintf('%d %d %d',xheight,yheight,zheight) for checking the height values
        if (Xaxis=='PosX')&(Yaxis=='PosY')
            x_tick=sort([handles.field.PosX(1,1,1),handles.field.PosX(1,end,1)]);
            y_tick=sort([handles.field.PosY(1,1,1),handles.field.PosY(end,1,1)]);
            handles.procdata.Xaxis='PosX';
            handles.procdata.Yaxis='PosY';
            switch Contour
                case 'uX'
                    dispX(:,:)=squeeze(handles.field.uX(:,:,zheight));
                    imghandle =imagesc(x_tick,y_tick,dispX);
                    set(gca,'YDir','normal');
                    handles.procdata.Contour='uX';
                case 'uY'
                    dispY(:,:)=squeeze(handles.field.uY(:,:,zheight));
                    imghandle =imagesc(x_tick,y_tick,dispY);
                    set(gca,'YDir','normal');
                    handles.procdata.Contour='uY';
                case 'uZ'
                    dispZ(:,:)=squeeze(handles.field.uZ(:,:,zheight));
                    imghandle =imagesc(x_tick,y_tick,dispZ);
                    set(gca,'YDir','normal');
                    handles.procdata.Contour='uZ';
            end
        elseif (Xaxis=='PosX')&(Yaxis=='PosZ')
            x_tick=sort([handles.field.PosX(1,1,1),handles.field.PosX(1,end,1)]);
            y_tick=sort([handles.field.PosZ(1,1,1),handles.field.PosZ(1,1,end)]);
            handles.procdata.Xaxis='PosX';
            handles.procdata.Yaxis='PosZ';
            switch Contour
                case 'uX'
                    % dispX(:,:)=squeeze(handles.field.uX(yheight,:,:));
                    dispX(:,:)=squeeze(handles.field.uX_c(:,yheight,:));
                    imghandle =imagesc(x_tick,y_tick,dispX);
                    set(gca,'YDir','normal');
                    handles.procdata.Contour='uX';
                case 'uY'
                    % dispY(:,:)=squeeze(handles.field.uY(yheight,:,:));
                    dispY(:,:)=squeeze(handles.field.uY_c(:,yheight,:));
                    imghandle =imagesc(x_tick,y_tick,dispY);
                    set(gca,'YDir','normal');
                    handles.procdata.Contour='uY';
                case 'uZ'
                    % dispZ(:,:)=squeeze(handles.field.uZ(yheight,:,:));
                    dispZ(:,:)=squeeze(handles.field.uZ_c(:,yheight,:));
                    imghandle =imagesc(x_tick,y_tick,dispZ);
                    set(gca,'YDir','normal');
                    handles.procdata.Contour='uZ';
            end
        elseif (Xaxis=='PosY')&(Yaxis=='PosZ')
            x_tick=sort([handles.field.PosY(1,1,1),handles.field.PosY(end,1,1)]);
            y_tick=sort([handles.field.PosZ(1,1,1),handles.field.PosZ(1,1,end)]);
            handles.procdata.Xaxis='PosY';
            handles.procdata.Yaxis='PosZ';
            switch Contour
                case 'uX'
                    % dispX(:,:)=squeeze(handles.field.uX(:,xheight,:));
                    dispX(:,:)=squeeze(handles.field.uX_c(:,:,xheight));
                    imghandle =imagesc(x_tick,y_tick,dispX);
                    set(gca,'YDir','normal');
                    handles.procdata.Contour='uX';
                case 'uY'
                    % dispY(:,:)=squeeze(handles.field.uY(:,xheight,:));
                    dispY(:,:)=squeeze(handles.field.uY_c(:,:,xheight));
                    imghandle =imagesc(x_tick,y_tick,dispY);
                    set(gca,'YDir','normal');
                    handles.procdata.Contour='uY';
                case 'uZ'
                    % dispZ(:,:)=squeeze(handles.field.uZ(:,xheight,:));
                    dispZ(:,:)=squeeze(handles.field.uZ_c(:,:,xheight));
                    imghandle =imagesc(x_tick,y_tick,dispZ);
                    set(gca,'YDir','normal');
                    handles.procdata.Contour='uZ';
            end
        end
        set(gca,'YDir','normal')
        title(handles.procdata.Contour)
        xlabel(handles.procdata.Xaxis)
        ylabel(handles.procdata.Yaxis)
        if roicount>0
            for i=1:roicount
                if (roi(i).Xaxis==Xaxis)&(roi(i).Yaxis==Yaxis)
                    if (roi(i).Xaxis=='PosX')&(roi(i).Yaxis=='PosY')
                        height=handles.procdata.zheight;
                    elseif (roi(i).Xaxis=='PosX')&(roi(i).Yaxis=='PosZ')
                        height=handles.procdata.yheight;
                    elseif (roi(i).Xaxis=='PosY')&(roi(i).Yaxis=='PosZ')
                        height=handles.procdata.xheight;
                    end
                    if (height>=min(roi(i).mask_range))&(height<=max(roi(i).mask_range))
                        if findstr(roi(i).shape,'rectangle')>0
                            roi(i).handle=imrect(gca,[roi(i).coord(1), roi(i).coord(2), roi(i).coord(3), roi(i).coord(4)]);
                            if findstr(roi(i).clude,'include')
                                setColor(roi(i).handle,'g')
                            else
                                setColor(roi(i).handle,'r')
                            end
                        elseif findstr(roi(i).shape,'polygon')>0
                            roi(i).handle=impoly(gca,roi(i).coord);
                            if findstr(roi(i).clude,'include')
                                setColor(roi(i).handle,'g')
                            else
                                setColor(roi(i).handle,'r')
                            end
                        elseif findstr(roi(i).shape,'ellipse')>0
                            roi(i).handle=imellipse(gca,[roi(i).coord(1), roi(i).coord(2), roi(i).coord(3), roi(i).coord(4)]);
                            if findstr(roi(i).clude,'include')
                                setColor(roi(i).handle,'g')
                            else
                                setColor(roi(i).handle,'r')
                            end
                        elseif findstr(roi(i).shape,'point')>0
                            roi(i).handle=impoint(gca,[roi(i).coord(1), roi(i).coord(2)]);
                            if findstr(roi(i).clude,'include')
                                setColor(roi(i).handle,'g')
                            else
                                setColor(roi(i).handle,'r')
                            end
                        end
                    end
                elseif findstr(roi(i).shape,'point')>0
                    if (Xaxis=='PosX')&(Yaxis=='PosY')
                        if (roi(i).Xaxis=='PosX')&(roi(i).Yaxis=='PosZ')
                            roi(i).handle=impoint(gca,[roi(i).coord(1), handles.field.PosY(roi(i).height,1,1)]);
                        elseif (roi(i).Xaxis=='PosY')&(roi(i).Yaxis=='PosZ')
                            roi(i).handle=impoint(gca,[handles.field.PosX(1,roi(i).height,1), roi(i).coord(1)]);
                        end
                    elseif (Xaxis=='PosX')&(Yaxis=='PosZ')
                        if (roi(i).Xaxis=='PosX')&(roi(i).Yaxis=='PosZ')
                            roi(i).handle=impoint(gca,[handles.field.PosX(1,roi(i).height), roi(i).coord(2)]);
                        elseif (roi(i).Xaxis=='PosX')&(roi(i).Yaxis=='PosY')
                            roi(i).handle=impoint(gca,[roi(i).coord(1), handles.field.PosZ(1,1,roi(i).height)]);
                        end
                    elseif (Xaxis=='PosY')&(Yaxis=='PosZ')
                        if (roi(i).Xaxis=='PosX')&(roi(i).Yaxis=='PosZ')
                            roi(i).handle=impoint(gca,[handles.field.PosY(roi(i).height,1,1), roi(i).coord(2)]);
                        elseif (roi(i).Xaxis=='PosX')&(roi(i).Yaxis=='PosY')
                            roi(i).handle=impoint(gca,[roi(i).coord(2), handles.field.PosZ(1,1,roi(i).height)]);
                        end
                    end
                end
            end
        end
    end
    axis equal tight
end

% function to import data for MHData_load_maskfile
function [field,procdata]=import_data(procdata,filename,pathname)
    fprintf('%s',filename)
    fprintf('%s',pathname)
    l=length(pathname);
    %if pahtname doesn't end in backslash
    if ispc
        if pathname(l)~='\' % windows 
            pathname(l+1)='\';
        end
    elseif isunix
        if pathname(l)~='/' % linux
            pathname(l+1)='/';
        end
    end
    if findstr(procdata.data_type,'DIC')>0
        if findstr(procdata.dic_type,'2D')>0
            dat_check=findstr(filename,'.dat');
            vc7_check=findstr(filename,'.vc7');
            if dat_check~=0 %if file is a dat file then use getDICdata to obtain data
                fprintf('~ Loading dataset %s ...',filename);
                field_got=getDICdata(pathname,filename);
                fprintf('done\n',filename);
                %store data in 'handles' variable
                field=field_got;
                procdata.zheight=1;
                procdata.xheight=1;
                procdata.yheight=1;
            elseif vc7_check>0 %if file is a vc7 file
                fprintf('~ Loading dataset %s ...',filename);
                [field_got,useless_field]=getVC7data2D(filename,pathname);
                fprintf('done\n',filename);
                field.PosX=field_got.POSX;
                field.PosY=field_got.POSY;
                field.PosZ=field_got.POSZ;
                field.uX=field_got.UX;
                field.uY=field_got.UY;
                %create a matrix of zeros for uZ since no uZ data will be available in the VC7 file
                [r,c]=size(field.uX);
                field.uZ=zeros(r,c);
                procdata.zheight=1;
                procdata.xheight=1;
                procdata.yheight=1;
            end
        elseif findstr(procdata.dic_type,'3D');
            dat_check=findstr(filename,'.dat');
            vc7_check=findstr(filename,'.vc7');
            if dat_check~=0 %if file is a dat file then use getDICdata to obtain data
                fprintf('~ Loading dataset %s ...',filename);
                field=getDICdata(pathname,filename);
                fprintf('done\n',filename);
                procdata.zheight=1;
                procdata.xheight=1;
                procdata.yheight=1;
            elseif vc7_check>0 %if file is a vc7 file
                fprintf('~ Loading dataset %s ...',filename);
                [field_got,useless_field]=getVC7data(filename,pathname);
                fprintf('done\n',filename);
                field.PosX=field_got.POSX;
                field.PosY=field_got.POSY;
                field.PosZ=field_got.POSZ;
                field.uX=field_got.UX;
                field.uY=field_got.UY;
                field.uZ=field_got.UZ;
                procdata.zheight=1;
                procdata.xheight=1;
                procdata.yheight=1;
            end
        end
    elseif findstr(procdata.data_type,'DVC')>0
        dat_check=findstr(filename,'.dat');
        vc7_check=findstr(filename,'.vc7');
        if dat_check~=0
            fprintf('~ Loading dataset %s ...',filename);
            [field,gridspacing]=getDVCdata6(filename,pathname);
            fprintf('done\n',filename);
            procdata.zheight=floor(max(size(field.uY(1,1,:)))/2);
            procdata.xheight=floor(max(size(field.uY(1,:,1)))/2);
            procdata.yheight=floor(max(size(field.uY(:,1,1)))/2);
            procdata.zmax=max(size(field.uY(1,1,:)));
            procdata.xmax=max(size(field.uY(1,:,1)));
            procdata.ymax=max(size(field.uY(:,1,1)));
            fprintf('Rearanging the DVC data for display purposes...')
            field.PosX_c=Correct_DVC_data(field.PosX);
            field.PosY_c=Correct_DVC_data(field.PosY);
            field.PosZ_c=Correct_DVC_data(field.PosZ);
            field.uX_c=Correct_DVC_data(field.uX);
            field.uY_c=Correct_DVC_data(field.uY);
            field.uZ_c=Correct_DVC_data(field.uZ);
            fprintf('done\n')
        elseif vc7_check~=0
            fprintf('~ Loading dataset %s ...',filename);
            [field_got,useless_field]=getVC7data(filename,pathname);
            fprintf('done\n',filename);
            field.PosX=field_got.POSX;
            field.PosY=field_got.POSY;
            field.PosZ=field_got.POSZ;
            field.uX=field_got.UX;
            field.uY=field_got.UY;
            field.uZ=field_got.UZ;
            procdata.zheight=floor(max(size(field_got.UY(1,1,:)))/2);
            procdata.xheight=floor(max(size(field_got.UY(1,:,1)))/2);
            procdata.yheight=floor(max(size(field_got.UY(:,1,1)))/2);
            procdata.zmax=max(size(field_got.UY(1,1,:)));
            procdata.xmax=max(size(field_got.UY(1,:,1)));
            procdata.ymax=max(size(field_got.UY(:,1,1)));
            fprintf('Rearanging the DVC data for display purposes...')
            field.PosX_c=Correct_DVC_data(field.PosX);
            field.PosY_c=Correct_DVC_data(field.PosY);
            field.PosZ_c=Correct_DVC_data(field.PosZ);
            field.uX_c=Correct_DVC_data(field.uX);
            field.uY_c=Correct_DVC_data(field.uY);
            field.uZ_c=Correct_DVC_data(field.uZ);
            fprintf('done\n')
        end
    elseif findstr(procdata.data_type,'FEM')>0
        fullfilename=strcat(pathname,filename);
        idmask=[nan,nan,nan,nan,nan,nan];
        fprintf('~ Loading dataset %s ...\n',filename);
        [fieldfem,crackfem] = getFEMdata7(fullfilename,1,idmask);
        fprintf('done\n',filename);
        field.PosX=fieldfem.POSX;
        field.PosY=fieldfem.POSY;
        field.PosZ=fieldfem.POSZ;
        field.uX=fieldfem.UX;
        field.uY=fieldfem.UY;
        field.uZ=fieldfem.UZ;
    end
end

function [roi,roicount]=handles2roi(handles)
    for i=1:handles.procdata.current
        roi(i)=handles.procdata.op(i);
    end
    roicount=handles.procdata.current;
end

function [handles]=roi2handles(roi,roicount)
    for i=1:roicount
        handles.procdata.op(i)=roi(i);
    end
    handles.procdata.current=roicount;
end

% function to convert processed data to vectors indicating the outline of the valid data
function [out]=mask2outline(field,handles)
    if handles.procdata.data_type=='DIC'
        [r,c]=size(field.uX);
        Valid=~isnan(field.uX);

        outline=zeros(r,c);
        count=1;
        for i=1:r
            for j=1:c
                if Valid(i,j)==1
                    if (i>1)&(j>1)&(i<r)&(j<c)
                        if (Valid(i-1,j)==0)|(Valid(i+1,j)==0)|(Valid(i,j-1)==0)|(Valid(i,j+1)==0) 
                            outline(i,j)=1;
                            starting_point=[i,j];
                            v(count,1)=i;
                            v(count,2)=j;
                            count=count+1;
                        end
                    else
                        outline(i,j)=1;
                        starting_point=[i,j];
                        v(count,1)=i;
                        v(count,2)=j;
                        count=count+1
                    end
                end
            end
        end

    elseif handles.procdata.data_type=='DVC'
    end
end

% Function to create an alternative way for storing the DVC data so that it can be displayed correctly
function [out]=Correct_DVC_data(it)
    [y_size,x_size,z_size]=size(it);
    out=zeros(z_size,y_size,x_size);
    for i=1:z_size
        out(i,:,:)=it(:,:,i);
    end
end

%ISSUES:
% use global variclude to save information about operations to perform - better way?
% should the axis display columns and rows or x and y positions (edit data according to columns and rows or x/y positions or given an option?)
% what does ref point do/what is it used for
% difference between mask and region of interest
% only crop rectangularly?
% does crop delete the unwanted area and reduce the matrix size
% should the file used to run the backend be a text file or a mat file containing the procdata (then fields can be stored in same file)
% should the dic data be saved as vectors or matrices (field standardised structure?)
% how does masking for dvc work. If in 3d does the mask get applied to each plane? different mask on each plane as travel in a direction thorugh 3d data?
% how work with 3d data (FEM and DVC) -should you choose what each axes displays and the value it shows
% should the program output helpful messages to the command window based on actions taken?
% is im7 the images from the camera and vc7 the processed displacement fields? Need to read im7?
% Matt's importing method seems to shift the Pos data, is that ok?
% currently only able include/exclude (and mask range for DVC) when mask shape is created, not thereafter - is that ok?
% should everything be commented?
% RBM for DIC causes zero data surrounding the actual data to take on a gradient (no longer all zero)
% what does MHOptions_Set do?
% reference point to closest data point or can it be independent of data points? (or both options?)
% cant change masks once execute a callback that doesn't mask




%TO DO
% importing vc7 data - make addpath more dynamic so that it is independent of computer it is used on. + add a warning if fails at this point
% ref point can always be displayed regardless of orientation - take height out of its callback

% fundemental issues
% once you start a new mask in gui you can no longer edit other mask created before although you can drag them
% if you change orientation then the masks will be set