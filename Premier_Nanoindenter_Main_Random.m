% Written by Kieran Rivers, Hannah Cole and Rebecca Tearle (Oxford Micromechanics Group) 2022

clear
close all
addpath src
addpath Side_Quests


% The aim of this script is to input all Bruker Premier nanoindentation data, 
% provide basic plots of hardness, modulus, etc. using Oliver and Parr
% methods. This script is for randomly placed indents

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% This is the main input deck - users: please edit inputs here only

% Enter the base file directory for your sample here - see README.txt for
% how to structure your base file directory; use a \ on the end of the name
base_file_directory = "D:\premier\week4HT\x80sample130702\";


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
calculate_extra_values = "no";

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
popin_fitting = "yes";

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
[load_displacement_data,amber_indents_list,red_indents_list] = Premier_Nanoindenter_Random_Import(base_file_directory,minimum_load_tolerance,maximum_displacement_tolerance);
%% Dealing with dodgy indents (writes new struct with NaN values - old struct still available for comparison)
% Note naughty list always contains red error indents, but only contains amber indents if user says so using exclude_dodgy
% Note new struct generated so originally dodgy data without NaN can also be viewed for debugging
[updated_main_data_struct,naughty_indents_list] = dodgy_indents(load_displacement_data,amber_indents_list,red_indents_list,exclude_dodgy);

%% Calling Oliver and Parr Methods
if hannah_oliver_parr == "yes"
    [main_data_struct,naughty_indents_list,red_indents_list] = oliverandparrpremierpowerlawfitrjsnewmethod(base_file_directory,updated_main_data_struct,epsilon,samplepossionratio,tolerance,cutofdatavalue,cutofunloadingtoplim,cutofunloadingbottomlim,naughty_indents_list,red_indents_list);
else if hannah_oliver_parr == "no"
        [main_data_struct] = premier_method(base_file_directory,updated_main_data_struct); % will read indent index to get correct data set
    end
end

%% Calculating values not directly taken from the raw data, e.g. stiffness squared divided by load
if calculate_extra_values == "yes"
    [final_main_data_struct,naughty_indents_list,red_indents_list] = calculationsofotherusefulvalues(base_file_directory,updated_main_data_struct,main_data_struct,naughty_indents_list,red_indents_list);
else if calculate_extra_values == "no"
        final_main_data_struct=main_data_struct;
    end
end

%% Calling pop-in code
if popin_fitting == "yes"
    [popinfitting,naughty_indents_list,red_indents_list] = popincode(base_file_directory,load_displacement_data,tolerancepopin,smoothingvalue,MPH,naughty_indents_list,red_indents_list,cutofflow,cutoffhigh)
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


