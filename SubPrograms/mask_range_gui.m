function [handles,out1,out2]=mask_range_gui(val_up)
	% this function creates a gui popup window so that the range over which a mask is applied can be set for DVC data
	scrsz = get(0,'ScreenSize');
	handles.fig = figure('MenuBar','None','Position',[(scrsz(3)-300)/2 (scrsz(4)-600)/2 300 250]);
	set(handles.fig, 'Name', 'Mask range');
    uicontrol('Style','text','String','Lower mask range (min of 1):',...
                'Position',[15 160 200 40]);
    string=sprintf('Upper mask range (max of %d):',val_up);
	uicontrol('Style','text','String',string,...
                'Position',[15 80 200 40]);
	lower_range = uicontrol('Style','edit','Position',[200 160 60 40]);
	upper_range = uicontrol('Style','edit','Position',[200 80 60 40]);
	pb=uicontrol('Style','pushbutton','String','Done','Position',[200 20 60 40],'Callback',@close_fn);

	uiwait
	
	function close_fn(hObject,eventdata,handles)
		handles = guidata(hObject);
		out1=str2num(get(lower_range,'String'));
		out2=str2num(get(upper_range,'String'));
		guidata(hObject, handles);
		uiresume
		close
	end
end