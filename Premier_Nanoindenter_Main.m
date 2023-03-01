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
base_file_directory = "C:\Users\hanna\OneDrive - Nexus365\Year 4\Term 1\HC_nanoindenation_premier\Premier_Nanoindentation\OUdi\";
% Specify whether the data is for an "xpm_indentation_map" or
% "automated_indentation_grid_array"
mapping_type = "xpm_indentation_map";

% Give the rows and columns data dimension: this is the number of rows and
% columns entered in the "Array Patterns" section of the automation tab
% regardless of the mapping type
rows = 1;
columns = 1;

% Give the spacing entered on the "Array Patterns" section of the
% automation tab regardless of the mapping type in um - if using automated
% indentation grid array you may wish to enter a measured spacing instead
spacing = 1;

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
% swamped with these outlier results; if there are indents present that are
% likely to break the code when applying calculations, these will 
% automatically be exluded and are described as a red error code - other 
% dodgy indents that do not break the code are described as an amber error 
% code and can be toggled using this exclude_dodgy;
exclude_dodgy = "no";

% If inputting xpm data specify here the number of segments in the load
% fucntion for each indent. This will either be 2 or 3.

noofsegments=3;


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

% Specify here whether you want to calculate some additional values like
% Hardness/Modulus, etc. with the final results using "yes" or "no"
calculate_extra_values = "yes";

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% This next section is for advanced users: only edit if you know what you are doing - see documentation

% Specify here whether you'd like to use Hannah's Oliver and Parr method
% using "yes" or "no"
hannah_oliver_parr = "yes";

% Fitting parameter for hannah_oliver_parr - see documentation if want to
% change these pararmeters
epsilon = 0.75;
samplepossionratio = 0.3;
tolerance = 0.007;
cutofdatavalue = 0.95;
cutofunloadingtoplim = 0.05;
cutofunloadingbottomlim = 0.25;

% Specify here whether you want to use the popin decting code using "yes" 
% or "no"
 popin_fitting= "yes";

% Fitting parameter for popin_fitting - see documentation if want to
% change these pararmeters
tolerancepopin = 0.007;
smoothingvalue = 7;
MPH = 1.0;
cutofflow=20;
cutoffhigh=1000;
numberofexpectedpopin=100;

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
if mapping_type == "xpm_indentation_map"
    [load_displacement_data,amber_indents_list,red_indents_list] = Premier_mapping_import_V2(base_file_directory,rows,columns,spacing,row_overlap,column_overlap,negative_displacement_tolerance,minimum_load_tolerance,noofsegments);
    disp("XPM Indentation Data Successfully Imported.")
else if mapping_type == "automated_indentation_grid_array"
        [load_displacement_data,amber_indents_list,red_indents_list] = Premier_Nanoindenter_Array_Data_Import(base_file_directory,rows,columns,spacing,minimum_load_tolerance,maximum_displacement_tolerance);
        disp("Automated Grid Array Indentation Data Successfully Imported.")
    end
end

%% Dealing with dodgy indents (writes new struct with NaN values - old struct still available for comparison)
% Note naughty list always contains red error indents, but only contains amber indents if user says so using exclude_dodgy
% Note new struct generated so originally dodgy data without NaN can also be viewed for debugging
[updated_main_data_struct,naughty_indents_list] = dodgy_indents(load_displacement_data,amber_indents_list,red_indents_list,exclude_dodgy,hannah_oliver_parr);


%% Calling Oliver and Parr Methods
if hannah_oliver_parr == "yes"
    if mapping_type == "xpm_indentation_map"
    [main_data_struct,naughty_indents_list,red_indents_list] = oliverandparrmappingversion(base_file_directory,updated_main_data_struct,epsilon,samplepossionratio,tolerance,cutofdatavalue,cutofunloadingtoplim,cutofunloadingbottomlim,naughty_indents_list,red_indents_list);
        else if mapping_type == "automated_indentation_grid_array"
        [main_data_struct,naughty_indents_list,red_indents_list] = oliverandparrarray(base_file_directory,updated_main_data_struct,epsilon,samplepossionratio,tolerance,cutofdatavalue,cutofunloadingtoplim,cutofunloadingbottomlim,naughty_indents_list,red_indents_list);   
        end
    end
