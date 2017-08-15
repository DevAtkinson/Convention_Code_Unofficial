function field=field_format(procdata_in,varargin)
	% this function applies the operations created in the GUI to output fields containing the processed data from the imported data files
	% for procdata_in either input the output file from the gui or the procdata variable
	%
	% To change which operations are applied use 'which operations' followed by a vector containing ones and zeros
	% to enforce which operations are to be applied. The vectore must have the same amount of entries as there are 
	% operations.
	%
	% To open a file other than the one opened in the GUI use options 'filename' followed by the files name as a 
	% string and 'pathname' followed by the path to the folder containg the file. Pathname should end with a '\'.
	%
	% To remove rigid body motions input the option 'RBM' followed by a 1. 0 will disable RBM removal.
	if ischar(procdata_in) %if procdata_in is a file
		load(procdata_in)
	else
		procdata=procdata_in;
	end
	%____________________________________________assigning additional options to their variables
	does_check=0;
	filename_check=0;
	pathname_check=0;
	if nargin>1
		for i=1:nargin/2
			if findstr(varargin{i*2-1},'which operations')
				does=varargin{i*2};
				does_check=1;
			elseif findstr(varargin{i*2-1},'filename')
				filename=varargin{i*2};
				filename_check=1;
			elseif findstr(varargin{i*2-1},'pathname')
				pathname=varargin{i*2};
				pahtname_check=1;
			elseif findstr(varargin{i*2-1},'RBM')
				procdata.RBM=varargin{i*2};
			end
		end
	end
	if (does_check==0)&(procdata.which_operations~=-1)
		does=procdata.which_operations;
	elseif (does_check==0)&(procdata.which_operations==-1) %if no operations have been set to be applied then all will be (default)
		does=ones(1,procdata.current);
	end
	if filename_check==0
		filename=procdata.filename;
	end
	if pathname_check==0
		pathname=procdata.pathname;
	end


	if length(does)~=procdata.current
		fprintf('~ There is a mismatch between the amount of operations and the matrix specifying which ones to implement\n');
	end

	%_____________________________load data
	%check if file name contains .dat file extension
	[field,procdata]=import_data(procdata,filename,pathname);
	field.crop.check='n';
	%____________________________manipulate fields

	mask_check=0;
	mask_count=0;
	roi_count=0;
	ref_count=0;
	crop_count=0;
	for i=1:procdata.current
		switch procdata.op(i).act % count how many instances of the various processes there are
			case 'crop'
				if does(i)==1
					crop_count=crop_count+1;
				end
				mask_check2(i)=0;
			case 'ref'
				if does(i)==1
					ref_count=ref_count+1;
				end
				mask_check2(i)=0;
			case 'mask'
				if does(i)==1
					mask_count=mask_count+1;
				end
				mask_check2(i)=0;
			case 'roi'
				if does(i)==1
					roi_count=roi_count+1;
				end
				mask_check2(i)=0;
			end
	end

	for i=1:procdata.current
		if does(i)==1
			switch procdata.op(i).act
				case 'crop'
					switch procdata.op(i).shape
					case 'rectangle'
						mask=immask_rect(procdata,i,field);
						[uselssfield,limits]=apply_crop(mask,field,procdata);
					end
				end
		end
	end

	% correct operations height in the case of a crop
	if (procdata.data_type=='DVC')&(exist('uselssfield','var'))
		[y_size,x_size,z_size]=size(uselssfield.PosX);
		for i=1:procdata.current
			if (procdata.op(i).Xaxis=='PosX')&(procdata.op(i).Yaxis=='PosY')
				procdata.op(i).height=procdata.op(i).height - uselssfield.crop.z;
				if (procdata.op(i).height<1)|(procdata.op(i).height>z_size)
					does(i)=0;
				end
			elseif (procdata.op(i).Xaxis=='PosX')&(procdata.op(i).Yaxis=='PosZ')
				procdata.op(i).height=procdata.op(i).height - uselssfield.crop.y;
				if (procdata.op(i).height<1)|(procdata.op(i).height>y_size)
					does(i)=0;
				end
			elseif (procdata.op(i).Xaxis=='PosY')&(procdata.op(i).Yaxis=='PosZ')
				procdata.op(i).height=procdata.op(i).height - uselssfield.crop.x;
				if (procdata.op(i).height<1)|(procdata.op(i).height>x_size)
					does(i)=0;
				end
			end				
		end
	end

	for i=1:procdata.current
		if does(i)==1
			switch procdata.op(i).act
				case 'mask'
					switch procdata.op(i).shape
					case 'rectangle'
						mask_check=i;
						operation(i).mask=immask_rect(procdata,i,field);
						mask_check2(i)=1;
						if crop_count>0
							operation(i).mask=fix_mask_size_from_crop(operation(i).mask,limits,procdata);
						end
					case 'polygon'
						mask_check=i;
						operation(i).mask=immask_poly(procdata,i,field);
						mask_check2(i)=1;
						if crop_count>0
							operation(i).mask=fix_mask_size_from_crop(operation(i).mask,limits,procdata);
						end
					case 'ellipse'
						mask_check=i;
						operation(i).mask=immask_ellipse(procdata,i,field);
						mask_check2(i)=1;
						if crop_count>0
							operation(i).mask=fix_mask_size_from_crop(operation(i).mask,limits,procdata);
						end
					end
				case 'roi'
					switch procdata.op(i).shape
					case 'rectangle'
						mask_check=i;
						operation(i).mask=immask_rect(procdata,i,field);
						mask_check2(i)=1;
						if crop_count>0
							operation(i).mask=fix_mask_size_from_crop(operation(i).mask,limits,procdata);
						end
					case 'polygon'
						mask_check=i;
						operation(i).mask=immask_poly(procdata,i,field);
						mask_check2(i)=1;
						if crop_count>0
							operation(i).mask=fix_mask_size_from_crop(operation(i).mask,limits,procdata);
						end
					case 'ellipse'
						mask_check=i;
						operation(i).mask=immask_ellipse(procdata,i,field);
						mask_check2(i)=1;
						if crop_count>0
							operation(i).mask=fix_mask_size_from_crop(operation(i).mask,limits,procdata);
						end
					end
				end
		end
	end

	for i=1:procdata.current
		if does(i)==0
			switch procdata.op(i).act
				case 'mask'
					switch procdata.op(i).shape
					case 'rectangle'
						mask_check2(i)=0;
					case 'polygon'
						mask_check2(i)=0;
					case 'ellipse'
						mask_check2(i)=0;
					end
				case 'roi'
					switch procdata.op(i).shape
					case 'rectangle'
						mask_check2(i)=0;
					case 'polygon'
						mask_check2(i)=0;
					case 'ellipse'
						mask_check2(i)=0;
					end
				end
		end
	end

	for i=1:procdata.current
		if does(i)==1
			switch procdata.op(i).act
			case 'crop'
				switch procdata.op(i).shape
				case 'rectangle'
					mask=immask_rect(procdata,i,field);
					if procdata.data_type=='DIC'
						[r1,c1]=size(field.uX);
					elseif procdata.data_type=='DVC'
						[r1,c1,k1]=size(field.uX);
					end
					[field,limits]=apply_crop(mask,field,procdata);
					if procdata.data_type=='DIC'
						[r2,c2]=size(field.uX);
						fprintf('~ The matrix of data has been reduced from a %d by %d to a %d by %d matrix\n',r1,c1,r2,c2);
					elseif procdata.data_type=='DVC'
						[r2,c2,k2]=size(field.uX);
						fprintf('~ The matrix of data has been reduced from a %d by %d by %d to a %d by %d by %d matrix\n',r1,c1,k1,r2,c2,k2);
					end
					mask_check2(i)=0;
				end
			end
		end
	end 

	for i=1:procdata.current
		if does(i)==1
			switch procdata.op(i).act
			case 'ref'
				switch procdata.op(i).shape
				case 'point'
					field=refference_point(procdata,i,field);
					mask_check2(i)=0;
				end
			end
		end
	end

	if findstr(procdata.data_type,'DIC')>0
		if mask_check>0
			[r_size,c_size]=size(operation(mask_check).mask);
			mask=ones(r_size,c_size);
			for i=1:procdata.current
				if mask_check2(i)==1
					mask=mask.*operation(i).mask;
				end
			end
			field.uX=field.uX.*mask;
			field.uY=field.uY.*mask;
			field.uZ=field.uZ.*mask;
			if procdata.RBM==1
				field=remove_RBM(procdata,field);
			end
		end
	elseif findstr(procdata.data_type,'DVC')>0
		if mask_check>0
			[r_size,c_size,v_size]=size(operation(mask_check).mask);
			mask=ones(r_size,c_size,v_size);
			for i=1:procdata.current
				% size(operation(i).mask)
				if mask_check2(i)==1
					mask=mask.*operation(i).mask;
				end
			end
			field.uX=field.uX.*mask;
			field.uY=field.uY.*mask;
			field.uZ=field.uZ.*mask;
			if procdata.RBM==1
				field=remove_RBM(procdata,field);
			end
		end
	end

	% change the output variables to have the same names used by most of Matt Malteno's codes
	field_temp=field;
	clear field.uX field.uY field.uZ field.PosX field.PosY field.PosZ
	field.UX=field_temp.uX;
	field.UY=field_temp.uY;
	field.UZ=field_temp.uZ;
	field.POSX=field_temp.PosX;
	field.POSY=field_temp.PosY;
	field.POSZ=field_temp.PosZ;
	if (~isnan(field.POSX(1,1,1)))&(~isnan(field.POSX(1,2,1)))
		field.gridspacing=field.POSX(1,2,1)-field.POSX(1,1,1);
	else 
		[r,c]=size(field.POSX);
		field.gridspacing=field.POSX(floor(r/2),floor(c/2)+1,1)-field.POSX(floor(r/2),floor(c/2),1);
	end

