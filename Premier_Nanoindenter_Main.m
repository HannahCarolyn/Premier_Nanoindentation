% Written by Kieran Rivers, Hannah Cole and Rebecca Tearle (Oxford Micromechanics Group) 2022

clear
close all
addpath src

% The aim of this script is to input all Bruker Premier nanoindentation data, 
% provide basic plots of hardness, modulus, etc. using Oliver and Parr methods 
% and provide an output format of data that can be used directly into Chris 
% Magazzeni's XPCorrelate EBSD MATLAB script

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% This is the main input deck - users: please edit inputs here only

% Enter the base file directory for your sample here - see README.txt for
% how to structure your base file directory; use a \ on the end of the name
base_file_directory = "C:\Users\hanna\OneDrive - Nexus365\Year 4\Term 1\HC_nanoindenation_premier\Premier_Nanoindentation\Example_Mapping_Data\";


% Specify whether the data is for an "xpm_indentation_map" or
% "automated_indentation_grid_array"
mapping_type = "xpm_indentation_map";

% Give the rows and columns data dimension: this is the number of rows and
% columns entered in the "Array Patterns" section of the automation tab
% regardless of the mapping type
rows = 3;
columns = 3;

% Give the spacing entered on the "Array Patterns" section of the
% automation tab regardless of the mapping type in um - if using automated
% indentation grid array you may wish to enter a measured spacing instead
spacing = 45;

% If overlap occured between xpm bundles, enter the number of overlapping
% columns and rows of indents so this may be corrected (only the data from
% the first set of indents at the given overlap location will be used); if
% overlap did not occur enter 0; if XPM mapping was not used, also enter 0;
% if there is a gap between xpm bundles instead, enter a negative number
% corresponding to how many lines of indents would fit in that gap
row_overlap = 2;
column_overlap = 2;

% If there are dodgy indents (due to rubbish on the surface or porosity),
% do you want these to be automatically excluded? Enter "yes" or "no". If
% these are excluded, an average of the surrounding indents will be used
% when plotting any data. If these are not excluded, you will need to
% manually edit the colour bar on the output figures so they are not
% swamped with these outlier results; dodgy tolerance is how negative a
% displacement (in um) needs to go on an indent for it to count as dodgy
exclude_dodgy = "yes";
dodgy_tolerance = 20;

% Specify here whether you'd like to use Hannah's Oliver and Parr method
% using "yes" or "no"
hannah_oliver_parr = "yes";
% Fitting parameter for hannah_oliver_parr see documentation if want to
% change these pararmeters
epsilon = 0.75;
samplepossionratio = 0.3;
tolerance = 0.01;
cutofdatavalue = 0.95;
cutofunloadingtoplim = 0.05;
cutofunloadingbottomlim = 0.25;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% From here, different functions are called in order and if needed - users: do not edit from this point onwards

%% Calling main data import function
if mapping_type == "xpm_indentation_map"
    [load_displacement_data,bad_indents_list] = Premier_Nanoindenter_Mapping_Data_Import(base_file_directory,rows,columns,spacing,row_overlap,column_overlap,exclude_dodgy,dodgy_tolerance);
    disp("XPM Indentation Data Successfully Imported.")
else if mapping_type == "automated_indentation_grid_array"
        [load_displacement_data,bad_indents_list] = Premier_Nanoindenter_Array_Data_Import(base_file_directory,rows,columns,spacing,exclude_dodgy,dodgy_tolerance);
        disp("Automated Grid Array Indentation Data Successfully Imported.")
    end
end
% load_displacement_data is a data struct and bad_indents_list is a list of indent indices (where indent numbering starts at zero)

%% Calling Oliver and Parr Methods
if hannah_oliver_parr == "yes"
    [main_data_struct] = oliverandparrpremierpowerlawfitrjsnewmethod(base_file_directory,load_displacement_data,epsilon,samplepossionratio,tolerance,cutofdatavalue,cutofunloadingtoplim,cutofunloadingbottomlim);
