function test(procdata_in)
if ischar(procdata_in) %if procdata_in is a file
		warning off
		load(procdata_in)
		close all
		warning on
	else
		procdata=procdata_in;
	end
scrsz = get(0,'ScreenSize');
handles.fig = figure('MenuBar','None','Position',[(scrsz(3)-300)/2 (scrsz(4)-600)/2 800 800]);
% [field,procdata]=import_data(procdata,procdata.filename,procdata.pathname);
		set(handles.fig, 'Name', 'Display operations');
		axes1=axes('Parent',handles.fig,'Layer' ,'Top','Units','pixels','Position',[90,70,300,300]);
		axes2=axes('Parent',handles.fig,'Layer' ,'Top','Units','pixels','Position',[90,440,300,300]);
		axes3=axes('Parent',handles.fig,'Layer' ,'Top','Units','pixels','Position',[480,440,300,300]);
		[field_original,~]=import_data(procdata,procdata.filename,procdata.pathname);
		field=field_format(procdata,'which operations',[1,0]);
		field.POSX_locked=field_original.POSX;
		field.POSY_locked=field_original.POSY;
		field.POSZ_locked=field_original.POSZ;
		if procdata.data_type=='DVC'
	        field.POSX_c=Correct_DVC_data(field.PosX);
	        field.POSY_c=Correct_DVC_data(field.PosY);
	        field.POSZ_c=Correct_DVC_data(field.PosZ);
	        field.UX_c=Correct_DVC_data(field.uX);
	        field.UY_c=Correct_DVC_data(field.uY);
	        field.UZ_c=Correct_DVC_data(field.uZ);
		end
		display_on_axes(procdata,field,[1,0],axes2,'PosX','PosZ',10,1,'uY')
		display_on_axes(procdata,field,[1,0],axes1,'PosX','PosY',10,1,'uY')
		display_on_axes(procdata,field,[1,0],axes3,'PosY','PosZ',10,1,'uY')
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