end

%function to import the data from the data file to process
function [field,procdata,other_fields]=import_data(procdata,filename,pathname)
	l=length(pathname);
	%if pahtname doesn't end in backslash
	if ispc
		if pathname(l)~='\' % assuming windows 
			pahtname(l+1)='\';
		end
	elseif isunix
		if pathname(l)~='/'
			pathname(l+1)='/'
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
		        field=output_other_fields(field_got,useless_field);
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
		        field=output_other_fields(field_got,useless_field);
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
	        field=output_other_fields(field_got,useless_field);
	        field.PosX=field_got.POSX;
	        field.PosY=field_got.POSY;
	        field.PosZ=field_got.POSZ;
	        field.uX=field_got.UX;
	        field.uY=field_got.UY;
	        field.uZ=field_got.UZ;

	        fprintf('Rearanging the DVC data for display purposes...')
            field.PosX_c=Correct_DVC_data(field_got.POSX);
            field.PosY_c=Correct_DVC_data(field_got.POSY);
            field.PosZ_c=Correct_DVC_data(field_got.POSZ);
            field.uX_c=Correct_DVC_data(field_got.UX);
            field.uY_c=Correct_DVC_data(field_got.UY);
            field.uZ_c=Correct_DVC_data(field_got.UZ);
            fprintf('done\n')

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
	    field.PosX=fieldfem.POSX;
	    field.PosY=fieldfem.POSY;
	    field.PosZ=fieldfem.POSZ;
	    field.uX=fieldfem.UX;
	    field.uY=fieldfem.UY;
	    field.uZ=fieldfem.UZ;
	end
