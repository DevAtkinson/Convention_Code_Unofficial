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
		ch_data=uicontrol('Style','checkbox','string','Display processed data','Position',[550,530,200,20],'Callback',@update_fig);
	elseif procdata.data_type=='DVC'
		handles.fig = figure('MenuBar','None','Position',[(scrsz(3)-300)/2 (scrsz(4)-600)/2 800 800]);
		set(handles.fig, 'Name', 'Display operations');
		axes1=axes('Parent',handles.fig,'Layer' ,'Top','Units','pixels','Position',[90,70,300,300]);
		axes2=axes('Parent',handles.fig,'Layer' ,'Top','Units','pixels','Position',[90,440,300,300]);
		axes3=axes('Parent',handles.fig,'Layer' ,'Top','Units','pixels','Position',[480,440,300,300]);
		[field,procdata]=import_data(procdata,procdata.filename,procdata.pathname);
		field_save=field;
		for i=1:procdata.current
			string{i}=sprintf('%d %s %s %s', i, procdata.op(i).act,procdata.op(i).shape,procdata.op(i).clude);
		end
		lb=uicontrol('Style','listbox','Max',5,'Min',0,'string',string,'Position',[550,15,200,260],'Callback',@update_fig);
		uicontrol('Style','text','string','Use ctrl to select multiple operations:','Position',[550,300,200,20]);
		ch_mask=uicontrol('Style','checkbox','String','Display masks','Position',[550,330,200,20],'Callback',@update_fig);
		ch_data=uicontrol('Style','checkbox','string','Display processed data','Position',[550,350,200,20],'Callback',@update_fig);

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
        set(textbox2_xy,'string',sprintf('%d/%d',procdata.zheight,procdata.zmax))
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
        set(textbox2_xz,'string',sprintf('%d/%d',procdata.yheight,procdata.ymax))
	    update_fig(hObject,eventdata,handles)
	    guidata(hObject, handles);
	end

	%function to allow the slider to change the height viewed with regards to DVC data in yz plane
	function Slider_callback_yz(hObject,eventdata,handles)
	    handles=guidata(hObject);
	    value=floor(get(slider_yz,'Value'));
        procdata.xheight=value;
        set(textbox_yz,'string',num2str(field.POSX(1,value,1)));
        set(textbox2_yz,'string',sprintf('%d/%d',procdata.xheight,procdata.xmax))
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
		data_check=get(ch_data,'Value');
		% values_length=length(values);
		% length(handles.values)
		% for i=1:length(handles.values)
		% 	values(i+values_length)=handles.values(i);
		% end
		for i=1:procdata.current
			if sum(values==i)
				does(i)=1;
			else
				does(i)=0;
			end
		end
		does2=ones(length(does));
		field_backup=field;
		if data_check==1
			field=field_format(procdata,'which operations',does);
			%adjust the heights in the case of cropping
			if field.crop.check=='y'
				fprintf('it thinks there is cropping')
				xval1=procdata.yheight
				% procdata.yheight=procdata.yheight_locked-field.crop.y;
				% procdata.xheight=procdata.xheight_locked-field.crop.x;
				% procdata.zheight=procdata.zheight_locked-field.crop.z;
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
				xval2=procdata.yheight
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
				xval3=procdata.yheight
				% set(slider_xy,'value',procdata.zheight,'max',z_size)
				% set(slider_xz,'value',procdata.yheight,'max',y_size)
				% set(slider_yz,'value',procdata.xheight,'max',x_size)
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


				% if x_current>x_size
				% 	set(slider_yz,'value',procdata.xheight,'max',x_size,'Sliderstep',[1/(x_size-1) 1])
				% 	set(textbox_yz,'String',num2str(field.POSX(1,procdata.xheight,1)))
				% else
				% 	set(slider_yz,'max',x_size,'Sliderstep',[1/(x_size-1) 1])
				% 	set(textbox_yz,'String',num2str(field.POSX(1,procdata.xheight,1)))
				% end
				% if y_current>y_size
				% 	set(slider_xz,'value',procdata.yheight,'max',y_size,'SliderStep',[1/(y_size-1) 1])
				% 	set(textbox_xz,'String',num2str(field.POSY(procdata.yheight,1,1)))
				% else
				% 	set(slider_xz,'max',y_size,'SliderStep',[1/(y_size-1) 1])
				% 	set(textbox_xz,'String',num2str(field.POSY(procdata.yheight,1,1)))
				% end
				% if z_current>z_size
				% 	set(slider_xy,'value',procdata.zheight,'max',z_size,'SliderStep',[1/(z_size-1) 1])
				% 	set(textbox_xy,'String',num2str(field.POSZ(1,1,procdata.zheight)))
				% else
				% 	set(slider_xy,'max',z_size,'SliderStep',[1/(z_size-1) 1])
				% 	set(textbox_xy,'String',num2str(field.POSZ(1,1,procdata.zheight)))
				% end


				% set(slider_xy,'max',z_size)
				% set(slider_xz,'max',y_size)
				% set(slider_yz,'max',x_size)
				% set(textbox2_xy,'string',sprintf('%d/%d',procdata.zheight,procdata.zmax))
				% set(textbox2_xz,'string',sprintf('%d/%d',procdata.yheight,procdata.ymax))
				% set(textbox2_yz,'string',sprintf('%d/%d',procdata.xheight,procdata.xmax))
				xval4=procdata.yheight
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
				xval2=procdata.yheight
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
				xval3=procdata.yheight
				% set(slider_xy,'value',procdata.zheight,'max',z_size)
				% set(slider_xz,'value',procdata.yheight,'max',y_size)
				% set(slider_yz,'value',procdata.xheight,'max',x_size)
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
		else
			field=field_save;
			%not sure if these are applicable here
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

				set(slider_yz,'value',procdata.xheight,'max',x_size,'Sliderstep',[1/(x_size-1) 1])
				set(textbox_yz,'String',num2str(field.POSX(1,procdata.xheight,1)))
				set(slider_xz,'value',procdata.yheight,'max',y_size,'SliderStep',[1/(y_size-1) 1])
				set(textbox_xz,'String',num2str(field.POSY(procdata.yheight,1,1)))
				set(slider_xy,'value',procdata.zheight,'max',z_size,'SliderStep',[1/(z_size-1) 1])
				set(textbox_xy,'String',num2str(field.POSZ(1,1,procdata.zheight)))
			end
		end
		if procdata.data_type=='DVC'
			fprintf('Rearanging the DVC data for display purposes...')
	        field.POSX_c=Correct_DVC_data(field.PosX);
	        field.POSY_c=Correct_DVC_data(field.PosY);
	        field.POSZ_c=Correct_DVC_data(field.PosZ);
	        field.UX_c=Correct_DVC_data(field.uX);
	        field.UY_c=Correct_DVC_data(field.uY);
	        field.UZ_c=Correct_DVC_data(field.uZ);
	        fprintf('done\n')
	        field.POSX_locked=field_backup.POSX_locked;
	        field.POSY_locked=field_backup.POSY_locked;
	        field.POSZ_locked=field_backup.POSZ_locked;
	    end

		% axes(axes1)
		if procdata.data_type=='DIC'
			% hAxes = findobj(gcf, 'type' ,'axes');
	        x_tick=sort([field.POSX(1,1),field.POSX(1,end)]);
	        y_tick=sort([field.POSY(1,1),field.POSY(end,1)]);
	        p=procdata;
	        p.which_operations=does;
	        if data_check==1
	        	p=update_masks_from_ref_point(p,field);
	        end
	        switch procdata.Contour
	            case 'uX'
	            	axes(axes1)
	                imghandle =imagesc(x_tick,y_tick,field.UX);
	                title('uX')
	            case 'uY'
	            	axes(axes1)
	                imghandle =imagesc(x_tick,y_tick,field.UY);
	                title('uY')
	            case 'uZ'
	            	axes(axes1)
	                imghandle =imagesc(x_tick,y_tick,field.UZ);
	                title('uZ')
	        end
	        set(axes1,'YDir','normal')
	        xlabel('PosX')
	        ylabel('PosY')
	        axis equal tight
	        if mask_check==1
		        for i=1:procdata.current
		        	if does(i)==1
			            if findstr(p.op(i).shape,'rectangle')>0
			                p.op(i).handle=imrect(axes1,[p.op(i).coord(1), p.op(i).coord(2), p.op(i).coord(3), p.op(i).coord(4)]);
			                if findstr(p.op(i).clude,'include')
			                    setColor(p.op(i).handle,'g')
			                else
			                    setColor(p.op(i).handle,'r')
			                end
			            elseif findstr(p.op(i).shape,'polygon')>0
			                p.op(i).handle=impoly(axes1,p.op(i).coord);
			                if findstr(p.op(i).clude,'include')
			                    setColor(p.op(i).handle,'g')
			                else
			                    setColor(p.op(i).handle,'r')
			                end
			            elseif findstr(p.op(i).shape,'ellipse')>0
			                p.op(i).handle=imellipse(axes1,[p.op(i).coord(1), p.op(i).coord(2), p.op(i).coord(3), p.op(i).coord(4)]);
			                if findstr(p.op(i).clude,'include')
			                    setColor(p.op(i).handle,'g')
			                else
			                    setColor(p.op(i).handle,'r')
			                end
			            elseif findstr(p.op(i).shape,'point')>0
			                p.op(i).handle=impoint(axes1,[p.op(i).coord(1), p.op(i).coord(2)]);
			                if findstr(p.op(i).clude,'include')
			                    setColor(p.op(i).handle,'g')
			                else
			                    setColor(p.op(i).handle,'r')
			                end
			            end
			        end
			    end
			end
	    elseif procdata.data_type=='DVC'
            x_tick=sort([field.POSX(1,1,1),field.POSX(1,end,1)]);
            y_tick=sort([field.POSY(1,1,1),field.POSY(end,1,1)]);
            p=procdata;
	        p.which_operations=does;
            if data_check==1
	        	p=update_masks_from_ref_point(p,field);
	        end
            axes(axes1)
            switch procdata.Contour
                case 'uX'
                    disp1(:,:)=squeeze(field.UX(:,:,procdata.zheight));
                    imghandle =imagesc(x_tick,y_tick,disp1);
                case 'uY'
                    disp1(:,:)=squeeze(field.UY(:,:,procdata.zheight));
                    imghandle =imagesc(x_tick,y_tick,disp1);
                case 'uZ'
                    disp1(:,:)=squeeze(field.UZ(:,:,procdata.zheight));
                    imghandle =imagesc(x_tick,y_tick,disp1);
            end
            x_tick=sort([field.POSX(1,1,1),field.POSX(1,end,1)]);
            y_tick=sort([field.POSZ(1,1,1),field.POSZ(1,1,end)]);
			set(gca,'YDir','normal')
	        title(procdata.Contour)
	        xlabel('PosX')
	        ylabel('PosY')
	        axes(axes2)
            switch procdata.Contour
                case 'uX'
                    disp2(:,:)=squeeze(field.UX_c(:,procdata.yheight,:));
                    imghandle =imagesc(x_tick,y_tick,disp2);
                case 'uY'
                    disp2(:,:)=squeeze(field.UY_c(:,procdata.yheight,:));
                    imghandle =imagesc(x_tick,y_tick,disp2);
                case 'uZ'
                    disp2(:,:)=squeeze(field.UZ_c(:,procdata.yheight,:));
                    imghandle =imagesc(x_tick,y_tick,disp2);
            end
            set(gca,'YDir','normal')
	        title(procdata.Contour)
	        xlabel('PosX')
	        ylabel('PosZ')
            x_tick=sort([field.POSY(1,1,1),field.POSY(end,1,1)]);
            y_tick=sort([field.POSZ(1,1,1),field.POSZ(1,1,end)]);
            axes(axes3)
            switch procdata.Contour
                case 'uX'
                    disp3(:,:)=squeeze(field.UX_c(:,:,procdata.xheight));
                    imghandle =imagesc(x_tick,y_tick,disp3);
                case 'uY'
                    disp3(:,:)=squeeze(field.UY_c(:,:,procdata.xheight));
                    imghandle =imagesc(x_tick,y_tick,disp3);
                case 'uZ'
                    disp3(:,:)=squeeze(field.UZ_c(:,:,procdata.xheight));
                    imghandle =imagesc(x_tick,y_tick,disp3);
            end
	        set(gca,'YDir','normal')
	        title(procdata.Contour)
	        xlabel('PosY')
	        ylabel('PosZ')
	        Xaxis='PosX';
	        Yaxis='PosY';
	        if mask_check==1
		        for i=1:procdata.current
		        	if sum(values==i)
			            if (p.op(i).Xaxis==Xaxis)&(p.op(i).Yaxis==Yaxis)
			                if (p.op(i).Xaxis=='PosX')&(p.op(i).Yaxis=='PosY')
			                    height=p.zheight;
			                elseif (p.op(i).Xaxis=='PosX')&(p.op(i).Yaxis=='PosZ')
			                    height=p.yheight;
			                elseif (p.op(i).Xaxis=='PosY')&(p.op(i).Yaxis=='PosZ')
			                    height=p.xheight;
			                end
			                if (height>=min(p.op(i).mask_range))&(height<=max(p.op(i).mask_range))
			                    if findstr(p.op(i).shape,'rectangle')>0
			                        p.op(i).handle=imrect(axes1,[p.op(i).coord(1), p.op(i).coord(2), p.op(i).coord(3), p.op(i).coord(4)]);
			                        if findstr(p.op(i).clude,'include')
			                            setColor(p.op(i).handle,'g')
			                        else
			                            setColor(p.op(i).handle,'r')
			                        end
			                    elseif findstr(p.op(i).shape,'polygon')>0
			                        p.op(i).handle=impoly(axes1,p.op(i).coord);
			                        if findstr(p.op(i).clude,'include')
			                            setColor(p.op(i).handle,'g')
			                        else
			                            setColor(p.op(i).handle,'r')
			                        end
			                    elseif findstr(p.op(i).shape,'ellipse')>0
			                        p.op(i).handle=imellipse(axes1,[p.op(i).coord(1), p.op(i).coord(2), p.op(i).coord(3), p.op(i).coord(4)]);
			                        if findstr(p.op(i).clude,'include')
			                            setColor(p.op(i).handle,'g')
			                        else
			                            setColor(p.op(i).handle,'r')
			                        end
			                    elseif findstr(p.op(i).shape,'point')>0
			                        p.op(i).handle=impoint(axes1,[p.op(i).coord(1), p.op(i).coord(2)]);
			                        if findstr(p.op(i).clude,'include')
			                            setColor(p.op(i).handle,'g')
			                        else
			                            setColor(p.op(i).handle,'r')
			                        end
			                    end
			                end
			            elseif findstr(p.op(i).shape,'point')>0
			                if (Xaxis=='PosX')&(Yaxis=='PosY')
			                    if (p.op(i).Xaxis=='PosX')&(p.op(i).Yaxis=='PosZ')
			                        p.op(i).handle=impoint(axes1,[p.op(i).coord(1), field.POSY(p.op(i).height,1,1)]);
			                    elseif (p.op(i).Xaxis=='PosY')&(p.op(i).Yaxis=='PosZ')
			                        p.op(i).handle=impoint(axes1,[field.POSX(1,p.op(i).height,1), p.op(i).coord(1)]);
			                    end
			                elseif (Xaxis=='PosX')&(Yaxis=='PosZ')
			                    if (p.op(i).Xaxis=='PosY')&(p.op(i).Yaxis=='PosZ')
			                        p.op(i).handle=impoint(axes1,[field.POSX(1,p.op(i).height), p.op(i).coord(2)]);
			                    elseif (p.op(i).Xaxis=='PosX')&(p.op(i).Yaxis=='PosY')
			                        p.op(i).handle=impoint(axes1,[p.op(i).coord(1), field.POSZ(1,1,p.op(i).height)]);
			                    end
			                elseif (Xaxis=='PosY')&(Yaxis=='PosZ')
			                    if (p.op(i).Xaxis=='PosX')&(p.op(i).Yaxis=='PosZ')
			                        p.op(i).handle=impoint(axes1,[field.POSY(p.op(i).height,1,1), p.op(i).coord(2)]);
			                    elseif (p.op(i).Xaxis=='PosX')&(p.op(i).Yaxis=='PosY')
			                        p.op(i).handle=impoint(axes1,[p.op(i).coord(2), field.POSZ(1,1,p.op(i).height)]);
			                    end
			                end
			            end
			        end
			    end
			        Xaxis='PosX';
			        Yaxis='PosZ';
			        for i=1:procdata.current
			        	if sum(values==i)
				            if (p.op(i).Xaxis==Xaxis)&(p.op(i).Yaxis==Yaxis)
				                if (p.op(i).Xaxis=='PosX')&(p.op(i).Yaxis=='PosY')
				                    height=p.zheight;
				                elseif (p.op(i).Xaxis=='PosX')&(p.op(i).Yaxis=='PosZ')
				                    height=p.yheight;
				                elseif (p.op(i).Xaxis=='PosY')&(p.op(i).Yaxis=='PosZ')
				                    height=p.xheight;
				                end
				                if (height>=min(p.op(i).mask_range))&(height<=max(p.op(i).mask_range))
				                    if findstr(p.op(i).shape,'rectangle')>0
				                        p.op(i).handle=imrect(axes2,[p.op(i).coord(1), p.op(i).coord(2), p.op(i).coord(3), p.op(i).coord(4)]);
				                        if findstr(p.op(i).clude,'include')
				                            setColor(p.op(i).handle,'g')
				                        else
				                            setColor(p.op(i).handle,'r')
				                        end
				                    elseif findstr(p.op(i).shape,'polygon')>0
				                        p.op(i).handle=impoly(axes2,p.op(i).coord);
				                        if findstr(p.op(i).clude,'include')
				                            setColor(p.op(i).handle,'g')
				                        else
				                            setColor(p.op(i).handle,'r')
				                        end
				                    elseif findstr(p.op(i).shape,'ellipse')>0
				                        p.op(i).handle=imellipse(axes2,[p.op(i).coord(1), p.op(i).coord(2), p.op(i).coord(3), p.op(i).coord(4)]);
				                        if findstr(p.op(i).clude,'include')
				                            setColor(p.op(i).handle,'g')
				                        else
				                            setColor(p.op(i).handle,'r')
				                        end
				                    elseif findstr(p.op(i).shape,'point')>0
				                        p.op(i).handle=impoint(axes2,[p.op(i).coord(1), p.op(i).coord(2)]);
				                        if findstr(p.op(i).clude,'include')
				                            setColor(p.op(i).handle,'g')
				                        else
				                            setColor(p.op(i).handle,'r')
				                        end
				                    end
				                end
				            elseif findstr(p.op(i).shape,'point')>0
				                if (Xaxis=='PosX')&(Yaxis=='PosY')
				                    if (p.op(i).Xaxis=='PosX')&(p.op(i).Yaxis=='PosZ')
				                        p.op(i).handle=impoint(axes2,[p.op(i).coord(1), field.POSY(p.op(i).height,1,1)]);
				                    elseif (p.op(i).Xaxis=='PosY')&(p.op(i).Yaxis=='PosZ')
				                        p.op(i).handle=impoint(axes2,[field.POSX(1,p.op(i).height,1), p.op(i).coord(1)]);
				                    end
				                elseif (Xaxis=='PosX')&(Yaxis=='PosZ')
				                    if (p.op(i).Xaxis=='PosY')&(p.op(i).Yaxis=='PosZ')
				                        p.op(i).handle=impoint(axes2,[field.POSX(1,p.op(i).height), p.op(i).coord(2)]);
				                    elseif (p.op(i).Xaxis=='PosX')&(p.op(i).Yaxis=='PosY')
				                        p.op(i).handle=impoint(axes2,[p.op(i).coord(1), field.POSZ(1,1,p.op(i).height)]);
				                    end
				                elseif (Xaxis=='PosY')&(Yaxis=='PosZ')
				                    if (p.op(i).Xaxis=='PosX')&(p.op(i).Yaxis=='PosZ')
				                        p.op(i).handle=impoint(axes2,[field.POSY(p.op(i).height,1,1), p.op(i).coord(2)]);
				                    elseif (p.op(i).Xaxis=='PosX')&(p.op(i).Yaxis=='PosY')
				                        p.op(i).handle=impoint(axes2,[p.op(i).coord(2), field.POSZ(1,1,p.op(i).height)]);
				                    end
				                end
				            end
				        end
				    end
			        Xaxis='PosY';
			        Yaxis='PosZ';
			        for i=1:procdata.current
			        	if sum(values==i)
			            if (p.op(i).Xaxis==Xaxis)&(p.op(i).Yaxis==Yaxis)
			                if (p.op(i).Xaxis=='PosX')&(p.op(i).Yaxis=='PosY')
			                    height=p.zheight;
			                elseif (p.op(i).Xaxis=='PosX')&(p.op(i).Yaxis=='PosZ')
			                    height=p.yheight;
			                elseif (p.op(i).Xaxis=='PosY')&(p.op(i).Yaxis=='PosZ')
			                    height=p.xheight;
			                end
			                if (height>=min(p.op(i).mask_range))&(height<=max(p.op(i).mask_range))
			                    if findstr(p.op(i).shape,'rectangle')>0
			                        p.op(i).handle=imrect(axes3,[p.op(i).coord(1), p.op(i).coord(2), p.op(i).coord(3), p.op(i).coord(4)]);
			                        if findstr(p.op(i).clude,'include')
			                            setColor(p.op(i).handle,'g')
			                        else
			                            setColor(p.op(i).handle,'r')
			                        end
			                    elseif findstr(p.op(i).shape,'polygon')>0
			                        p.op(i).handle=impoly(axes3,p.op(i).coord);
			                        if findstr(p.op(i).clude,'include')
			                            setColor(p.op(i).handle,'g')
			                        else
			                            setColor(p.op(i).handle,'r')
			                        end
			                    elseif findstr(p.op(i).shape,'ellipse')>0
			                        p.op(i).handle=imellipse(axes3,[p.op(i).coord(1), p.op(i).coord(2), p.op(i).coord(3), p.op(i).coord(4)]);
			                        if findstr(p.op(i).clude,'include')
			                            setColor(p.op(i).handle,'g')
			                        else
			                            setColor(p.op(i).handle,'r')
			                        end
			                    elseif findstr(p.op(i).shape,'point')>0
			                        p.op(i).handle=impoint(axes3,[p.op(i).coord(1), p.op(i).coord(2)]);
			                        if findstr(p.op(i).clude,'include')
			                            setColor(p.op(i).handle,'g')
			                        else
			                            setColor(p.op(i).handle,'r')
			                        end
			                    end
			                end
			            elseif findstr(p.op(i).shape,'point')>0
			                if (Xaxis=='PosX')&(Yaxis=='PosY')
			                    if (p.op(i).Xaxis=='PosX')&(p.op(i).Yaxis=='PosZ')
			                        p.op(i).handle=impoint(axes3,[p.op(i).coord(1), field.POSY(p.op(i).height,1,1)]);
			                    elseif (p.op(i).Xaxis=='PosY')&(p.op(i).Yaxis=='PosZ')
			                        p.op(i).handle=impoint(axes3,[field.POSX(1,p.op(i).height,1), p.op(i).coord(1)]);
			                    end
			                elseif (Xaxis=='PosX')&(Yaxis=='PosZ')
			                    if (p.op(i).Xaxis=='PosY')&(p.op(i).Yaxis=='PosZ')
			                        p.op(i).handle=impoint(axes3,[field.POSX(1,p.op(i).height), p.op(i).coord(2)]);
			                    elseif (p.op(i).Xaxis=='PosX')&(p.op(i).Yaxis=='PosY')
			                        p.op(i).handle=impoint(axes3,[p.op(i).coord(1), field.POSZ(1,1,p.op(i).height)]);
			                    end
			                elseif (Xaxis=='PosY')&(Yaxis=='PosZ')
			                    if (p.op(i).Xaxis=='PosX')&(p.op(i).Yaxis=='PosZ')
			                        p.op(i).handle=impoint(axes3,[field.POSY(p.op(i).height,1,1), p.op(i).coord(2)]);
			                    elseif (p.op(i).Xaxis=='PosX')&(p.op(i).Yaxis=='PosY')
			                        p.op(i).handle=impoint(axes3,[p.op(i).coord(2), field.POSZ(1,1,p.op(i).height)]);
			                    end
			                end
			            end
			        end
			    end
		    end
	    end
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

