function example_code
	% This code is suppose to give the user an idea of how to create the masks
	% without using the GUI. This will allow users to automate the process over
	% multiple images in order to mask a set of images with identical masks.

	% First create the struct with main variable name procdata (stands for "processing data").
	% You can do this by assigning the image name to procdata. Not it must be assigned as a string.
	procdata.filename='B00005.vc7'; % you can try .vc7 or .dat (both are included in the "Example_data" folder)
	% Next you need to assign a variable pathname which contains the path to the above image.
	current_path=pwd;
	addpath(current_path);
	procdata.pathname=strcat(current_path,'\Example_data\DIC_2D\');
	% C:\Users\devan\Holiday_work\During semester\Final\online\Example_data\DIC_2D
	% procdata.pathname='C:\Users\devan\Holiday_work\example_data\DIC_2D\Example Data_Elongated CT sample (2D)\';
	% Then you need to tell the program what data type it is (DIC, DVC, FEM)
	% (At the moment the program works only for DIC data.)
	procdata.data_type='DIC';
	% Thereafter the type of DIC data must be specified (2D or 3D-stereovision)
	procdata.dic_type='2D';
	% The program needs to know whether you want to remove rigid body motions.
	% Assigning a value of 0 means that no RBM should be removed whereas a value
	% of 1 will remove them.
	procdata.RBM='0';
	% Next the following vairables need to be set to 1. They are intended for use with DVC
	% data so dont worry about them.
	procdata.zheight=1;
	procdata.yheight=1;
	procdata.xheight=1;

	% Now it is time to create the perform operations on the data.
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Masking
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% There are 4 operations that can be applied to the data, these are:
	% > Cropping - 	This removes data around the specimens outer perimeter that contains
	%				no relevant information. The shape of the crop is always rectangular 
	%				since the data outside of the crop is disregarded and the size of 
	% 				matrices are reduced to the size contained within the crop.
	% > Mask -		Masking creates masks with ones at points considered to be relevant 
	%				and NaNs for points outside of the mask. Masks can be applied in the
	%				shape of rectangles, ellipses and polygons. Masks can be set to
	% 				include or exclude the region selected. The default is to include.
	% > ROI - 		A region of interest can be selected. This is exactly the same as a
	% 				mask in terms of programming but it is designed to select regions that
	% 				are of interest whereas masking should be used to remove areas 
	% 				containing invalid data.
	% > Ref.Point - A reference point is used to change the postion of the origin in the 
	% 				position data in the variables POSX, POSY and POSZ. Only one reference
	% 				point can be active at a time but multiple can be created. If you do not
	% 			 	specify which one is to be active then the last one in the list will be 
	% 				set as active.
	%
	% The shapes of these operations are based on Matlabs imrect, impoly, imellipse and impoint
	% functions and so the positions of the operations are assigned using the convention of 
	% these functions.

	% For example we can crop the data by creating a crop operation as follows.
	% First assign the operation type
	procdata.op(1).act='crop';
	% Then assign the shape
	procdata.op(1).shape='rectangle';
	% Then assign the coordinates accoring to the matlab convention
	procdata.op(1).coord=[2.1,3.1,25,30.3];
	% Then tell field_format whether to include or exclude the data.
	% (note that crop should always include)
	procdata.op(1).clude='include';

	% We can then create a mask.
	procdata.op(2).act='mask';
	procdata.op(2).shape='polygon';
	procdata.op(2).coord=[14.8,30.6;15.3,24.2;19.5,23.9;24.7,31.4];
	procdata.op(2).clude='exclude';

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Now that the operations have been assigned you must create a couple more variables.
	% Create a variable called 'current' that tells field_format the amount of operations
	% there are.
	procdata.current=2;
	% Create a variable called 'which_operations' which is used to tell field_format which
	% operations it should apply to the data and which should be ignored. If it is set to -1
	% then all the operations will be applied. Otherwise create a vector containing a binary
	% indication of which operations to apply (if the vector entry corresponding to an
	% operation is a 1 then the operation will be applied but if it is 0 then the operation
	% will be ignored)
	procdata.which_operations=[1 1];

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Now you can run field_format to apply the operations to your data. This is done as
	% follows...
	Whatever_you_want_to_call_it=field_format(procdata)

	% This will return the data to you with the position and displacement fields in the
	% following form
	Whatever_you_want_to_call_it.POSX;			% position in x direction
	Whatever_you_want_to_call_it.POSY;			% position in y direction
	Whatever_you_want_to_call_it.POSZ;			% position in z direction  
	Whatever_you_want_to_call_it.UX;			% x direction displacement
	Whatever_you_want_to_call_it.UY;			% y direction displacement
	Whatever_you_want_to_call_it.UZ;			% z direction displacement
	Whatever_you_want_to_call_it.gridspacing;	% distance between data points
	%if you import data from a .vc7 file then there will be other outputs

	% display data
	imagesc(Whatever_you_want_to_call_it.UX)
end