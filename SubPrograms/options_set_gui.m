function [operations,RBM]=options_set_gui(h,roi,roicount)
	%this function creates a popup window from which the operations to perform can be selected and the processed data and masks selected can be viewed
	scrsz = get(0,'ScreenSize');
	handles.fig = figure('MenuBar','None','Position',[(scrsz(3)-300)/2 (scrsz(4)-600)/2 400 (30*roicount+200)]);
	set(handles.fig, 'Name', 'Mask range');
	uicontrol('Style','text','String','Operations:','Position',[15 (30*roicount+50) 100 20]);
	uicontrol('Style','text','String','Options:','Position',[250 (30*roicount+50) 100 20]);
	uicontrol('Style','text','String',sprintf('Set which operations to execute and whether to remove rigid body rotations.'),'Position',[15 (30*roicount+100) 370 40]);

	for i=1:roicount
		cbh(i) = uicontrol('Style','checkbox','String',sprintf('%d %s %s %s',i,roi(i).act,roi(i).shape,roi(i).clude),'Value',0,'Position',[15 30*(roicount-i+1) 200 20]);
		% switch roi(i).act
		% case 'mask'
		% 	cbh2(i)=uicontrol('Style','checkbox','Value',0,'Position',[250 30*i 200 20]);
		% case 'roi'
		% 	cbh2(i)=uicontrol('Style','checkbox','Value',0,'Position',[250 30*i 200 20]);
		% end
	end
	cbh2=uicontrol('Style','checkbox','String','Remove RBM','Position',[250,30*roicount+30,200,20],'tooltipstring',sprintf('This wil remove rigid body motions from the masked out region.\nIt is not recommended to apply this to unmasked data.'));

	pb=uicontrol('Style','pushbutton','String','Save','Position',[270 10 60 40],'Callback',@save_fn,'tooltipstring',sprintf('This will save which opertions to apply in ''which_operations''.'));
	pb_show=uicontrol('Style','pushbutton','String','Show','Position',[200 10 60 40],'Callback',@show_fn,'tooltipstring',sprintf('This will show the data as processed by the selected operations.'));
	pb_cancel=uicontrol('Style','pushbutton','String','Cancel','Position',[340 10 60 40],'Callback',@close_fn,'tooltipstring',sprintf('This will exit the gui and make no changes to the data.'));
	ch_mask=uicontrol('Style','checkbox','String','Display masks','Position',[250,30*roicount,200,20],'tooltipstring',sprintf('Show''s output will display masks.'));
	uiwait

	% function to cancel
	function close_fn(hObject,eventdata,handles)
		operations=h.procdata.which_operations;
		RBM=h.procdata.RBM;
		uiresume
		close
	end
	% function to save the selected operations
	function save_fn(hObject,eventdata,handles)
		handles = guidata(hObject);
		for i=1:roicount
			operations(i)=get(cbh(i),'Value');
		end
		if get(cbh2,'Value')==1
			RBM=1;
		else 
			RBM=0;
		end
		guidata(hObject, handles);
		uiresume
		close
	end
	% function to create plots to view the data
	function show_fn(hObject,eventdata,handles)
		handles = guidata(hObject);
		mask_check=get(ch_mask,'Value');
		for i=1:roicount
			operations(i)=get(cbh(i),'Value');
		end
		if get(cbh2,'Value')==1
			RBM=1;
		else 
			RBM=0;
		end
		if operations~=-1
			h.procdata.current=roicount;
			h.procdata.RBM=RBM;
		    for i=1:roicount
		        h.procdata.op(i).act=roi(i).act;
		        h.procdata.op(i).shape=roi(i).shape;
		        h.procdata.op(i).coord=roi(i).coord;
		        h.procdata.op(i).clude=roi(i).clude;
		        if h.procdata.data_type=='DVC'
		            h.procdata.op(i).Xaxis=roi(i).Xaxis;
		            h.procdata.op(i).Yaxis=roi(i).Yaxis;
		            h.procdata.op(i).mask_range=roi(i).mask_range;
		            h.procdata.op(i).height=roi(i).height;
		        end
		    end
		    field=field_format(h.procdata,'which operations',operations);
		    if h.procdata.data_type=='DIC'  
		        x_tick=sort([field.PosX(1,1),field.PosX(1,end)]);
		        y_tick=sort([field.PosY(1,1),field.PosY(end,1)]);
		        switch h.procdata.Contour
		        case 'uX'
		            figure
		            hAxes =imagesc(x_tick,y_tick,field.uX);
		            title('uX')
		        case 'uY'
		            figure
		            hAxes =imagesc(x_tick,y_tick,field.uY);
		            title('uY')
		        case 'uZ'
		            figure
		            hAxes =imagesc(x_tick,y_tick,field.uZ);
		            title('uZ')
		        end
		        axis equal tight
		        set(gca,'YDir','normal')
		        xlabel('PosX')
		        ylabel('PosY')
		        if mask_check==1
	        	p=update_masks_from_ref_point(h.procdata,field);
		        for i=1:h.procdata.current
		        	if operations(i)==1
			            if findstr(p.op(i).shape,'rectangle')>0
			                p.op(i).handle=imrect(gca,[p.op(i).coord(1), p.op(i).coord(2), p.op(i).coord(3), p.op(i).coord(4)]);
			                if findstr(p.op(i).clude,'include')
			                    setColor(p.op(i).handle,'g')
			                else
			                    setColor(p.op(i).handle,'r')
			                end
			            elseif findstr(p.op(i).shape,'polygon')>0
			                p.op(i).handle=impoly(gca,p.op(i).coord);
			                if findstr(p.op(i).clude,'include')
			                    setColor(p.op(i).handle,'g')
			                else
			                    setColor(p.op(i).handle,'r')
			                end
			            elseif findstr(p.op(i).shape,'ellipse')>0
			                p.op(i).handle=imellipse(gca,[p.op(i).coord(1), p.op(i).coord(2), p.op(i).coord(3), p.op(i).coord(4)]);
			                if findstr(p.op(i).clude,'include')
			                    setColor(p.op(i).handle,'g')
			                else
			                    setColor(p.op(i).handle,'r')
			                end
			            elseif findstr(p.op(i).shape,'point')>0
			                p.op(i).handle=impoint(gca,[p.op(i).coord(1), p.op(i).coord(2)]);
			                if findstr(p.op(i).clude,'include')
			                    setColor(p.op(i).handle,'g')
			                else
			                    setColor(p.op(i).handle,'r')
			                end
			            end
			        end
			    end
			end
		    elseif h.procdata.data_type=='DVC'
		        x_tick=sort([field.PosX(1,1,1),field.PosX(1,end,1)]);
		        y_tick=sort([field.PosY(1,1,1),field.PosY(end,1,1)]);
		        p=update_masks_from_ref_point(h.procdata,field);
		        switch h.procdata.Contour
		            case 'uX'
		                disp1(:,:)=field.uX(:,:,h.procdata.zheight);
		                figure
		                imghandle =imagesc(x_tick,y_tick,disp1);
		                title('uX')
		            case 'uY'
		                disp1(:,:)=field.uY(:,:,h.procdata.zheight);
		                figure
		                imghandle =imagesc(x_tick,y_tick,disp1);
		                title('uY')
		            case 'uZ'
		                disp1(:,:)=field.uZ(:,:,h.procdata.zheight);
		                figure
		                imghandle =imagesc(x_tick,y_tick,disp1);
		                title('uZ')
		        end
		        set(gca,'YDir','normal')
		        xlabel('PosX')
		        ylabel('PosY')
		        axis equal tight
		        Xaxis='PosX';
		        Yaxis='PosY';
		        if mask_check==1
			        for i=1:h.procdata.current
			        	if operations(i)==1
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
				                        p.op(i).handle=imrect(gca,[p.op(i).coord(1), p.op(i).coord(2), p.op(i).coord(3), p.op(i).coord(4)]);
				                        if findstr(p.op(i).clude,'include')
				                            setColor(p.op(i).handle,'g')
				                        else
				                            setColor(p.op(i).handle,'r')
				                        end
				                    elseif findstr(p.op(i).shape,'polygon')>0
				                        p.op(i).handle=impoly(gca,p.op(i).coord);
				                        if findstr(p.op(i).clude,'include')
				                            setColor(p.op(i).handle,'g')
				                        else
				                            setColor(p.op(i).handle,'r')
				                        end
				                    elseif findstr(p.op(i).shape,'ellipse')>0
				                        p.op(i).handle=imellipse(gca,[p.op(i).coord(1), p.op(i).coord(2), p.op(i).coord(3), p.op(i).coord(4)]);
				                        if findstr(p.op(i).clude,'include')
				                            setColor(p.op(i).handle,'g')
				                        else
				                            setColor(p.op(i).handle,'r')
				                        end
				                    elseif findstr(p.op(i).shape,'point')>0
				                        p.op(i).handle=impoint(gca,[p.op(i).coord(1), p.op(i).coord(2)]);
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
				                        p.op(i).handle=impoint(gca,[p.op(i).coord(1), field.PosY(p.op(i).height,1,1)]);
				                    elseif (p.op(i).Xaxis=='PosY')&(p.op(i).Yaxis=='PosZ')
				                        p.op(i).handle=impoint(gca,[field.PosX(1,p.op(i).height,1), p.op(i).coord(1)]);
				                    end
				                elseif (Xaxis=='PosX')&(Yaxis=='PosZ')
				                    if (p.op(i).Xaxis=='PosY')&(p.op(i).Yaxis=='PosZ')
				                        p.op(i).handle=impoint(gca,[field.PosX(1,p.op(i).height), p.op(i).coord(2)]);
				                    elseif (p.op(i).Xaxis=='PosX')&(p.op(i).Yaxis=='PosY')
				                        p.op(i).handle=impoint(gca,[p.op(i).coord(1), field.PosZ(1,1,p.op(i).height)]);
				                    end
				                elseif (Xaxis=='PosY')&(Yaxis=='PosZ')
				                    if (p.op(i).Xaxis=='PosX')&(p.op(i).Yaxis=='PosZ')
				                        p.op(i).handle=impoint(gca,[field.PosY(p.op(i).height,1,1), p.op(i).coord(2)]);
				                    elseif (p.op(i).Xaxis=='PosX')&(p.op(i).Yaxis=='PosY')
				                        p.op(i).handle=impoint(gca,[p.op(i).coord(2), field.PosZ(1,1,p.op(i).height)]);
				                    end
				                end
				            end
				        end
				    end
			    end
		        x_tick=sort([field.PosX(1,1,1),field.PosX(1,end,1)]);
		        y_tick=sort([field.PosZ(1,1,1),field.PosZ(1,1,end)]);
		        switch h.procdata.Contour
		            case 'uX'
		                disp2(:,:)=field.uX(h.procdata.yheight,:,:);
		                figure
		                imghandle =imagesc(x_tick,y_tick,disp2);
		                title('uX')
		            case 'uY'
		                disp2(:,:)=field.uY(h.procdata.yheight,:,:);
		                figure
		                imghandle =imagesc(x_tick,y_tick,disp2);
		                title('uY')
		            case 'uZ'
		                disp2(:,:)=field.uZ(h.procdata.yheight,:,:);
		                figure
		                imghandle =imagesc(x_tick,y_tick,disp2);
		                title('uZ')
		        end
		        set(gca,'YDir','normal')
		        xlabel('PosX')
		        ylabel('PosZ')
		        axis equal tight
		        Xaxis='PosX';
		        Yaxis='PosZ';
		        if mask_check==1
			        for i=1:h.procdata.current
			        	if operations(i)==1
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
				                        p.op(i).handle=imrect(gca,[p.op(i).coord(1), p.op(i).coord(2), p.op(i).coord(3), p.op(i).coord(4)]);
				                        if findstr(p.op(i).clude,'include')
				                            setColor(p.op(i).handle,'g')
				                        else
				                            setColor(p.op(i).handle,'r')
				                        end
				                    elseif findstr(p.op(i).shape,'polygon')>0
				                        p.op(i).handle=impoly(gca,p.op(i).coord);
				                        if findstr(p.op(i).clude,'include')
				                            setColor(p.op(i).handle,'g')
				                        else
				                            setColor(p.op(i).handle,'r')
				                        end
				                    elseif findstr(p.op(i).shape,'ellipse')>0
				                        p.op(i).handle=imellipse(gca,[p.op(i).coord(1), p.op(i).coord(2), p.op(i).coord(3), p.op(i).coord(4)]);
				                        if findstr(p.op(i).clude,'include')
				                            setColor(p.op(i).handle,'g')
				                        else
				                            setColor(p.op(i).handle,'r')
				                        end
				                    elseif findstr(p.op(i).shape,'point')>0
				                        p.op(i).handle=impoint(gca,[p.op(i).coord(1), p.op(i).coord(2)]);
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
				                        p.op(i).handle=impoint(gca,[p.op(i).coord(1), field.PosY(p.op(i).height,1,1)]);
				                    elseif (p.op(i).Xaxis=='PosY')&(p.op(i).Yaxis=='PosZ')
				                        p.op(i).handle=impoint(gca,[field.PosX(1,p.op(i).height,1), p.op(i).coord(1)]);
				                    end
				                elseif (Xaxis=='PosX')&(Yaxis=='PosZ')
				                    if (p.op(i).Xaxis=='PosY')&(p.op(i).Yaxis=='PosZ')
				                        p.op(i).handle=impoint(gca,[field.PosX(1,p.op(i).height), p.op(i).coord(2)]);
				                    elseif (p.op(i).Xaxis=='PosX')&(p.op(i).Yaxis=='PosY')
				                        p.op(i).handle=impoint(gca,[p.op(i).coord(1), field.PosZ(1,1,p.op(i).height)]);
				                    end
				                elseif (Xaxis=='PosY')&(Yaxis=='PosZ')
				                    if (p.op(i).Xaxis=='PosX')&(p.op(i).Yaxis=='PosZ')
				                        p.op(i).handle=impoint(gca,[field.PosY(p.op(i).height,1,1), p.op(i).coord(2)]);
				                    elseif (p.op(i).Xaxis=='PosX')&(p.op(i).Yaxis=='PosY')
				                        p.op(i).handle=impoint(gca,[p.op(i).coord(2), field.PosZ(1,1,p.op(i).height)]);
				                    end
				                end
				            end
				        end
				    end
			    end
		        x_tick=sort([field.PosY(1,1,1),field.PosY(end,1,1)]);
		        y_tick=sort([field.PosZ(1,1,1),field.PosZ(1,1,end)]);
		        switch h.procdata.Contour
		            case 'uX'
		                disp3(:,:)=field.uX(:,h.procdata.xheight,:);
		                figure
		                imghandle =imagesc(x_tick,y_tick,disp3);
		                title('uX')
		            case 'uY'
		                disp3(:,:)=field.uY(:,h.procdata.xheight,:);
		                figure
		                imghandle =imagesc(x_tick,y_tick,disp3);
		                title('uY')
		            case 'uZ'
		                disp3(:,:)=field.uZ(:,h.procdata.xheight,:);
		                figure
		                imghandle =imagesc(x_tick,y_tick,disp3);
		                title('uZ')
		        end
		        set(gca,'YDir','normal')
		        xlabel('PosY')
		        ylabel('PosZ')
		        axis equal tight
		        Xaxis='PosY';
		        Yaxis='PosZ';
		       	if mask_check==1
			        for i=1:h.procdata.current
			        	if operations(i)==1
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
				                        p.op(i).handle=imrect(gca,[p.op(i).coord(1), p.op(i).coord(2), p.op(i).coord(3), p.op(i).coord(4)]);
				                        if findstr(p.op(i).clude,'include')
				                            setColor(p.op(i).handle,'g')
				                        else
				                            setColor(p.op(i).handle,'r')
				                        end
				                    elseif findstr(p.op(i).shape,'polygon')>0
				                        p.op(i).handle=impoly(gca,p.op(i).coord);
				                        if findstr(p.op(i).clude,'include')
				                            setColor(p.op(i).handle,'g')
				                        else
				                            setColor(p.op(i).handle,'r')
				                        end
				                    elseif findstr(p.op(i).shape,'ellipse')>0
				                        p.op(i).handle=imellipse(gca,[p.op(i).coord(1), p.op(i).coord(2), p.op(i).coord(3), p.op(i).coord(4)]);
				                        if findstr(p.op(i).clude,'include')
				                            setColor(p.op(i).handle,'g')
				                        else
				                            setColor(p.op(i).handle,'r')
				                        end
				                    elseif findstr(p.op(i).shape,'point')>0
				                        p.op(i).handle=impoint(gca,[p.op(i).coord(1), p.op(i).coord(2)]);
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
				                        p.op(i).handle=impoint(gca,[p.op(i).coord(1), field.PosY(p.op(i).height,1,1)]);
				                    elseif (p.op(i).Xaxis=='PosY')&(p.op(i).Yaxis=='PosZ')
				                        p.op(i).handle=impoint(gca,[field.PosX(1,p.op(i).height,1), p.op(i).coord(1)]);
				                    end
				                elseif (Xaxis=='PosX')&(Yaxis=='PosZ')
				                    if (p.op(i).Xaxis=='PosY')&(p.op(i).Yaxis=='PosZ')
				                        p.op(i).handle=impoint(gca,[field.PosX(1,p.op(i).height), p.op(i).coord(2)]);
				                    elseif (p.op(i).Xaxis=='PosX')&(p.op(i).Yaxis=='PosY')
				                        p.op(i).handle=impoint(gca,[p.op(i).coord(1), field.PosZ(1,1,p.op(i).height)]);
				                    end
				                elseif (Xaxis=='PosY')&(Yaxis=='PosZ')
				                    if (p.op(i).Xaxis=='PosX')&(p.op(i).Yaxis=='PosZ')
				                        p.op(i).handle=impoint(gca,[field.PosY(p.op(i).height,1,1), p.op(i).coord(2)]);
				                    elseif (p.op(i).Xaxis=='PosX')&(p.op(i).Yaxis=='PosY')
				                        p.op(i).handle=impoint(gca,[p.op(i).coord(2), field.PosZ(1,1,p.op(i).height)]);
				                    end
				                end
				            end
				        end
				    end
			    end
		    end
	    else
	    	fprintf('~ No masks were set as active. Therefore none can be displayed\n');
	    end
		guidata(hObject, handles);
	end