% this function is used to edit the masks coordinate data so that they are correctly placed when a reference point is active
function procdata=update_masks_from_ref_point(procdata,field)
	ref_check=0;
	for i=1:procdata.current
		if findstr(procdata.op(i).act,'ref')
			if procdata.which_operations==-1
				ref_check=i;
			elseif procdata.which_operations(i)==1
				ref_check=i;
			end
		end
	end
	if (procdata.data_type=='DIC')&(ref_check~=0)
		x_ref=procdata.op(ref_check).coord(1);
		y_ref=procdata.op(ref_check).coord(2);
		for i=1:procdata.current
			if procdata.which_operations==-1
				switch procdata.op(i).shape
				case 'rectangle'
					procdata.op(i).coord(1)=procdata.op(i).coord(1)-x_ref;
					procdata.op(i).coord(2)=procdata.op(i).coord(2)-y_ref;
				case 'ellipse'
					procdata.op(i).coord(1)=procdata.op(i).coord(1)-x_ref;
					procdata.op(i).coord(2)=procdata.op(i).coord(2)-y_ref;
				case 'polygon'
					[r,c]=size(procdata.op(i).coord);
					for j=1:r
						procdata.op(i).coord(j,1)=procdata.op(i).coord(j,1)-x_ref;
						procdata.op(i).coord(j,2)=procdata.op(i).coord(j,2)-y_ref;
					end
				case 'point'
					procdata.op(i).coord(1)=procdata.op(i).coord(1)-x_ref;
					procdata.op(i).coord(2)=procdata.op(i).coord(2)-y_ref;
				end
			elseif procdata.which_operations(i)==1
				switch procdata.op(i).shape
				case 'rectangle'
					procdata.op(i).coord(1)=procdata.op(i).coord(1)-x_ref;
					procdata.op(i).coord(2)=procdata.op(i).coord(2)-y_ref;
				case 'ellipse'
					procdata.op(i).coord(1)=procdata.op(i).coord(1)-x_ref;
					procdata.op(i).coord(2)=procdata.op(i).coord(2)-y_ref;
				case 'polygon'
					[r,c]=size(procdata.op(i).coord);
					for j=1:r
						procdata.op(i).coord(j,1)=procdata.op(i).coord(j,1)-x_ref;
						procdata.op(i).coord(j,2)=procdata.op(i).coord(j,2)-y_ref;
					end
				case 'point'
					procdata.op(i).coord(1)=procdata.op(i).coord(1)-x_ref;
					procdata.op(i).coord(2)=procdata.op(i).coord(2)-y_ref;
				end
			end
		end
	elseif (procdata.data_type=='DVC')&(ref_check~=0)
		if (procdata.op(ref_check).Xaxis=='PosX')&(procdata.op(ref_check).Yaxis=='PosY')
			x_ref=procdata.op(ref_check).coord(1);
			y_ref=procdata.op(ref_check).coord(2);
			z_ref=field.POSZ_locked(1,1,procdata.op(ref_check).height);
			z_ref_ind=procdata.op(ref_check).height;
			[~,x_ref_ind]=min(abs(field.POSX(1,:,1)-x_ref));
			[~,y_ref_ind]=min(abs(field.POSY(:,1,1)-y_ref));
		elseif (procdata.op(ref_check).Xaxis=='PosX')&(procdata.op(ref_check).Yaxis=='PosZ')
			x_ref=procdata.op(ref_check).coord(1);
			z_ref=procdata.op(ref_check).coord(2);
			y_ref=field.POSY_locked(procdata.op(ref_check).height,1,1);
			y_ref_ind=procdata.op(ref_check).height;
			[~,x_ref_ind]=min(abs(field.POSX(1,:,1)-x_ref));
			[~,z_ref_ind]=min(abs(field.POSZ(1,1,:)-z_ref));
		elseif (procdata.op(ref_check).Xaxis=='PosY')&(procdata.op(ref_check).Yaxis=='PosZ')
			y_ref=procdata.op(ref_check).coord(1);
			z_ref=procdata.op(ref_check).coord(2);
			x_ref=field.POSX_locked(1,procdata.op(ref_check).height,1);
			x_ref_ind=procdata.op(ref_check).height;
			[~,y_ref_ind]=min(abs(field.POSY(:,1,1)-y_ref));
			[~,z_ref_ind]=min(abs(field.POSZ(1,1,:)-z_ref));
		end
		for i=1:procdata.current
			if procdata.which_operations==-1
				switch procdata.op(i).shape
				case 'rectangle'
					if (procdata.op(i).Xaxis=='PosX')&(procdata.op(i).Yaxis=='PosY')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-x_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-y_ref;
							% procdata.op(i).height=procdata.op(i).height-z_ref_ind;
					elseif (procdata.op(i).Xaxis=='PosX')&(procdata.op(i).Yaxis=='PosZ')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-x_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-z_ref;
							% procdata.op(i).height=procdata.op(i).height-y_ref_ind;
					elseif (procdata.op(i).Xaxis=='PosY')&(procdata.op(i).Yaxis=='PosZ')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-y_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-z_ref;
							% procdata.op(i).height=procdata.op(i).height-x_ref_ind;

					end
				case 'ellipse'
					if (procdata.op(i).Xaxis=='PosX')&(procdata.op(i).Yaxis=='PosY')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-x_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-y_ref;
							% procdata.op(i).height=procdata.op(i).height-z_ref_ind;
					elseif (procdata.op(i).Xaxis=='PosX')&(procdata.op(i).Yaxis=='PosZ')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-x_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-z_ref;
							% procdata.op(i).height=procdata.op(i).height-y_ref_ind;
					elseif (procdata.op(i).Xaxis=='PosY')&(procdata.op(i).Yaxis=='PosZ')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-y_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-z_ref;
							% procdata.op(i).height=procdata.op(i).height-x_ref_ind;
					end
				case 'polygon'
					[r,c]=size(procdata.op(i).coord);
					if (procdata.op(i).Xaxis=='PosX')&(procdata.op(i).Yaxis=='PosY')
						for j=1:r
							procdata.op(i).coord(j,1)=procdata.op(i).coord(j,1)-x_ref;
							procdata.op(i).coord(j,2)=procdata.op(i).coord(j,2)-y_ref;
						end
						% procdata.op(i).height=procdata.op(i).height-z_ref_ind;
					elseif (procdata.op(i).Xaxis=='PosX')&(procdata.op(i).Yaxis=='PosZ')
						for j=1:r
							procdata.op(i).coord(j,1)=procdata.op(i).coord(j,1)-x_ref;
							procdata.op(i).coord(j,2)=procdata.op(i).coord(j,2)-z_ref;
						end
						% procdata.op(i).height=procdata.op(i).height-y_ref_ind;
					elseif (procdata.op(i).Xaxis=='PosY')&(procdata.op(i).Yaxis=='PosZ')
						for j=1:r
							procdata.op(i).coord(j,1)=procdata.op(i).coord(j,1)-y_ref;
							procdata.op(i).coord(j,2)=procdata.op(i).coord(j,2)-z_ref;
						end
						% procdata.op(i).height=procdata.op(i).height-x_ref_ind;
					end	
				case 'point'
					if (procdata.op(i).Xaxis=='PosX')&(procdata.op(i).Yaxis=='PosY')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-x_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-y_ref;
						% procdata.op(i).height=procdata.op(i).height-z_ref_ind;
					elseif (procdata.op(i).Xaxis=='PosX')&(procdata.op(i).Yaxis=='PosZ')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-x_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-z_ref;
						% procdata.op(i).height=procdata.op(i).height-y_ref_ind;
					elseif (procdata.op(i).Xaxis=='PosY')&(procdata.op(i).Yaxis=='PosZ')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-y_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-z_ref;
						% procdata.op(i).height=procdata.op(i).height-x_ref_ind;
					end
				end
			elseif procdata.which_operations(i)==1
				switch procdata.op(i).shape
				case 'rectangle'
					if (procdata.op(i).Xaxis=='PosX')&(procdata.op(i).Yaxis=='PosY')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-x_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-y_ref;
						% procdata.op(i).height=procdata.op(i).height-z_ref_ind;
					elseif (procdata.op(i).Xaxis=='PosX')&(procdata.op(i).Yaxis=='PosZ')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-x_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-z_ref;
						% procdata.op(i).height=procdata.op(i).height-y_ref_ind;
					elseif (procdata.op(i).Xaxis=='PosY')&(procdata.op(i).Yaxis=='PosZ')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-y_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-z_ref;
						% procdata.op(i).height=procdata.op(i).height-x_ref_ind;
					end
				case 'ellipse'
					if (procdata.op(i).Xaxis=='PosX')&(procdata.op(i).Yaxis=='PosY')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-x_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-y_ref;
						% procdata.op(i).height=procdata.op(i).height-z_ref_ind;
					elseif (procdata.op(i).Xaxis=='PosX')&(procdata.op(i).Yaxis=='PosZ')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-x_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-z_ref;
						% procdata.op(i).height=procdata.op(i).height-y_ref_ind;
					elseif (procdata.op(i).Xaxis=='PosY')&(procdata.op(i).Yaxis=='PosZ')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-y_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-z_ref;
						% procdata.op(i).height=procdata.op(i).height-x_ref_ind;
					end
				case 'polygon'
					[r,c]=size(procdata.op(i).coord);
					if (procdata.op(i).Xaxis=='PosX')&(procdata.op(i).Yaxis=='PosY')
						for j=1:r
							procdata.op(i).coord(j,1)=procdata.op(i).coord(j,1)-x_ref;
							procdata.op(i).coord(j,2)=procdata.op(i).coord(j,2)-y_ref;
						end
						% procdata.op(i).height=procdata.op(i).height-z_ref_ind;
					elseif (procdata.op(i).Xaxis=='PosX')&(procdata.op(i).Yaxis=='PosZ')
						for j=1:r
							procdata.op(i).coord(j,1)=procdata.op(i).coord(j,1)-x_ref;
							procdata.op(i).coord(j,2)=procdata.op(i).coord(j,2)-z_ref;
						end
						% procdata.op(i).height=procdata.op(i).height-y_ref_ind;
					elseif (procdata.op(i).Xaxis=='PosY')&(procdata.op(i).Yaxis=='PosZ')
						for j=1:r
							procdata.op(i).coord(j,1)=procdata.op(i).coord(j,1)-y_ref;
							procdata.op(i).coord(j,2)=procdata.op(i).coord(j,2)-z_ref;
						end
						% procdata.op(i).height=procdata.op(i).height-x_ref_ind;
					end
				case 'point'
					if (procdata.op(i).Xaxis=='PosX')&(procdata.op(i).Yaxis=='PosY')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-x_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-y_ref;
							% procdata.op(i).height=procdata.op(i).height-z_ref_ind;
					elseif (procdata.op(i).Xaxis=='PosX')&(procdata.op(i).Yaxis=='PosZ')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-x_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-z_ref;
							% procdata.op(i).height=procdata.op(i).height-y_ref_ind;
					elseif (procdata.op(i).Xaxis=='PosY')&(procdata.op(i).Yaxis=='PosZ')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-y_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-z_ref;
							% procdata.op(i).height=procdata.op(i).height-x_ref_ind;
					end	
				end
			end
		end
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

function [out]=Check_if_masks_fit_in_crop()

end