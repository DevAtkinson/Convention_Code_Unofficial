function add_required_paths()
	if ispc
		current_path=pwd;
		addpath(current_path);
		addpath(strcat(current_path,'\readimxstuff'));
		addpath(strcat(current_path,'\SubPrograms'));
	elseif isunix|ismac
		current_path=pwd;
		addpath(current_path);
		addpath(strcat(current_path,'/readimxstuff_linux'));
		addpath(strcat(current_path,'/SubPrograms'));
		if ismac
			fprintf('This program has not yet been tested for Macintosh systems so some bugs may appear.\nIf they do please report them to me at 17732913@sun.ac.za (I appreciated it)\n')
		end
	end
end