else if hannah_oliver_parr == "no"
        [main_data_struct] = premier_method(base_file_directory,load_displacement_data); % will read indent index to get correct data set
    end
end


% % 
% %% Calculating values not directly taken from the raw data, e.g. stiffness squared divided by load
% % [main_data_struct] = calculations(main_data_struct);
% 
% %% Dealing with dodgy indents (writes new struct with NaN values - old struct still available for comparison)
% % if exclude_dodgy == "yes"
% %     [updated_main_data_struct] = dodgy_indents(main_data_struct,bad_indents_list);
% % else if exclude_dodgy == "no"
% %         updated_main_data_struct = main_data_struct;
% %     end
% % end
updated_main_data_struct =main_data_struct;

% %% Generating outputs and saving them to file
% output_file_directory = strcat((base_file_directory),"Figure_Outputs"); % Generates path for output folder
% mkdir (output_file_directory); % Creates output folder in base path
% 
% % Firstly the histograms
% [Figure1_Hardness_Histogram] = histogramfunction(updated_main_data_struct,"Hardness",output_file_directory);
% [Figure2_Youngs_Modulus_Histogram] = histogramfunction(updated_main_data_struct,"Youngs_Modulus",output_file_directory);
% [Figure3_Reduced_Modulus_Histogram] = histogramfunction(updated_main_data_struct,"Reduced_Modulus",output_file_directory);
% % [Figure4_Stiffness_Histogram] = histogramfunction(updated_main_data_struct,"Stiffness",output_file_directory);
% [Figure5_Hardness_Histogram_Zoom] = histogramfunction_zoom(updated_main_data_struct,"Hardness",output_file_directory);
% [Figure6_Youngs_Modulus_Histogram_Zoom] = histogramfunction_zoom(updated_main_data_struct,"Youngs_Modulus",output_file_directory);
% [Figure7_Reduced_Modulus_Histogram_Zoom] = histogramfunction_zoom(updated_main_data_struct,"Reduced_Modulus",output_file_directory);
% % [Figure8_Stiffness_Histogram_Zoom] = histogramfunction_zoom(updated_main_data_struct,"Stiffness",output_file_directory);
% 
% % Secondly the heat maps
% [Figure9_Hardness_Map] = heatmaps(updated_main_data_struct,"Hardness",output_file_directory);
% [Figure10_Youngs_Modulus_Map] = heatmaps(updated_main_data_struct,"Youngs_Modulus",output_file_directory);
% [Figure11_Reduced_Modulus_Map] = heatmaps(updated_main_data_struct,"Reduced_Modulus",output_file_directory);
% % [Figure12_Stiffness_Map] = heatmaps(updated_main_data_struct,"Stiffness",output_file_directory);
% % [Figure13_Maximum_Load_Map] = heatmaps(updated_main_data_struct,"Maximum_Load",output_file_directory);
% % [Figure14_Maximum_Displacement_Map] = heatmaps(updated_main_data_struct,"Maximum_Displacement",output_file_directory);
% % [Figure15_Minimum_Displacement_Map] = heatmaps(updated_main_data_struct,"Minimum_Displacement",output_file_directory);
% % [Figure16_Hardness_Divided_By_Modulus_Map] = heatmaps(updated_main_data_struct,"Hardness_Divided_By_Modulus",output_file_directory);
% % [Figure17_Stiffness_Squared_Divided_By_Load_Map] = heatmaps(updated_main_data_struct,"Stiffness_Squared_Divided_By_Load",output_file_directory);
% 
% % Thirdly the dodgy indents treasure map
% [Figure18_Dodgy_Indent_Locations] = dodgy_indent_find(updated_main_data_struct,bad_indents_list,output_file_directory);
% 
% %% Generating output workspace to be compatible with XPCorrelate
% % [workspace_output] = conversion(updated_main_data_struct);
