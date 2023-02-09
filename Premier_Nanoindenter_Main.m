% Written by Kieran Rivers, Hannah Cole and Rebecca Tearle (Oxford Micromechanics Group) 2022

clear
close all
addpath src
addpath Side_Quests

% The aim of this script is to input all Bruker Premier nanoindentation data, 
% provide basic plots of hardness, modulus, etc. using Oliver and Parr methods 
% and provide an output format of data that can be used directly into Chris 
% Magazzeni's XPCorrelate EBSD MATLAB script

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% This is the main input deck - users: please edit inputs here only

% Enter the base file directory for your sample here - see README.txt for
% how to structure your base file directory; use a \ on the end of the name
% Strpmg
base_file_directory = "C:\Users\mans3584\Documents\Example_Mapping_Data\";

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
row_overlap = 0;
column_overlap = 0;

% If there are dodgy indents (due to rubbish on the surface or porosity),
% do you want these to be automatically excluded? Enter "yes" or "no". If
% these are excluded, an average of the surrounding indents will be used
% when plotting any data. If these are not excluded, you will need to
% manually edit the colour bar on the output figures so they are not
% swamped with these outlier results; please note:
% - If using Hannah's Oliver and Parr calculations: If there are indents 
%   present that are likely to break the code when applying Oliver and Parr 
%   calculations, these will automatically be exluded and are described as 
%   a red error code - other dodgy indents that do not break the code are 
%   described as an amber error code and can be toggled using this 
%   exclude_dodgy. 
% - If you are just going to use the Premier calculated values: The premier
%   is able to calculate values whether the indents have a amber or red
%   error so exclude_dodgy will in this case be used to toggle on/off both
%   the red and amber errored indents
exclude_dodgy = "no";

% Edit these numbers to determine how an indent gets described as a red or
% amber error: 
% Amber errors:
% - Negative displacement tolerance is how negative a displacement (in um) 
%   needs to go for an indent for it to count as dodgy (xpm mapping only)
% Red errors:
% - Minimum load tolerance is how close an indent needs to get to zero load
%   in unloading for it to be used in Oliver and Parr calculations (a
%   higher number excludes less indents but the calculations will be less
%   accurate for ALL indents) - load units are in uN
% - Maximum displacement tolerance is how high the displacement gets on an
%   indent before it is considered that the surface was missed - this will
%   need to be a value lower than the expected maximum displacement for the
%   maximum load used
negative_displacement_tolerance = 20;
minimum_load_tolerance = 5;
maximum_displacement_tolerance = 700;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% This next section is for advanced users: only edit if you know what you are doing - see documentation

% Specify here whether you'd like to use Hannah's Oliver and Parr method
% using "yes" or "no"
hannah_oliver_parr = "yes";

% Fitting parameter for hannah_oliver_parr - see documentation if want to
% change these pararmeters; note samplepossionratio also used in premier
% method for calculating Youngs Modulus from Reduced Modulus
epsilon = 0.75;
samplepossionratio = 0.3;
tolerance = 0.007;
cutofdatavalue = 0.95;
cutofunloadingtoplim = 0.05;
cutofunloadingbottomlim = 0.25;

% Specify here whether you want to use the popin decting code using "yes" 
% or "no"
popin_fitting = "no";

% Fitting parameter for popin_fitting - see documentation if want to
% change these pararmeters
tolerancepopin = 0.007;
smoothingvalue = 7;
MPH = 0.9;
cutofflow=0;
cutoffhigh=250;

% Specify here whether you want to use the CMX_fitting using "yes" or "no" 
% to use this function have a folder in your base directory called "CMX_Output"
% We can change this later to auto-generate that folder
CMX_fitting = "no";

% Fitting parameter for CMX fitting
Lowerdepthcutoff = 100;
Upperdepthcutoff = 350;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% From here, different functions are called in order and if needed - users: do not edit from this point onwards

%% Supress warnings
warning('off','curvefit:fittype:sethandles:xMustBePositive')

%% Calling main data import function
% load_displacement_data is a data struct and amber/red_indents_list is a list of indent indices (where indent numbering starts at zero)
% Note need to get Maximum Load, Maximum Displacement, Surface Displacement values from these too
if mapping_type == "xpm_indentation_map"
    [load_displacement_data,amber_indents_list,red_indents_list] = Premier_Nanoindenter_Mapping_Data_Import(base_file_directory,rows,columns,spacing,row_overlap,column_overlap,negative_displacement_tolerance,minimum_load_tolerance);
    disp("XPM Indentation Data Successfully Imported.")
else if mapping_type == "automated_indentation_grid_array"
        [load_displacement_data,amber_indents_list,red_indents_list] = Premier_Nanoindenter_Array_Data_Import(base_file_directory,rows,columns,spacing,minimum_load_tolerance,maximum_displacement_tolerance);
        disp("Automated Grid Array Indentation Data Successfully Imported.")
    end
end

