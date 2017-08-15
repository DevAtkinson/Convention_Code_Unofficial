function display_operations(procdata_in)
	% this function displays the data and masks associated with a GUI output file (.mat) or variables (procdata).
	if ischar(procdata_in) %if procdata_in is a file
		warning off
		load(procdata_in)
		close all
		warning on
	else
		procdata=procdata_in;
	end
	scrsz = get(0,'ScreenSize');
	if procdata.data_type=='DIC'
		handles.fig = figure('MenuBar','None','Position',[(scrsz(3)-300)/2 (scrsz(4)-600)/2 900 600]);
		set(handles.fig, 'Name', 'Dipslay operations');
		axes1=axes('Parent',handles.fig,'Layer' ,'Top','Units','pixels','Position',[70,70,450,450]);

		box(axes1,'on');
		axis(axes1,'tight');
		axis(axes1,'equal');
		set(axes1,'DataAspectRatio',[1 1 1],'Layer','top');
		Z = peaks(51);
		imghandle = imagesc(Z,'Parent',axes1);

		[field,procdata]=import_data(procdata,procdata.filename,procdata.pathname);
		field_save=field;
		for i=1:procdata.current
			string{i}=sprintf('%d %s %s %s', i, procdata.op(i).act,procdata.op(i).shape,procdata.op(i).clude);
		end
		lb=uicontrol('Style','listbox','Max',5,'Min',0,'string',string,'Position',[550,15,200,450],'Callback',@update_fig);
		uicontrol('Style','text','string','Use ctrl to select multiple operations:','Position',[550,470,200,20]);
		ch_mask=uicontrol('Style','checkbox','String','Display masks','Position',[550,500,200,20],'Callback',@update_fig);
		% ch_data=uicontrol('Style','checkbox','string','Display processed data','Position',[550,530,200,20],'Callback',@update_fig);
	elseif procdata.data_type=='DVC'
		handles.fig = figure('MenuBar','None','Position',[(scrsz(3)-300)/2 (scrsz(4)-600)/2 800 800]);
		set(handles.fig, 'Name', 'Display operations');
		axes1=axes('Parent',handles.fig,'Layer' ,'Top','Units','pixels','Position',[90,70,300,300]);
		axes2=axes('Parent',handles.fig,'Layer' ,'Top','Units','pixels','Position',[90,440,300,300]);
		axes3=axes('Parent',handles.fig,'Layer' ,'Top','Units','pixels','Position',[480,440,300,300]);
		[field,procdata]=import_data(procdata,procdata.filename,procdata.pathname);
		field_backup=field;
		for i=1:procdata.current
			string{i}=sprintf('%d %s %s %s', i, procdata.op(i).act,procdata.op(i).shape,procdata.op(i).clude);
		end
		lb=uicontrol('Style','listbox','Max',5,'Min',0,'string',string,'Position',[550,15,200,260],'Callback',@update_fig);
		uicontrol('Style','text','string','Use ctrl to select multiple operations:','Position',[550,300,200,20]);
		ch_mask=uicontrol('Style','checkbox','String','Display masks','Position',[550,330,200,20],'Callback',@update_fig);
		% ch_data=uicontrol('Style','checkbox','string','Display processed data','Position',[550,350,200,20],'Callback',@update_fig);

		slider_xy=uicontrol('Style','slider','Position',[20,70,20,300],'min',1,'max',procdata.zmax,'Value',procdata.zheight,'Callback',@Slider_callback_xy);
        textbox_xy=uicontrol('Style','text','Position',[5,50,60,20],'String',num2str(field.POSZ(1,1,procdata.zheight)),'ToolTipString',sprintf('The currently viewed plane''s value'));
        textbox2_xy=uicontrol('Style','text','Position',[5,30,60,20],'String',sprintf('%d/%d',procdata.zheight,procdata.zmax),'ToolTipString',sprintf('The currently viewed plane out of how many panes exist in this direction'));
        set(slider_xy,'SliderStep',[1 1]/(procdata.zmax-1));

        slider_xz=uicontrol('Style','slider','Position',[20,440,20,300],'min',1,'max',procdata.ymax,'Value',procdata.yheight,'Callback',@Slider_callback_xz);
        textbox_xz=uicontrol('Style','text','Position',[5,420,60,20],'String',num2str(field.POSY(procdata.yheight,1,1)),'ToolTipString',sprintf('The currently viewed plane''s value'));
        textbox2_xz=uicontrol('Style','text','Position',[5,400,60,20],'String',sprintf('%d/%d',procdata.yheight,procdata.ymax),'ToolTipString',sprintf('The currently viewed plane out of how many panes exist in this direction'));
        set(slider_xz,'SliderStep',[1 1]/(procdata.ymax-1));

        slider_yz=uicontrol('Style','slider','Position',[410,440,20,300],'min',1,'max',procdata.xmax,'Value',procdata.xheight,'Callback',@Slider_callback_yz);
        textbox_yz=uicontrol('Style','text','Position',[395,420,60,20],'String',num2str(field.POSX(1,procdata.xheight,1)),'ToolTipString',sprintf('The currently viewed plane''s value'));
        textbox2_yz=uicontrol('Style','text','Position',[395,400,60,20],'String',sprintf('%d/%d',procdata.xheight,procdata.xmax),'ToolTipString',sprintf('The currently viewed plane out of how many panes exist in this direction'));
        set(slider_yz,'SliderStep',[1 1]/(procdata.xmax-1));

        %create a locked version of the heights so that they can be readjusted in the case of cropping
        procdata.yheight_locked=procdata.yheight;
        procdata.xheight_locked=procdata.xheight;
        procdata.zheight_locked=procdata.zheight;
        procdata.crop.yprev=0;
		procdata.crop.xprev=0;
		procdata.crop.zprev=0;
	end

	%function to allow the slider to change the height viewed with regards to DVC data in xy plane
	function Slider_callback_xy(hObject,eventdata,handles)
	    handles=guidata(hObject);
	    value=floor(get(slider_xy,'Value'));
        procdata.zheight=value;
        set(textbox_xy,'string',num2str(field.POSZ(1,1,value)));
        set(textbox2_xy,'string',sprintf('%d/%d',procdata.zheight,procdata.zmax));
	    update_fig(hObject,eventdata,handles)
	    guidata(hObject, handles);
	end

	%function to allow the slider to change the height viewed with regards to DVC data in xz plane
	function Slider_callback_xz(hObject,eventdata,handles)
	    handles=guidata(hObject);
	    check_val=get(slider_xz,'value')
	    value=floor(get(slider_xz,'Value'));
        procdata.yheight=value;
        set(textbox_xz,'string',num2str(field.POSY(value,1,1)));
        set(textbox2_xz,'string',sprintf('%d/%d',procdata.yheight,procdata.ymax));
	    update_fig(hObject,eventdata,handles)
	    guidata(hObject, handles);
	end

	%function to allow the slider to change the height viewed with regards to DVC data in yz plane
	function Slider_callback_yz(hObject,eventdata,handles)
	    handles=guidata(hObject);
	    value=floor(get(slider_yz,'Value'));
        procdata.xheight=value;
        set(textbox_yz,'string',num2str(field.POSX(1,value,1)));
        set(textbox2_yz,'string',sprintf('%d/%d',procdata.xheight,procdata.xmax));
	    update_fig(hObject,eventdata,handles)
	    guidata(hObject, handles);
	end

	% this function updates the figures to display the data with the selected options
	function update_fig(hObject,eventdata,handles)
		if procdata.data_type=='DIC'
			cla
		elseif procdata.data_type=='DVC'
			cla(axes1)
			cla(axes2)
			cla(axes3)
		end
		handles=guidata(hObject);
		values=get(lb,'Value');
		mask_check=get(ch_mask,'Value');
		% data_check=get(ch_data,'Value');

		for i=1:procdata.current
			if sum(values==i)
				does(i)=1;
			else
				does(i)=0;
			end
		end
		does2=ones(length(does));
		% field_backup=field;
		field=field_format(procdata,'which operations',does);
		%adjust the heights in the case of cropping
		if field.crop.check=='y'
			procdata.yheight=procdata.yheight-field.crop.y+procdata.crop.yprev;
			procdata.xheight=procdata.xheight-field.crop.x+procdata.crop.xprev;
			procdata.zheight=procdata.zheight-field.crop.z+procdata.crop.zprev;
			procdata.crop.yprev=field.crop.y;
			procdata.crop.xprev=field.crop.x;
			procdata.crop.zprev=field.crop.z;
			[y_size,x_size,z_size]=size(field.POSX);
			procdata.zmax=z_size;
			procdata.ymax=y_size;
			procdata.xmax=x_size;
			if procdata.yheight<1
				procdata.yheight=1;
			elseif procdata.yheight>y_size
				procdata.yheight=y_size;
			end
			if procdata.xheight<1
				procdata.xheight=1;
			elseif procdata.xheight>x_size
				procdata.xheight=x_size;
			end
			if procdata.zheight<1
				procdata.zheight=1;
			elseif procdata.zheight>z_size
				procdata.zheight=z_size;				
			end
			set(textbox2_xy,'string',sprintf('%d/%d',procdata.zheight,procdata.zmax))
			set(textbox2_xz,'string',sprintf('%d/%d',procdata.yheight,procdata.ymax))
			set(textbox2_yz,'string',sprintf('%d/%d',procdata.xheight,procdata.xmax))

			x_current=get(slider_yz,'value');
			y_current=get(slider_xz,'value');
			z_current=get(slider_xy,'value');

			set(slider_yz,'value',procdata.xheight,'max',x_size,'Sliderstep',[1/(x_size-1) 1/(x_size-1)])
			set(textbox_yz,'String',num2str(field.POSX(1,procdata.xheight,1)))
			set(slider_xz,'value',procdata.yheight,'max',y_size,'SliderStep',[1/(y_size-1) 1/(y_size-1)])
			set(textbox_xz,'String',num2str(field.POSY(procdata.yheight,1,1)))
			set(slider_xy,'value',procdata.zheight,'max',z_size,'SliderStep',[1/(z_size-1) 1/(z_size-1)])
			set(textbox_xy,'String',num2str(field.POSZ(1,1,procdata.zheight)))
		else % if no cropping is applied correct changes made for cropping
			procdata.yheight=procdata.yheight+procdata.crop.yprev;
			procdata.xheight=procdata.xheight+procdata.crop.xprev;
			procdata.zheight=procdata.zheight+procdata.crop.zprev;
			procdata.crop.yprev=0;
			procdata.crop.xprev=0;
			procdata.crop.zprev=0;
			[y_size,x_size,z_size]=size(field.POSX);
			procdata.zmax=z_size;
			procdata.ymax=y_size;
			procdata.xmax=x_size;
			if procdata.yheight<1
				procdata.yheight=1;
			elseif procdata.yheight>y_size
				procdata.yheight=y_size;
			end
			if procdata.xheight<1
				procdata.xheight=1;
			elseif procdata.xheight>x_size
				procdata.xheight=x_size;
			end
			if procdata.zheight<1
				procdata.zheight=1;
			elseif procdata.zheight>z_size
				procdata.zheight=z_size;				
			end
			set(textbox2_xy,'string',sprintf('%d/%d',procdata.zheight,procdata.zmax))
			set(textbox2_xz,'string',sprintf('%d/%d',procdata.yheight,procdata.ymax))
			set(textbox2_yz,'string',sprintf('%d/%d',procdata.xheight,procdata.xmax))

			x_current=get(slider_yz,'value');
			y_current=get(slider_xz,'value');
			z_current=get(slider_xy,'value');

			set(slider_yz,'value',procdata.xheight,'max',x_size,'Sliderstep',[1/(x_size-1) 1/(x_size-1)])
			set(textbox_yz,'String',num2str(field.POSX(1,procdata.xheight,1)))
			set(slider_xz,'value',procdata.yheight,'max',y_size,'SliderStep',[1/(y_size-1) 1/(y_size-1)])
			set(textbox_xz,'String',num2str(field.POSY(procdata.yheight,1,1)))
			set(slider_xy,'value',procdata.zheight,'max',z_size,'SliderStep',[1/(z_size-1) 1/(z_size-1)])
			set(textbox_xy,'String',num2str(field.POSZ(1,1,procdata.zheight)))
		end
		
		if procdata.data_type=='DVC'
			fprintf('Rearanging the DVC data for display purposes...')
	        field.POSX_c=Correct_DVC_data(field.POSX);
	        field.POSY_c=Correct_DVC_data(field.POSY);
	        field.POSZ_c=Correct_DVC_data(field.POSZ);
	        field.UX_c=Correct_DVC_data(field.UX);
	        field.UY_c=Correct_DVC_data(field.UY);
	        field.UZ_c=Correct_DVC_data(field.UZ);
	        fprintf('done\n')
	        field.POSX_locked=field_backup.POSX_locked;
	        field.POSY_locked=field_backup.POSY_locked;
	        field.POSZ_locked=field_backup.POSZ_locked;
	    end
	    display_on_axes(procdata,field,does,axes2,'PosX','PosZ',procdata.yheight,mask_check,'uY')
		display_on_axes(procdata,field,does,axes1,'PosX','PosY',procdata.zheight,mask_check,'uY')
		display_on_axes(procdata,field,does,axes3,'PosY','PosZ',procdata.xheight,mask_check,'uY')
		
		guidata(hObject, handles);
	end
