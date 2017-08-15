function display_on_axes(procdata,field,does,axis_in,Xaxis_in,Yaxis_in,height_in,disp_mask,contour_in)
	
	if procdata.data_type=='DIC'
		% hAxes = findobj(gcf, 'type' ,'axes');
        x_tick=sort([field.POSX(1,1),field.POSX(1,end)]);
        y_tick=sort([field.POSY(1,1),field.POSY(end,1)]);
        p=procdata;
        p.which_operations=does;
        p=update_masks_from_ref_point(p,field);
        switch procdata.Contour
            case 'uX'
            	axes(axis_in)
                imghandle =imagesc(x_tick,y_tick,field.UX);
                title('uX')
            case 'uY'
            	axes(axis_in)
                imghandle =imagesc(x_tick,y_tick,field.UY);
                title('uY')
            case 'uZ'
            	axes(axis_in)
                imghandle =imagesc(x_tick,y_tick,field.UZ);
                title('uZ')
        end
        set(axes_in,'YDir','normal')
        xlabel('PosX')
        ylabel('PosY')
        axis equal tight
        if disp_mask==1
	        for i=1:procdata.current
	        	if (does(i)==1)&(is_mask_in_window(i,p,field,Xaxis_in,Yaxis_in))
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
    	if (Xaxis_in=='PosX')&(Yaxis_in=='PosY')
			x_tick=sort([field.POSX(1,1,1),field.POSX(1,end,1)]);
       		y_tick=sort([field.POSY(1,1,1),field.POSY(end,1,1)]);
       		switch contour_in
            case 'uX'
                disp_matrix(:,:)=squeeze(field.UX(:,:,height_in));
            case 'uY'
                disp_matrix(:,:)=squeeze(field.UY(:,:,height_in));
            case 'uZ'
                disp_matrix(:,:)=squeeze(field.UZ(:,:,height_in));
        	end
		elseif (Xaxis_in=='PosX')&(Yaxis_in=='PosZ')
			x_tick=sort([field.POSX(1,1,1),field.POSX(1,end,1)]);
        	y_tick=sort([field.POSZ(1,1,1),field.POSZ(1,1,end)]);
        	switch contour_in
            case 'uX'
                disp_matrix(:,:)=squeeze(field.UX_c(:,height_in,:));
            case 'uY'
                disp_matrix(:,:)=squeeze(field.UY_c(:,height_in,:));
            case 'uZ'
                disp_matrix(:,:)=squeeze(field.UZ_c(:,height_in,:));
	        end
		elseif (Xaxis_in=='PosY')&(Yaxis_in=='PosZ')
			x_tick=sort([field.POSY(1,1,1),field.POSY(end,1,1)]);
	        y_tick=sort([field.POSZ(1,1,1),field.POSZ(1,1,end)]);
	        switch contour_in
            case 'uX'
                disp_matrix(:,:)=squeeze(field.UX_c(:,:,height_in));
            case 'uY'
                disp_matrix(:,:)=squeeze(field.UY_c(:,:,height_in));
            case 'uZ'
                disp_matrix(:,:)=squeeze(field.UZ_c(:,:,height_in));
	        end
		end
		p=procdata;
        p.which_operations=does;
        p=update_masks_from_ref_point(p,field);
        axes(axis_in)
        imghandle=imagesc(x_tick,y_tick,disp_matrix);
        set(gca,'YDir','normal')
        title(contour_in)
        xlabel(Xaxis_in)
        ylabel(Yaxis_in)
        if disp_mask==1
        	for i=1:procdata.current
        		if (does(i)==1)&(is_mask_in_window(i,p,field,Xaxis_in,Yaxis_in))
        			if (p.op(i).Xaxis==Xaxis_in)&(p.op(i).Yaxis==Yaxis_in)
        				if (height_in>=min(p.op(i).mask_range))&(height_in<=max(p.op(i).mask_range))
	        				switch p.op(i).shape
	        				case 'rectangle'
	        					p.op(i).handle=imrect(axis_in,[p.op(i).coord(1), p.op(i).coord(2), p.op(i).coord(3), p.op(i).coord(4)]);
		                        if findstr(p.op(i).clude,'include')
		                            setColor(p.op(i).handle,'g')
		                        else
		                            setColor(p.op(i).handle,'r')
		                        end
		                    case 'ellipse'
		                    	p.op(i).handle=imellipse(axis_in,[p.op(i).coord(1), p.op(i).coord(2), p.op(i).coord(3), p.op(i).coord(4)]);
		                        if findstr(p.op(i).clude,'include')
		                            setColor(p.op(i).handle,'g')
		                        else
		                            setColor(p.op(i).handle,'r')
		                        end
		                    case 'polygon'
		                    	p.op(i).handle=impoly(axis_in,p.op(i).coord);
		                        if findstr(p.op(i).clude,'include')
		                            setColor(p.op(i).handle,'g')
		                        else
		                            setColor(p.op(i).handle,'r')
		                        end
		                    case 'point'
		                    	p.op(i).handle=impoint(axis_in,0,0);
		                        if findstr(p.op(i).clude,'include')
		                            setColor(p.op(i).handle,'g')
		                        else
		                            setColor(p.op(i).handle,'r')
		                        end	
	        				end
	        			end
	        		elseif findstr(p.op(i).shape,'point')>0
	        			% if (p.op(i).Xaxis=='PosX')&(p.op(i).Yaxis=='PosY')
	        			% 	x_point=p.op(i).coord(1);
	        			% 	y_point=p.op(i).coord(2);
	        			% 	% z_point=field.POSZ(1,1,p.op(i).height);
	        			% elseif (p.op(i).Xaxis=='PosX')&(p.op(i).Yaxis=='PosZ')
	        			% 	x_point=p.op(i).coord(1);
	        			% 	z_point=p.op(i).coord(2);
	        			% 	% y_point=field.POSY(p.op(i).height,1,1);
	        			% elseif (p.op(i).Xaxis=='PosY')&(p.op(i).Yaxis=='PosZ')
	        			% 	y_point=p.op(i).coord(1);
	        			% 	z_point=p.op(i).coord(2);
	        			% 	% x_point=field.POSX(1,p.op(i).height,1);
        				% end

        				if (Xaxis_in=='PosX')&(Yaxis_in=='PosY')
        					p.op(i).handle=impoint(axis_in,0,0);
        				elseif (Xaxis_in=='PosX')&(Yaxis_in=='PosZ')
							p.op(i).handle=impoint(axis_in,0,0);
        				elseif (Xaxis_in=='PosY')&(Yaxis_in=='PosZ')
							p.op(i).handle=impoint(axis_in,0,0);
        				end

        				if findstr(p.op(i).clude,'include')
	                        setColor(p.op(i).handle,'g')
	                    else
	                        setColor(p.op(i).handle,'r')
	                    end
        			end
        		end
        	end
        end
    end
end

