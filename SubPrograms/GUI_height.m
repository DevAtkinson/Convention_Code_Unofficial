function [height]=GUI_height(ax,val_up)
	%this function creates a gui popup windows so that the height to be viewed for DVC data can be selected
	scrsz = get(0,'ScreenSize');
	handles.fig = figure('MenuBar','None','Position',[(scrsz(3)-300)/2 (scrsz(4)-600)/2 300 140]);
	string1=sprintf('%s height', ax);
	set(handles.fig, 'Name', string1);

    string=sprintf('Height along %s axis (min=1/max=%d):',ax,val_up);
	uicontrol('Style','text','String',string,...
                'Position',[15 80 220 40]);
	height_obj = uicontrol('Style','edit','Position',[230 80 60 40]);
	pb=uicontrol('Style','pushbutton','String','Done','Position',[230 20 60 40],'Callback',@close_fn);

	uiwait
	
	function close_fn(hObject,eventdata,handles)
		handles = guidata(hObject);
		height=str2num(get(height_obj,'String'));
		guidata(hObject, handles);
		uiresume
		close
	end
end