else if hannah_oliver_parr == "no"
        [main_data_struct] = premier_method(base_file_directory,updated_main_data_struct,mapping_type,naughty_indents_list,samplepossionratio); % will read indent index to get correct data set
    end
end

%% Calculating values not directly taken from the raw data, e.g. stiffness squared divided by load
if calculate_extra_values == "yes"
    [final_main_data_struct,naughty_indents_list,red_indents_list] = calculationsofotherusefulvalues(base_file_directory,main_data_struct,naughty_indents_list,red_indents_list);
else if calculate_extra_values == "no"
        final_main_data_struct=main_data_struct;
    end
end

%% Calling pop-in code
if popin_fitting == "yes"
    [popinfitting,naughty_indents_list,red_indents_list,final_main_popin_data_struct] = popincode(base_file_directory,mapping_type,final_main_data_struct,tolerancepopin,smoothingvalue,MPH,naughty_indents_list,red_indents_list,cutofflow,cutoffhigh,numberofexpectedpopin);
    else if popin_fitting == "no"
    end
end
%% Single curve popin 
% MPH = 0.8;
% cutofflow=200;
% individual_indent_no=56;
% [popinfittingsingle,naughty_indents_list,red_indents_list] = popincodesingle(base_file_directory,mapping_type,updated_main_data_struct,tolerancepopin,smoothingvalue,MPH,naughty_indents_list,red_indents_list,cutofflow,cutoffhigh,individual_indent_no,numberofexpectedpopin);

%% Popinsample
% MPH = 1.0;
% cutofflow=50;
% samplesize=10;
% [popinfittingsample,naughty_indents_list,red_indents_list] = popincodesample(base_file_directory,mapping_type,updated_main_data_struct,tolerancepopin,smoothingvalue,MPH,naughty_indents_list,red_indents_list,cutofflow,cutoffhigh,samplesize,numberofexpectedpopin);


%% Calling CMX fitting
% Specify here whether you want to use the popin decting code using "yes" or "no"
if CMX_fitting == "yes"
    [CMXfittingresults] = CMXmethod(base_file_directory,Lowerdepthcutoff,Upperdepthcutoff);
else if CMX_fitting == "no"
    end
end
 %% Generating outputs and saving them to file

output_file_directory = strcat((base_file_directory),"Figure_Outputs"); % Generates path for output folder
mkdir (output_file_directory); % Creates output folder in base path

%%
updated_main_data_struct=final_main_data_struct;

% % Firstly the histograms
[Figure1_Hardness_Histogram] = histogramfunction(updated_main_data_struct,"Hardness",output_file_directory);
[Figure2_Youngs_Modulus_Histogram] = histogramfunction(updated_main_data_struct,"Youngs_Modulus",output_file_directory);
[Figure3_Reduced_Modulus_Histogram] = histogramfunction(updated_main_data_struct,"Reduced_Modulus",output_file_directory);
[Figure4_Stiffness_Histogram] = histogramfunction(updated_main_data_struct,"Stiffness",output_file_directory);
[Figure5_Hardness_Histogram_Zoom] = histogramfunction_zoom(updated_main_data_struct,"Hardness",output_file_directory);
[Figure6_Youngs_Modulus_Histogram_Zoom] = histogramfunction_zoom(updated_main_data_struct,"Youngs_Modulus",output_file_directory);
[Figure7_Reduced_Modulus_Histogram_Zoom] = histogramfunction_zoom(updated_main_data_struct,"Reduced_Modulus",output_file_directory);
[Figure8_Stiffness_Histogram_Zoom] = histogramfunction_zoom(updated_main_data_struct,"Stiffness",output_file_directory);

