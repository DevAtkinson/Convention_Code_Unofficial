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