end

%function to assign other fields to a structure variable so that they are available to the user
%(useless_field contains outputs from Davis that would typically not be of importance)
function [out]=output_other_fields(field,useless_field)
	field_a=fieldnames(field);
	field_b=fieldnames(useless_field);

	out=field;
	for i=1:max(size(field_b))
		%make sure none of the existing fields are altered
		for j=1:max(size(field_a))
			if findstr(field_a{j},field_b{i})>0
				check=1;
			else
				check=0;
			end
		end
		%combine fields into one structure variable
		if check==0
			out.(field_b{i})=useless_field.(field_b{i});
		end
	end
end

% function to create the mask from imrect
function [mask_out]=immask_rect(procdata,ops,field)
	if findstr(procdata.data_type,'DIC')>0
		handles.fig=figure('MenuBar','None');
		handles.axes = axes('Parent',handles.fig ,'Layer' ,'Top');
		imghandle = imagesc(field.PosX(1,:),field.PosY(:,1),field.uY,'Parent',handles.axes);
		ch=imrect(handles.axes,[procdata.op(ops).coord(1), procdata.op(ops).coord(2), procdata.op(ops).coord(3), procdata.op(ops).coord(4)]);
		mask=createMask(ch);
		close
		if procdata.op(ops).clude=='include'
			mask=double(mask);
			mask(mask==0)=NaN;
			mask_out=mask;
		end
		if procdata.op(ops).clude=='exclude'
			mask=not(mask);
			mask=double(mask);
			mask(mask==0)=NaN;
			mask_out=mask;
		end
	elseif findstr(procdata.data_type,'DVC')>0
		handles.fig=figure('MenuBar','None');
		handles.axes = axes('Parent',handles.fig ,'Layer' ,'Top');
		mask_out_temp=zeros(procdata.zmax,procdata.ymax,procdata.xmax);
		if (procdata.op(ops).Xaxis=='PosX')&(procdata.op(ops).Yaxis=='PosY')
			x_tick=sort([field.PosX(1,1,1),field.PosX(1,end,1)]);
            y_tick=sort([field.PosY(1,1,1),field.PosY(end,1,1)]);
            dispX(:,:)=squeeze(field.uX(:,:,procdata.zheight));
			imghandle = imagesc(x_tick,y_tick,dispX,'Parent',handles.axes);
			set(gca,'YDir','normal')
			ch=imrect(handles.axes,[procdata.op(ops).coord(1), procdata.op(ops).coord(2), procdata.op(ops).coord(3), procdata.op(ops).coord(4)]);
			mask=createMask(ch);
			close
			% mask_out=ones(procdata.ymax,procdata.xmax,procdata.zmax);
			for i=1:procdata.zmax
				if (i>=procdata.op(ops).mask_range(1))&(i<=procdata.op(ops).mask_range(2))
					mask_out_temp(i,:,:)=mask;
				end
			end
		elseif (procdata.op(ops).Xaxis=='PosX')&(procdata.op(ops).Yaxis=='PosZ')
			x_tick=sort([field.PosX(1,1,1),field.PosX(1,end,1)]);
            y_tick=sort([field.PosZ(1,1,1),field.PosZ(1,1,end)]);
            dispY(:,:)=squeeze(field.uY_c(:,procdata.yheight,:));
            imghandle =imagesc(x_tick,y_tick,dispY);
            set(gca,'YDir','normal')
            ch=imrect(handles.axes,[procdata.op(ops).coord(1), procdata.op(ops).coord(2), procdata.op(ops).coord(3), procdata.op(ops).coord(4)]);
			mask=createMask(ch);
			close
			% mask_out=ones(procdata.ymax,procdata.xmax,procdata.zmax);
			for i=1:procdata.ymax
				if (i>=procdata.op(ops).mask_range(1))&(i<=procdata.op(ops).mask_range(2))
					mask_out_temp(:,i,:)=mask;
				end
			end
		elseif (procdata.op(ops).Xaxis=='PosY')&(procdata.op(ops).Yaxis=='PosZ')
			x_tick=sort([field.PosY(1,1,1),field.PosY(end,1,1)]);
            y_tick=sort([field.PosZ(1,1,1),field.PosZ(1,1,end)]);
            dispY(:,:)=squeeze(field.uY_c(:,:,procdata.xheight));
            imghandle =imagesc(x_tick,y_tick,dispY);
            set(gca,'YDir','normal')
            ch=imrect(handles.axes,[procdata.op(ops).coord(1), procdata.op(ops).coord(2), procdata.op(ops).coord(3), procdata.op(ops).coord(4)]);
			mask=createMask(ch);
			close
			% mask_out=ones(procdata.ymax,procdata.xmax,procdata.zmax);
			for i=1:procdata.xmax
				if (i>=procdata.op(ops).mask_range(1))&(i<=procdata.op(ops).mask_range(2))
					mask_out_temp(:,:,i)=mask;
				end
			end
		end
		if procdata.op(ops).clude=='include'
			mask_out=double(mask_out_temp);
			mask_out(mask_out==0)=NaN;
			mask_out=ReCorrect_DVC_data(mask_out);
		end
		if procdata.op(ops).clude=='exclude'
			mask_out=not(mask_out_temp);
			mask_out=double(mask_out);
			mask_out(mask_out==0)=NaN;
			mask_out=ReCorrect_DVC_data(mask_out);
		end
	end
