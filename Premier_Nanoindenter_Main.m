% Written by Kieran Rivers and Hannah Cole (Oxford Micromechanics Group) 2022

clear
close all
addpath src

% The aim of this script is to input all Bruker Premier nanoindentation data, 
% provide basic plots of hardness, modulus, etc. using Oliver and Parr methods 
% and provide an output format of data that can be used directly into Chris 
% Magazzeni's XPCorrelate EBSD MATLAB script

%% This is the main input deck - users: please edit inputs here only

% Enter the base file directory for your sample here - see README.txt for
% how to structure your base file directory
base_file_directory = "C:\Users\mans3584\OneDrive - Nexus365\3 - Postgraduate Documents\Research Project\Data\Premier\Local Premier Github Repository\Premier_Nanoindentation\Example_Mapping_Data";

% Specify whether the data is for an "xpm_indentation_map" or
% "automated_indentation_grid_array"
mapping_type = "xpm_indentation_map";

% If xpm mapping was used, specify whether serpentine or lateral pattern
% was used
xpm_pattern = "lateral";

% Give the rows and columns data dimension: this is the number of rows and
% columns entered in the "Array Patterns" section of the automation tab
% regardless of the mapping type
rows = 3;
columns = 3;

% Enter the spacing in um between the data dimensions above: since the motor 
% movement is in accurate, enter the actual measured spacing (via a microscope) 
% used to avoid indent overlap; enter indent spacing if using an automated
% indentation array
bundle_spacing = 45;

% If overlap occured between xpm bundles, enter the number of overlapping
% columns and rows of indents so this may be corrected (only the data from
% the first set of indents at the given overlap location will be used); if
% overlap did not occur enter 0; if XPM mapping was not used, also enter 0
row_overlap = 0;
column_overlap = 0;

%% From here, different functions are called in order and if needed - users: do not edit

% Calling main data import function
if mapping_type == "xpm_indentation_map"
    [data_import_struct] = Premier_Nanoindenter_Mapping_Data_Import(base_file_directory,xpm_pattern,rows,columns,bundle_spacing,row_overlap,column_overlap);
    disp("XPM Indentation Data Successfully Imported")
else if mapping_type == "automated_indentation_grid_array"
        [data_import_struct] = Premier_Nanoindenter_Array_Data_Import(base_file_directory,rows,columns,bundle_spacing);
        disp("Automated Grid Array Indentation Data Successfully Imported")
    end
end