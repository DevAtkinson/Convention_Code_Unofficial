% function to determine whether a mask is fully visible due to cropping
function [out]=is_mask_in_window(num,procdata,field,Xaxis_in,Yaxis_in)
	if field.crop.check=='y'
		if procdata.data_type=='DIC'
			posx_min=min(min(field.POSX));
			posy_min=min(min(field.POSY));
			posx_max=max(max(field.POSX));
			posy_max=max(max(field.POSY));
			switch procdata.op(num).shape
			case {'rectangle','ellipse'}
				x_low=(procdata.op(num).coord(1)>=posx_min)&(procdata.op(num).coord(1)<=posx_max);
				y_low=(procdata.op(num).coord(2)>=posy_min)&(procdata.op(num).coord(2)<=posy_max);
				x_high=((procdata.op(num).coord(1)+procdata.op(num).coord(3))>=posx_min)&((procdata.op(num).coord(1)+procdata.op(num).coord(3))<=posx_max);
				y_high=((procdata.op(num).coord(2)+procdata.op(num).coord(4))>=posy_min)&((procdata.op(num).coord(2)+procdata.op(num).coord(4))<=posy_max);
				if x_low+x_high+y_low+y_high==4
					out=1;
				else
					out=0;
				end
			case 'polygon'
				[r,c]=size(procdata.op(num).coord);
				summing=0
				for i=1:r
					temp1=(procdata.op(num).coord(i,1)>=posx_min)&(procdata.op(num).coord(i,1)<=posx_max);
					temp2=(procdata.op(num).coord(i,2)>=posy_min)&(procdata.op(num).coord(i,2)<=posy_max);
					summing=summing+temp1+temp2;
				end
				if summing==r*2
					out=1;
				else
					out=0;
				end
			case 'point'
				x_low=(0>=posx_min)&(0<=posx_max);
				y_low=(0>=posy_min)&(0<=posy_max);
				if (x_low+y_low)==2
					out=1;
				else
					out=0;
				end
			end
		elseif procdata.data_type=='DVC'
			posx_min=min(min(min(field.POSX)));
			posy_min=min(min(min(field.POSY)));
			posz_min=min(min(min(field.POSZ)));
			posx_max=max(max(max(field.POSX)));
			posy_max=max(max(max(field.POSY)));
			posz_max=max(max(max(field.POSZ)));
			if (procdata.op(num).Xaxis=='PosX')&(procdata.op(num).Yaxis=='PosY')
				x_min=posx_min;
				x_max=posx_max;
				y_min=posy_min;
				y_max=posy_max;
				z_min=posz_min;
				z_max=posz_max;
			elseif (procdata.op(num).Xaxis=='PosX')&(procdata.op(num).Yaxis=='PosZ')
				x_min=posx_min;
				x_max=posx_max;
				y_min=posz_min;
				y_max=posz_max;
				z_min=posy_min;
				z_max=posy_max;
			elseif (procdata.op(num).Xaxis=='PosY')&(procdata.op(num).Yaxis=='PosZ')
				x_min=posy_min;
				x_max=posy_max;
				y_min=posz_min;
				y_max=posz_max;
				z_min=posx_min;
				z_max=posx_max;
			end
			switch procdata.op(num).shape
			case {'rectangle','ellipse'}
				x_low=(procdata.op(num).coord(1)>=x_min)&(procdata.op(num).coord(1)<=x_max);
				y_low=(procdata.op(num).coord(2)>=y_min)&(procdata.op(num).coord(2)<=y_max);
				x_high=((procdata.op(num).coord(1)+procdata.op(num).coord(3))>=x_min)&((procdata.op(num).coord(1)+procdata.op(num).coord(3))<=x_max);
				y_high=((procdata.op(num).coord(2)+procdata.op(num).coord(4))>=y_min)&((procdata.op(num).coord(2)+procdata.op(num).coord(4))<=y_max);
				if x_low+x_high+y_low+y_high==4
					out=1;
				else
					out=0;
				end
			case 'polygon'
				[r,c]=size(procdata.op(num).coord);
				summing=0
				for i=1:r
					temp1=(procdata.op(num).coord(i,1)>=x_min)&(procdata.op(num).coord(i,1)<=x_max);
					temp2=(procdata.op(num).coord(i,2)>=y_min)&(procdata.op(num).coord(i,2)<=y_max);
					summing=summing+temp1+temp2;
				end
				if summing==r*2
					out=1;
				else
					out=0;
				end
			case 'point'
				% x_low=(procdata.op(num).coord(1)>=x_min)&(procdata.op(num).coord(1)<=x_max);
				% y_low=(procdata.op(num).coord(2)>=y_min)&(procdata.op(num).coord(2)<=y_max);
				x_low=(0>=posx_min)&(0<=posx_max);
				y_low=(0>=posy_min)&(0<=posy_max);
				% need original fields for this check
				% if (procdata.op(num).Xaxis=='PosX')&(procdata.op(num).Yaxis=='PosY')
				% 	z_low=(field.POSZ_locked(1,1,procdata.op(num).height)>=z_min)&(field.POSZ_locked(1,1,procdata.op(num).height)<=z_max);
				% elseif (procdata.op(num).Xaxis=='PosX')&(procdata.op(num).Yaxis=='PosZ')
				% 	z_low=(field.POSY_locked(procdata.op(num).height,1,1)>=z_min)&(field.POSY_locked(procdata.op(num).height,1,1)<=z_max);
				% elseif (procdata.op(num).Xaxis=='PosY')&(procdata.op(num).Yaxis=='PosZ')
				% 	z_low=(field.POSX_locked(1,procdata.op(num).height,1)>=z_min)&(field.POSX_locked(1,procdata.op(num).height,1)<=z_max);
				% end
				if (procdata.op(num).Xaxis=='PosX')&(procdata.op(num).Yaxis=='PosY')
					z_low=(0>=posz_min)&(0<=posz_max);
				elseif (procdata.op(num).Xaxis=='PosX')&(procdata.op(num).Yaxis=='PosZ')
					z_low=(0>=posz_min)&(0<=posz_max);
				elseif (procdata.op(num).Xaxis=='PosY')&(procdata.op(num).Yaxis=='PosZ')
					z_low=(0>=posz_min)&(0<=posz_max);
				end
				if (Xaxis_in=='PosX')&(Yaxis_in=='PosY')
					if ((x_low+y_low)==2)
						out=1;
					else
						out=0;
					end
				end
				if (Xaxis_in=='PosX')&(Yaxis_in=='PosZ')
					if ((x_low+z_low)==2)
						out=1;
					else
						out=0;
					end
				end
				if (Xaxis_in=='PosY')&(Yaxis_in=='PosZ')
					if ((y_low+z_low)==2)
						out=1;
					else
						out=0;
					end
				end
			end
		end
	else
		out=1;
	end
end