end

% this function is used to import the data
function [field,procdata]=import_data(procdata,filename,pathname)
	l=length(pathname);
	%if pahtname doesn't end in backslash
	if pathname(l)~='\' % assuming windows 
		pahtname(l+1)='\';
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
		        field.POSX=field_got.POSX;
		        field.POSY=field_got.POSY;
		        field.POSZ=field_got.POSZ;
		        field.UX=field_got.UX;
		        field.UY=field_got.UY;
		        %create a matrix of zeros for uZ since no uZ data will be available in the VC7 file
		        [r,c]=size(field.UX);
		        field.UZ=zeros(r,c);
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
		        field.POSX=field_got.POSX;
		        field.POSY=field_got.POSY;
		        field.POSZ=field_got.POSZ;
		        field.UX=field_got.UX;
		        field.UY=field_got.UY;
		        field.UZ=field_got.UZ;
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
	        field.UX=field.uX;
	        field.UY=field.uY;
	        field.UZ=field.uZ;
	        field.POSX=field.PosX;
	        field.POSY=field.PosY;
	        field.POSZ=field.PosZ;
	        fprintf('Rearanging the DVC data for display purposes...')
            field.POSX_c=Correct_DVC_data(field.PosX);
            field.POSY_c=Correct_DVC_data(field.PosY);
            field.POSZ_c=Correct_DVC_data(field.PosZ);
            field.UX_c=Correct_DVC_data(field.uX);
            field.UY_c=Correct_DVC_data(field.uY);
            field.UZ_c=Correct_DVC_data(field.uZ);

            fprintf('done\n')

            field.POSX_locked=field.POSX;
            field.POSY_locked=field.POSY;
            field.POSZ_locked=field.POSZ;

			procdata.zheight=floor(max(size(field.uY(1,1,:)))/2);
			procdata.xheight=floor(max(size(field.uY(1,:,1)))/2);
			procdata.yheight=floor(max(size(field.uY(:,1,1)))/2);
			procdata.zmax=max(size(field.uY(1,1,:)));
			procdata.xmax=max(size(field.uY(1,:,1)));
			procdata.ymax=max(size(field.uY(:,1,1)));
	    elseif vc7_check~=0
	        fprintf('~ Loading dataset %s ...',filename);
	        [field_got,useless_field]=getVC7data(filename,pathname);
	        fprintf('done\n',filename);

	        fprintf('Rearanging the DVC data for display purposes...')
            field.POSX_c=Correct_DVC_data(field_got.POSX);
            field.POSY_c=Correct_DVC_data(field_got.POSY);
            field.POSZ_c=Correct_DVC_data(field_got.POSZ);
            field.UX_c=Correct_DVC_data(field_got.UX);
            field.UY_c=Correct_DVC_data(field_got.UY);
            field.UZ_c=Correct_DVC_data(field_got.UZ);

            fprintf('done\n')

            field.POSX=field_got.POSX;
	        field.POSY=field_got.POSY;
	        field.POSZ=field_got.POSZ;
	        field.UX=field_got.UX;
	        field.UY=field_got.UY;
	        field.UZ=field_got.UZ;
	        %created fields that will not be changed by ref points so they can be used to correct the masks when ref points are applied
	        field.POSX_locked=field.POSX;
            field.POSY_locked=field.POSY;
            field.POSZ_locked=field.POSZ;

	        procdata.zheight=floor(max(size(field_got.UY(1,1,:)))/2);
	        procdata.xheight=floor(max(size(field_got.UY(1,:,1)))/2);
	        procdata.yheight=floor(max(size(field_got.UY(:,1,1)))/2);
	        procdata.zmax=max(size(field_got.UY(1,1,:)));
	        procdata.xmax=max(size(field_got.UY(1,:,1)));
	        procdata.ymax=max(size(field_got.UY(:,1,1)));
	    end
	elseif findstr(procdata.data_type,'FEM')>0
	    fullfilename=strcat(pathname,filename);
	    idmask=[nan,nan,nan,nan,nan,nan];
	    fprintf('~ Loading dataset %s ...\n',filename);
	    [fieldfem,crackfem] = getFEMdata7(fullfilename,1,idmask);
	    fprintf('done\n',filename);
	    field.POSX=fieldfem.POSX;
	    field.POSY=fieldfem.POSY;
	    field.POSZ=fieldfem.POSZ;
	    field.UX=fieldfem.UX;
	    field.UY=fieldfem.UY;
	    field.UZ=fieldfem.UZ;
	end
end