% % % Secondly the heat maps
[Figure9_Hardness_Map] = heatmaps(updated_main_data_struct,"Hardness",output_file_directory);
[Figure10_Youngs_Modulus_Map] = heatmaps(updated_main_data_struct,"Youngs_Modulus",output_file_directory);
[Figure11_Reduced_Modulus_Map] = heatmaps(updated_main_data_struct,"Reduced_Modulus",output_file_directory);
[Figure12_Stiffness_Map] = heatmaps(updated_main_data_struct,"Stiffness",output_file_directory);
[Figure13_Maximum_Load_Map] = heatmaps(updated_main_data_struct,"Maximum_Load",output_file_directory);
[Figure14_Maximum_Displacement_Map] = heatmaps(updated_main_data_struct,"Maximum_Displacement",output_file_directory);

[Figure18_Dodgy_Indent_Locations] = dodgy_indent_find(updated_main_data_struct,amber_indents_list,red_indents_list,output_file_directory);

output_conversion_file_directory = strcat((base_file_directory),"Conversion");
mkdir (output_conversion_file_directory); 
conversion(updated_main_data_struct,output_conversion_file_directory);

if calculate_extra_values == "yes"
    [Figure16_Hardness_Divided_By_Modulus_Map] = heatmaps(updated_main_data_struct,"Hardness_Divided_By_Modulus",output_file_directory);
    [Figure17_Stiffness_Squared_Divided_By_Load_Map] = heatmaps(updated_main_data_struct,"Stiffness_Squared_Divided_By_Load",output_file_directory);
end

if popin_fitting == "yes"
    updated_main_data_struct=final_main_popin_data_struct;
    [Figure14_Popin_no_density_above_cut_off] = heatmaps(updated_main_data_struct,"No_Pop_in_Data_Above_Cut_off",output_file_directory);
    [Figure14_Popin_no_density_limited] = heatmaps(updated_main_data_struct,"No_Pop_in_Data_Between_Limits",output_file_directory);
    [Figure9_Hardness_Map] = heatmapspopin(updated_main_data_struct,"Hardness",output_file_directory,numberofexpectedpopin);
    [Figure10_Youngs_Modulus_Map] = heatmapspopin(updated_main_data_struct,"Youngs_Modulus",output_file_directory,numberofexpectedpopin);
    [Figure11_Reduced_Modulus_Map] = heatmapspopin(updated_main_data_struct,"Reduced_Modulus",output_file_directory,numberofexpectedpopin);
    [Figure12_Stiffness_Map] = heatmapspopin(updated_main_data_struct,"Stiffness",output_file_directory,numberofexpectedpopin);
    [Figure13_Maximum_Load_Map] = heatmapspopin(updated_main_data_struct,"Maximum_Load",output_file_directory,numberofexpectedpopin);
    [Figure14_Maximum_Displacement_Map] = heatmapspopin(updated_main_data_struct,"Maximum_Displacement",output_file_directory,numberofexpectedpopin);
         if calculate_extra_values == "yes"
            [Figure16_Hardness_Divided_By_Modulus_Map] = heatmapspopin(updated_main_data_struct,"Hardness_Divided_By_Modulus",output_file_directory,numberofexpectedpopin);
            [Figure17_Stiffness_Squared_Divided_By_Load_Map] = heatmapspopin(updated_main_data_struct,"Stiffness_Squared_Divided_By_Load",output_file_directory,numberofexpectedpopin);
         end
end

if mapping_type == "xpm_indentation_map"
    [Figure15_Surface_Displacement_Map] = heatmaps(updated_main_data_struct,"Surface_Displacement",output_file_directory);
    if popin_fitting == "yes"
        [Figure15_Surface_Displacement_Map] = heatmapspopin(updated_main_data_struct,"Surface_Displacement",output_file_directory,numberofexpectedpopin);
    end
   
end

close all



 