end

% function to create the mask from imellipse
function [mask_out]=immask_ellipse(procdata,ops,field)
	if findstr(procdata.data_type,'DIC')>0
		handles.fig=figure('MenuBar','None');
		handles.axes = axes('Parent',handles.fig ,'Layer' ,'Top');
		imghandle = imagesc(field.PosX(1,:),field.PosY(:,1),field.uY,'Parent',handles.axes);
		ch=imellipse(handles.axes,[procdata.op(ops).coord(1), procdata.op(ops).coord(2), procdata.op(ops).coord(3), procdata.op(ops).coord(4)]);
		mask=createMask(ch);
		close
		if procdata.op(ops).clude=='include'
			mask=double(mask);
			mask(mask==0)=NaN;
			mask_out=mask;
		end
		if procdata.op(ops).clude=='exclude'
			mask=not(mask);
			mask=double(mask);
			mask(mask==0)=NaN;
			mask_out=mask;
		end
	elseif findstr(procdata.data_type,'DVC')>0
		handles.fig=figure('MenuBar','None');
		handles.axes = axes('Parent',handles.fig ,'Layer' ,'Top');
		mask_out_temp=zeros(procdata.zmax,procdata.ymax,procdata.xmax);
		if (procdata.op(ops).Xaxis=='PosX')&(procdata.op(ops).Yaxis=='PosY')
			x_tick=sort([field.PosX(1,1,1),field.PosX(1,end,1)]);
            y_tick=sort([field.PosY(1,1,1),field.PosY(end,1,1)]);
            dispX(:,:)=squeeze(field.uX(:,:,procdata.zheight));
			imghandle = imagesc(x_tick,y_tick,dispX,'Parent',handles.axes);
			set(gca,'YDir','normal')
			ch=imellipse(handles.axes,[procdata.op(ops).coord(1), procdata.op(ops).coord(2), procdata.op(ops).coord(3), procdata.op(ops).coord(4)]);
			mask=createMask(ch);
			close
			% mask_out=ones(procdata.ymax,procdata.xmax,procdata.zmax);
			for i=1:procdata.zmax
				if (i>=procdata.op(ops).mask_range(1))&(i<=procdata.op(ops).mask_range(2))
					mask_out_temp(i,:,:)=mask;
				end
			end
		elseif (procdata.op(ops).Xaxis=='PosX')&(procdata.op(ops).Yaxis=='PosZ')
			x_tick=sort([field.PosX(1,1,1),field.PosX(1,end,1)]);
            y_tick=sort([field.PosZ(1,1,1),field.PosZ(1,1,end)]);
            dispY(:,:)=squeeze(field.uY_c(:,procdata.yheight,:));
            imghandle =imagesc(x_tick,y_tick,dispY);
            set(gca,'YDir','normal')
            ch=imellipse(handles.axes,[procdata.op(ops).coord(1), procdata.op(ops).coord(2), procdata.op(ops).coord(3), procdata.op(ops).coord(4)]);
			% mask=transpose(createMask(ch));
			% mask=Recorrect_DVC_mask(createMask(ch));
			mask=createMask(ch);
			close
			% mask_out=ones(procdata.ymax,procdata.xmax,procdata.zmax);
			for i=1:procdata.ymax
				if (i>=procdata.op(ops).mask_range(1))&(i<=procdata.op(ops).mask_range(2))
					mask_out_temp(:,i,:)=mask;
				end
			end
		elseif (procdata.op(ops).Xaxis=='PosY')&(procdata.op(ops).Yaxis=='PosZ')
			x_tick=sort([field.PosY(1,1,1),field.PosY(end,1,1)]);
            y_tick=sort([field.PosZ(1,1,1),field.PosZ(1,1,end)]);
            dispY(:,:)=squeeze(field.uY_c(:,:,procdata.xheight));
            imghandle=imagesc(x_tick,y_tick,dispY)
            set(gca,'YDir','normal')
            ch=imellipse(handles.axes,[procdata.op(ops).coord(1), procdata.op(ops).coord(2), procdata.op(ops).coord(3), procdata.op(ops).coord(4)]);
			mask=createMask(ch);
			close
			% mask_out=ones(procdata.ymax,procdata.xmax,procdata.zmax);
			for i=1:procdata.xmax
				if (i>=procdata.op(ops).mask_range(1))&(i<=procdata.op(ops).mask_range(2))
					mask_out_temp(:,:,i)=mask;
				end
			end
		end
		if procdata.op(ops).clude=='include'
			mask_out=double(mask_out_temp);
			mask_out(mask_out==0)=NaN;
			mask_out=ReCorrect_DVC_data(mask_out);
		end
		if procdata.op(ops).clude=='exclude'
			mask_out=not(mask_out_temp);
			mask_out=double(mask_out);
			mask_out(mask_out==0)=NaN;
			mask_out=ReCorrect_DVC_data(mask_out);
		end
	end