%% Dealing with dodgy indents (writes new struct with NaN values - old struct still available for comparison)
% Note naughty list always contains red error indents, but only contains amber indents if user says so using exclude_dodgy
% Note if not using Hannah's Oliver and Parr methods, red errors are not an issue so if exclude_dodgy is no, the naughty list is cleared
% Note new struct generated so originally dodgy data without NaN can also be viewed for debugging
[updated_data_struct,naughty_indents_list] = dodgy_indents(load_displacement_data,amber_indents_list,red_indents_list,exclude_dodgy,hannah_oliver_parr);

%% Calling Oliver and Parr Methods
if hannah_oliver_parr == "yes"
    [updated_data_struct,naughty_indents_list,red_indents_list] = oliverandparrpremierpowerlawfitrjsnewmethod(base_file_directory,updated_data_struct,epsilon,samplepossionratio,tolerance,cutofdatavalue,cutofunloadingtoplim,cutofunloadingbottomlim,naughty_indents_list,red_indents_list,minimum_load_tolerance);
else if hannah_oliver_parr == "no"
        [updated_data_struct] = premier_method(base_file_directory,updated_data_struct,mapping_type,naughty_indents_list,samplepossionratio); % will read indent index to get correct data set and will ignore naughty list ones
    end
end

%% Calculating values not directly taken from the raw data, e.g. stiffness squared divided by load
% Shouldn't need red list from this point, only naughty
[updated_data_struct,naughty_indents_list,red_indents_list] = calculationsofotherusefulvalues(base_file_directory,updated_data_struct,naughty_indents_list,red_indents_list); 

%% Calling pop-in code
if popin_fitting == "yes"
    [popinfitting,naughty_indents_list,red_indents_list] = popincode(base_file_directory,updated_data_struct,tolerancepopin,smoothingvalue,MPH,naughty_indents_list,red_indents_list,cutofflow,cutoffhigh);
else if popin_fitting == "no"
    end
end

%% Calling CMX fitting
% Specify here whether you want to use the popin decting code using "yes" or "no"
if CMX_fitting == "yes"
    [CMXfittingresults] = CMXmethod(base_file_directory,Lowerdepthcutoff,Upperdepthcutoff);
else if CMX_fitting == "no"
    end
end

%% Generating outputs and saving them to file
% Need to add time and date to name so not overwrite. Will add generation
% of text file with parameters above also
output_file_directory = strcat((base_file_directory),"Figure_Outputs\"); % Generates path for output folder
mkdir (output_file_directory); % Creates output folder in base path

% Need to update these outputs to deal with bundle gaps (i.e. put white
% space rather than blend)
% Firstly the histograms
% [Figure1_Hardness_Histogram] = histogramfunction(updated_data_struct,"Hardness",output_file_directory);
% [Figure2_Youngs_Modulus_Histogram] = histogramfunction(updated_data_struct,"Youngs_Modulus",output_file_directory);
% [Figure3_Reduced_Modulus_Histogram] = histogramfunction(updated_data_struct,"Reduced_Modulus",output_file_directory);
% [Figure4_Stiffness_Histogram] = histogramfunction(updated_data_struct,"Stiffness",output_file_directory);
% [Figure5_Hardness_Histogram_Zoom] = histogramfunction_zoom(updated_data_struct,"Hardness",output_file_directory);
% [Figure6_Youngs_Modulus_Histogram_Zoom] = histogramfunction_zoom(updated_data_struct,"Youngs_Modulus",output_file_directory);
% [Figure7_Reduced_Modulus_Histogram_Zoom] = histogramfunction_zoom(updated_data_struct,"Reduced_Modulus",output_file_directory);
% [Figure8_Stiffness_Histogram_Zoom] = histogramfunction_zoom(updated_data_struct,"Stiffness",output_file_directory);
% 
% % Secondly the heat maps
[Figure9_Hardness_Map] = heatmaps(updated_data_struct,"Hardness",output_file_directory);
[Figure10_Youngs_Modulus_Map] = heatmaps(updated_data_struct,"Youngs_Modulus",output_file_directory);
[Figure11_Reduced_Modulus_Map] = heatmaps(updated_data_struct,"Reduced_Modulus",output_file_directory);
[Figure12_Stiffness_Map] = heatmaps(updated_data_struct,"Stiffness",output_file_directory);
[Figure13_Maximum_Load_Map] = heatmaps(updated_data_struct,"Maximum_Load",output_file_directory);
[Figure14_Maximum_Displacement_Map] = heatmaps(updated_data_struct,"Maximum_Displacement",output_file_directory);
[Figure15_Surface_Displacement_Map] = heatmaps(updated_data_struct,"Surface_Displacement",output_file_directory);
[Figure16_Hardness_Divided_By_Modulus_Map] = heatmaps(updated_data_struct,"Hardness_Divided_By_Modulus",output_file_directory);
%[Figure17_Stiffness_Squared_Divided_By_Load_Map] = heatmaps(updated_data_struct,"Stiffness_Squared_Divided_By_Load",output_file_directory);
 
% Thirdly the dodgy indents treasure map
[Figure18_Dodgy_Indent_Locations] = dodgy_indent_find(updated_data_struct,amber_indents_list,red_indents_list,output_file_directory);

%% Generating output workspace to be compatible with XPCorrelate and generate excel output
conversion(updated_data_struct,output_file_directory);