end

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
			z_ref=field.PosZ(1,1,procdata.op(ref_check).height);
		elseif (procdata.op(ref_check).Xaxis=='PosX')&(procdata.op(ref_check).Yaxis=='PosZ')
			x_ref=procdata.op(ref_check).coord(1);
			z_ref=procdata.op(ref_check).coord(2);
			y_ref=field.PosY(procdata.op(ref_check).height,1,1);
		elseif (procdata.op(ref_check).Xaxis=='PosY')&(procdata.op(ref_check).Yaxis=='PosZ')
			y_ref=procdata.op(ref_check).coord(1);
			z_ref=procdata.op(ref_check).coord(2);
			x_ref=field.PosX(1,procdata.op(ref_check).height,1);
		end
		for i=1:procdata.current
			if procdata.which_operations==-1
				switch procdata.op(i).shape
				case 'rectangle'
					if (procdata.op(ref_check).Xaxis=='PosX')&(procdata.op(ref_check).Yaxis=='PosY')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-x_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-y_ref;
						procdata.op(i).height=procdata.op(i).height-z_ref;
					elseif (procdata.op(ref_check).Xaxis=='PosX')&(procdata.op(ref_check).Yaxis=='PosZ')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-x_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-z_ref;
						procdata.op(i).height=procdata.op(i).height-y_ref;
					elseif (procdata.op(ref_check).Xaxis=='PosY')&(procdata.op(ref_check).Yaxis=='PosZ')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-y_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-z_ref;
						procdata.op(i).height=procdata.op(i).height-x_ref;
					end
				case 'ellipse'
					if (procdata.op(ref_check).Xaxis=='PosX')&(procdata.op(ref_check).Yaxis=='PosY')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-x_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-y_ref;
						procdata.op(i).height=procdata.op(i).height-z_ref;
					elseif (procdata.op(ref_check).Xaxis=='PosX')&(procdata.op(ref_check).Yaxis=='PosZ')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-x_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-z_ref;
						procdata.op(i).height=procdata.op(i).height-y_ref;
					elseif (procdata.op(ref_check).Xaxis=='PosY')&(procdata.op(ref_check).Yaxis=='PosZ')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-y_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-z_ref;
						procdata.op(i).height=procdata.op(i).height-x_ref;
					end
				case 'polygon'
					[r,c]=size(procdata.op(i).coord);
					if (procdata.op(ref_check).Xaxis=='PosX')&(procdata.op(ref_check).Yaxis=='PosY')
						for j=1:r
							procdata.op(i).coord(j,1)=procdata.op(i).coord(j,1)-x_ref;
							procdata.op(i).coord(j,2)=procdata.op(i).coord(j,2)-y_ref;
						end
						procdata.op(i).height=procdata.op(i).height-z_ref;
					elseif (procdata.op(ref_check).Xaxis=='PosX')&(procdata.op(ref_check).Yaxis=='PosZ')
						for j=1:r
							procdata.op(i).coord(j,1)=procdata.op(i).coord(j,1)-x_ref;
							procdata.op(i).coord(j,2)=procdata.op(i).coord(j,2)-z_ref;
						end
						procdata.op(i).height=procdata.op(i).height-y_ref;
					elseif (procdata.op(ref_check).Xaxis=='PosY')&(procdata.op(ref_check).Yaxis=='PosZ')
						for j=1:r
							procdata.op(i).coord(j,1)=procdata.op(i).coord(j,1)-y_ref;
							procdata.op(i).coord(j,2)=procdata.op(i).coord(j,2)-z_ref;
						end
						procdata.op(i).height=procdata.op(i).height-x_ref;
					end	
				case 'point'
					if (procdata.op(ref_check).Xaxis=='PosX')&(procdata.op(ref_check).Yaxis=='PosY')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-x_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-y_ref;
						procdata.op(i).height=procdata.op(i).height-z_ref;
					elseif (procdata.op(ref_check).Xaxis=='PosX')&(procdata.op(ref_check).Yaxis=='PosZ')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-x_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-z_ref;
						procdata.op(i).height=procdata.op(i).height-y_ref;
					elseif (procdata.op(ref_check).Xaxis=='PosY')&(procdata.op(ref_check).Yaxis=='PosZ')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-y_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-z_ref;
						procdata.op(i).height=procdata.op(i).height-x_ref;
					end
				end
			elseif procdata.which_operations(i)==1
				switch procdata.op(i).shape
				case 'rectangle'
					if (procdata.op(ref_check).Xaxis=='PosX')&(procdata.op(ref_check).Yaxis=='PosY')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-x_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-y_ref;
						procdata.op(i).height=procdata.op(i).height-z_ref;
					elseif (procdata.op(ref_check).Xaxis=='PosX')&(procdata.op(ref_check).Yaxis=='PosZ')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-x_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-z_ref;
						procdata.op(i).height=procdata.op(i).height-y_ref;
					elseif (procdata.op(ref_check).Xaxis=='PosY')&(procdata.op(ref_check).Yaxis=='PosZ')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-y_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-z_ref;
						procdata.op(i).height=procdata.op(i).height-x_ref;
					end
				case 'ellipse'
					if (procdata.op(ref_check).Xaxis=='PosX')&(procdata.op(ref_check).Yaxis=='PosY')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-x_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-y_ref;
						procdata.op(i).height=procdata.op(i).height-z_ref;
					elseif (procdata.op(ref_check).Xaxis=='PosX')&(procdata.op(ref_check).Yaxis=='PosZ')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-x_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-z_ref;
						procdata.op(i).height=procdata.op(i).height-y_ref;
					elseif (procdata.op(ref_check).Xaxis=='PosY')&(procdata.op(ref_check).Yaxis=='PosZ')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-y_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-z_ref;
						procdata.op(i).height=procdata.op(i).height-x_ref;
					end
				case 'polygon'
					[r,c]=size(procdata.op(i).coord);
					if (procdata.op(ref_check).Xaxis=='PosX')&(procdata.op(ref_check).Yaxis=='PosY')
						for j=1:r
							procdata.op(i).coord(j,1)=procdata.op(i).coord(j,1)-x_ref;
							procdata.op(i).coord(j,2)=procdata.op(i).coord(j,2)-y_ref;
						end
						procdata.op(i).height=procdata.op(i).height-z_ref;
					elseif (procdata.op(ref_check).Xaxis=='PosX')&(procdata.op(ref_check).Yaxis=='PosZ')
						for j=1:r
							procdata.op(i).coord(j,1)=procdata.op(i).coord(j,1)-x_ref;
							procdata.op(i).coord(j,2)=procdata.op(i).coord(j,2)-z_ref;
						end
						procdata.op(i).height=procdata.op(i).height-y_ref;
					elseif (procdata.op(ref_check).Xaxis=='PosY')&(procdata.op(ref_check).Yaxis=='PosZ')
						for j=1:r
							procdata.op(i).coord(j,1)=procdata.op(i).coord(j,1)-y_ref;
							procdata.op(i).coord(j,2)=procdata.op(i).coord(j,2)-z_ref;
						end
						procdata.op(i).height=procdata.op(i).height-x_ref;
					end
				case 'point'
					if (procdata.op(ref_check).Xaxis=='PosX')&(procdata.op(ref_check).Yaxis=='PosY')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-x_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-y_ref;
						procdata.op(i).height=procdata.op(i).height-z_ref;
					elseif (procdata.op(ref_check).Xaxis=='PosX')&(procdata.op(ref_check).Yaxis=='PosZ')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-x_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-z_ref;
						procdata.op(i).height=procdata.op(i).height-y_ref;
					elseif (procdata.op(ref_check).Xaxis=='PosY')&(procdata.op(ref_check).Yaxis=='PosZ')
						procdata.op(i).coord(1)=procdata.op(i).coord(1)-y_ref;
						procdata.op(i).coord(2)=procdata.op(i).coord(2)-z_ref;
						procdata.op(i).height=procdata.op(i).height-x_ref;
					end	
				end
			end
		end
	end
end