end

%function to create a mask from impoly
function [mask_out]=immask_poly(procdata,ops,field)
	if findstr(procdata.data_type,'DIC')>0
		coord_length=length(procdata.op(ops).coord);
		% for i=1:coord_length/2
		% 	N(i,1)=procdata.op(ops).coord(i*2-1);
		% 	N(i,2)=procdata.op(ops).coord(i*2);
		% end
		handles.fig=figure('MenuBar','None');
		handles.axes = axes('Parent',handles.fig ,'Layer' ,'Top');
		imghandle = imagesc(field.PosX(1,:),field.PosY(:,1),field.uY,'Parent',handles.axes);
		ch=impoly(handles.axes,procdata.op(ops).coord);
		mask=createMask(ch);
		close
		if procdata.op(ops).clude=='include'
			mask=double(mask);
			mask(mask==0)=NaN;
			mask_out=mask;
		end
		if procdata.op(ops).clude=='exclude'
			mask=not(mask);
			mask=double(mask);
			mask(mask==0)=NaN;
			mask_out=mask;
		end
	elseif findstr(procdata.data_type,'DVC')>0
		coord_length=length(procdata.op(ops).coord);
		% for i=1:coord_length/2
		% 	N(i,1)=procdata.op(ops).coord(i*2-1);
		% 	N(i,2)=procdata.op(ops).coord(i*2);
		% end
		handles.fig=figure('MenuBar','None');
		handles.axes = axes('Parent',handles.fig ,'Layer' ,'Top');
		mask_out_temp=zeros(procdata.zmax,procdata.ymax,procdata.xmax);
		if (procdata.op(ops).Xaxis=='PosX')&(procdata.op(ops).Yaxis=='PosY')
			x_tick=sort([field.PosX(1,1,1),field.PosX(1,end,1)]);
            y_tick=sort([field.PosY(1,1,1),field.PosY(end,1,1)]);
            dispX(:,:)=squeeze(field.uX(:,:,procdata.zheight));
			imghandle = imagesc(x_tick,y_tick,dispX,'Parent',handles.axes);
			set(gca,'YDir','normal')
			ch=impoly(handles.axes,procdata.op(ops).coord);
			mask=createMask(ch);
			close
			% mask_out=ones(procdata.ymax,procdata.xmax,procdata.zmax);
			for i=1:procdata.zmax
				if (i>=procdata.op(ops).mask_range(1))&(i<=procdata.op(ops).mask_range(2))
					mask_out_temp(i,:,:)=mask;
				end
			end
		elseif (procdata.op(ops).Xaxis=='PosX')&(procdata.op(ops).Yaxis=='PosZ')
			x_tick=sort([field.PosX(1,1,1),field.PosX(1,end,1)]);
            y_tick=sort([field.PosZ(1,1,1),field.PosZ(1,1,end)]);
            dispY(:,:)=squeeze(field.uY_c(:,procdata.yheight,:));
            imghandle =imagesc(x_tick,y_tick,dispY);
            set(gca,'YDir','normal')
            ch=impoly(handles.axes,procdata.op(ops).coord);
			mask=createMask(ch);
			close
			% mask_out=ones(procdata.ymax,procdata.xmax,procdata.zmax);
			for i=1:procdata.ymax
				if (i>=procdata.op(ops).mask_range(1))&(i<=procdata.op(ops).mask_range(2))
					mask_out_temp(:,i,:)=mask;
				end
			end
		elseif (procdata.op(ops).Xaxis=='PosY')&(procdata.op(ops).Yaxis=='PosZ')
			x_tick=sort([field.PosY(1,1,1),field.PosY(end,1,1)]);
            y_tick=sort([field.PosZ(1,1,1),field.PosZ(1,1,end)]);
            dispY(:,:)=squeeze(field.uY_c(:,:,procdata.xheight));
            imghandle = imagesc(x_tick,y_tick,dispY,'Parent',handles.axes);
            set(gca,'YDir','normal')
            ch=impoly(handles.axes,procdata.op(ops).coord);
			mask=createMask(ch);
			close
			% mask_out=ones(procdata.ymax,procdata.xmax,procdata.zmax);
			for i=1:procdata.xmax
				if (i>=procdata.op(ops).mask_range(1))&(i<=procdata.op(ops).mask_range(2))
					mask_out_temp(:,:,i)=mask;
				end
			end
		end
		if procdata.op(ops).clude=='include'
			mask_out=double(mask_out_temp);
			mask_out(mask_out==0)=NaN;
			mask_out=ReCorrect_DVC_data(mask_out);
		end
		if procdata.op(ops).clude=='exclude'
			mask_out=not(mask_out_temp);
			mask_out=double(mask_out);
			mask_out(mask_out==0)=NaN;
			mask_out=ReCorrect_DVC_data(mask_out);
		end
	end
