There are two ways to interact with this program with regards to importing and masking/editting DIC and DVC data 
(FEM not yet implemented properly). The first way is to use a Graphical User Inerface called Convention_Code_v1_0.m.
 A guide for this can be found in the "Help_files" folder. The other method is to create a structure variable with 
 the appropriate subvariables and options. An example of using the program like this is found in the file 
 "example_code.m". In order to add all the necessary folders to the matlab search path run the file called 
 "run_this_to_add_current_folder_to_matlabs_search_path.m" (great name right :D ).

This program can read in .dat and .vc7 files containing either DVC or DIC data. The output will be a structure
variable containing fields
> UX - displacement in the x direction
> UY - displacement in the y direction
> UZ - displacement in the z direction
> POSX - x position
> POSY - y position
> POSZ - z position
> gridspacing - spacing between data points in mm (usually)