end

%function to change the position of the reference point
function field=refference_point(procdata,ops,field)
	if procdata.data_type=='DIC'
		x_ref=procdata.op(ops).coord(1);
		y_ref=procdata.op(ops).coord(2);
		field.PosX=field.PosX-x_ref;
		field.PosY=field.PosY-y_ref;
	elseif procdata.data_type=='DVC'
		if (procdata.op(ops).Xaxis=='PosX')&(procdata.op(ops).Yaxis=='PosY')
			x_ref=procdata.op(ops).coord(1);
			y_ref=procdata.op(ops).coord(2);
			z_ref=field.PosZ(1,1,procdata.op(ops).height);
		elseif (procdata.op(ops).Xaxis=='PosX')&(procdata.op(ops).Yaxis=='PosZ')
			x_ref=procdata.op(ops).coord(1);
			y_ref=field.PosY(procdata.op(ops).height,1,1);
			z_ref=procdata.op(ops).coord(2);
		elseif (procdata.op(ops).Xaxis=='PosY')&(procdata.op(ops).Yaxis=='PosZ')
			x_ref=field.PosX(1,procdata.op(ops).height,1);
			y_ref=procdata.op(ops).coord(1);
			z_ref=procdata.op(ops).coord(2);
		end
		field.PosX=field.PosX-x_ref;
		field.PosY=field.PosY-y_ref;
		field.PosZ=field.PosZ-z_ref;
	end
end

% function to remove rigid body motions
function [field]=remove_RBM(procdata,field)
	if  procdata.data_type=='DIC'
    	PosX=field.PosX;
        PosY=field.PosY;
        PosZ=field.PosZ;
        uX=field.uX;
        uY=field.uY;
        uZ=field.uZ;
        [uX,uY,uZ,rbmaf]=remove_rbm(PosX,PosY,PosZ,uX,uY,uZ);
        field.uX=uX;
        field.uY=uY;
        field.uZ=uZ;
        field.rbm=rbmaf;
    elseif procdata.data_type=='DVC'
       	procdata.RBM='yes';
        [field.PosX,field.PosY,field.PosZ,field.uX,field.uY,field.uZ,eulerAngles,rotCentre,RBD] = RBMCorr(field.PosX,field.PosY,field.PosZ,field.uX,field.uY,field.uZ);
    end
end

% function to crop the fields according to a crop input
function [field,limits]=apply_crop(mask,field,procdata)
	field.crop.check='y';
	switch procdata.data_type
	case 'DIC'
		[r,c]=size(field.uX);
		for i=1:r
			for j=1:c
				if ~isnan(mask(i,j))
					valid_c=j;
					valid_r=i;
				end
			end
		end
		check=0;
		r_top=1;
		for i=1:r
			if isnan(mask(i,valid_c))&(check==0)
				r_top=i+1;
			elseif ~isnan(mask(i,valid_c))
				check=1;
			end
		end
		check=0;
		r_bot=r;
		for i=1:r
			if isnan(mask(r-i+1,valid_c))&(check==0)
				r_bot=r-i;
			elseif ~isnan(mask(r-i+1,valid_c))
				check=1;
			end
		end
		check=0;
		c_top=1;
		for i=1:c
			if isnan(mask(valid_r,i))&(check==0)
				c_top=i+1;
			elseif ~isnan(mask(valid_r,i))
				check=1;
			end
		end
		check=0;
		c_bot=c;
		for i=1:c
			if isnan(mask(valid_r,c-i+1))&(check==0)
				c_bot=c-i;
			elseif ~isnan(mask(valid_r,c-i+1))
				check=1;
			end
		end

		field_temp=field;
		clear field.uX field.uY field.uZ field.PosX field.PosY field.PosZ
		% r_top
		% r_bot
		% c_top
		% c_bot
		field.uX=field_temp.uX(r_top:r_bot,c_top:c_bot);
		field.uY=field_temp.uY(r_top:r_bot,c_top:c_bot);
		field.uZ=field_temp.uZ(r_top:r_bot,c_top:c_bot);
		field.PosX=field_temp.PosX(r_top:r_bot,c_top:c_bot);
		field.PosY=field_temp.PosY(r_top:r_bot,c_top:c_bot);
		field.PosZ=field_temp.PosZ(r_top:r_bot,c_top:c_bot);
		limits=[r_top,r_bot,c_top,c_bot];
	case 'DVC'
		[r,c,v]=size(field.uX);
		for i=1:r
			for j=1:c
				for k=1:v
					if ~isnan(mask(i,j,k))
						valid_r=i;
						valid_c=j;
						valid_v=k;
					end
				end
			end
		end
		check=0;
		r_top=1;
		for i=1:r
			if isnan(mask(i,valid_c,valid_v))&(check==0)
				r_top=i+1;
			elseif ~isnan(mask(i,valid_c,valid_v))
				check=1;
			end
		end
		check=0;
		r_bot=r;
		for i=1:r
			if isnan(mask(r-i+1,valid_c,valid_v))&(check==0)
				r_bot=r-i;
			elseif ~isnan(mask(r-i+1,valid_c,valid_v))
				check=1;
			end
		end
		check=0;
		c_top=1;
		for i=1:c
			if isnan(mask(valid_r,i,valid_v))&(check==0)
				c_top=i+1;
			elseif ~isnan(mask(valid_r,i,valid_v))
				check=1;
			end
		end
		check=0;
		c_bot=c;
		for i=1:c
			if isnan(mask(valid_r,c-i+1,valid_v))&(check==0)
				c_bot=c-i;
			elseif ~isnan(mask(valid_r,c-i+1,valid_v))
				check=1;
			end
		end
		check=0;
		v_top=1;
		for i=1:v
			if isnan(mask(valid_r,valid_c,i))&(check==0)
				v_top=i+1;
			elseif ~isnan(mask(valid_r,valid_c,i))
				check=1;
			end
		end
		check=0;
		v_bot=v;
		for i=1:v
			if isnan(mask(valid_r,valid_c,v-i+1))&(check==0)
				v_bot=v-i;
			elseif ~isnan(mask(valid_r,valid_c,v-i+1))
				check=1;
			end
		end
		field_temp=field;
		clear field.uX field.uY field.uZ field.PosX field.PosY field.PosZ
		field.uX=field_temp.uX(r_top:r_bot,c_top:c_bot,v_top:v_bot);
		field.uY=field_temp.uY(r_top:r_bot,c_top:c_bot,v_top:v_bot);
		field.uZ=field_temp.uZ(r_top:r_bot,c_top:c_bot,v_top:v_bot);
		field.PosX=field_temp.PosX(r_top:r_bot,c_top:c_bot,v_top:v_bot);
		field.PosY=field_temp.PosY(r_top:r_bot,c_top:c_bot,v_top:v_bot);
		field.PosZ=field_temp.PosZ(r_top:r_bot,c_top:c_bot,v_top:v_bot);
		% field.PosX_c=Correct_DVC_data(field.PosX);
		% field.PosY_c=Correct_DVC_data(field.PosY);
		% field.PosZ_c=Correct_DVC_data(field.PosZ);
		% field.uX_c=Correct_DVC_data(field.uX);
		% field.uY_c=Correct_DVC_data(field.uY);
		% field.uZ_c=Correct_DVC_data(field.uZ);
        field.crop.y=r_top;
        field.crop.x=c_top;
        field.crop.z=v_top;
		limits=[r_top,r_bot,c_top,c_bot,v_top,v_bot];
	end
end

% function to fix the mask size if there is a crop applied
function mask_out=fix_mask_size_from_crop(mask,limits,procdata)
	switch procdata.data_type
	case 'DIC'
		mask_out=mask(limits(1):limits(2),limits(3):limits(4));
	case 'DVC'
		mask_out=mask(limits(1):limits(2),limits(3):limits(4),limits(5):limits(6));
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

% Function to undo the alternative way of storing DVC data
function [out]=ReCorrect_DVC_data(it)
    [z_size,y_size,x_size]=size(it);
    out=zeros(y_size,x_size,z_size);
    for i=1:z_size
        out(:,:,i)=it(i,:,:);
    end
end

% function [out]=Recorrect_DVC_mask(it)
% 	[x_size,y_size]=size(it);
% 	out=zeros(y_size,x_size);
% 	for i=1:x_size
% 		for j=1:y_size
% 			out(j,i)=it(i,j);
% 		end
% 	end
% end