%% Importing all indentation data
function [final_load_displacement_data,amber_indents_list,red_indents_list] = Premier_Nanoindenter_Random_Import(base_file_directory,minimum_load_tolerance,maximum_displacement_tolerance)

indent_file_locations = strcat(base_file_directory,"Indent_Data"); % Gets the full folder path for the indentation data
folder_info = dir(fullfile(indent_file_locations, '/*.txt')); % Gets a list of file properties within the folder
initial_number_of_data = size(folder_info,1); % Counts number of files in the folder

progress_bar = waitbar(0,"Importing Indentation Data"); % Creates a progress bar
original_load_displacement = struct("Indent_Index",cell(initial_number_of_data,1),"Displacement_Load_Data",cell(initial_number_of_data,1),"X_Coordinate",cell(initial_number_of_data,1),"Y_Coordinate",cell(initial_number_of_data,1)); % Creates an empty struct with 4 fields for each indent 

for file_loop = 1:initial_number_of_data % For count through number of indents in folder
    completion_fraction = file_loop/initial_number_of_data; % Calculates fraction for progress bar
    waitbar(completion_fraction); % Updates progress bar
    file_name = folder_info(file_loop).name; % Extract file name of indent
    full_file_name = fullfile(indent_file_locations, file_name); % Extract file name (including path) for each indent
    full_input = importdata(full_file_name); % Extracts contents of file as struct depending on data structure
    data_input = full_input.data; % Selects only the numerical data
    raw_input = []; % Resets table for below
    raw_input(:,1) = data_input(:,1); % Loads uncorrected depth values into table
    raw_input(:,2) = data_input(:,2); % Loads uncorrected load values into table
    original_load_displacement(file_loop).Indent_Index = file_loop-1; % Writes indent number to struct (starting indexing at zero as per files)
    original_load_displacement(file_loop).Displacement_Load_Data = raw_input; % Writes displacement and load data array to struct
end

close(progress_bar) % Closes progress bar

%% Check for problem indents
%  Other conditions for excluding indents can be added here at a later date

% Amber warning: no amber warnings yet

amber_indents_list = []; % List for storing index of dodgy amber indents

% Red warning: indent load never drops below zero

progress_bar = waitbar(0,"Checking for Problem Indents - Red Warning"); % Creates a progress bar
red_indents_list = []; % List for storing index of dodgy indents
for indent_loop = 1:initial_number_of_data % For count through each remaining indent
    completion_fraction = indent_loop/initial_number_of_data; % Calculates fraction for progress bar
    waitbar(completion_fraction); % Updates progress bar
    load_data_test = original_load_displacement(indent_loop).Displacement_Load_Data(:,2); % Gets all load data for indent
    minimum_load_test = min(load_data_test(20:end)); % Excludes first few points in case those are also negative
    if minimum_load_test > minimum_load_tolerance % If minimum load below threshold for bad data
        red_indents_list(end+1) = original_load_displacement(indent_loop).Indent_Index; % Appends bad indent index to naughty list
        original_load_displacement (indent_loop).Error_Code = strcat("Red: Load does not drop below ",string(minimum_load_tolerance)," um when unloading."); % Writes error code to struct
    end
end
close(progress_bar)

number_dodgy = length(red_indents_list);
disp(strcat("Number of dodgy indents in red category due to unloading load not dropping below ",string(minimum_load_tolerance)," um is ",string(number_dodgy)," indents."))

% Red warning: displacement is above upper threshold (default 700)

new_red_indents_list = []; % Error list only for displaying number of indents with this error, not used elsewhere
progress_bar = waitbar(0,"Checking for Problem Indents - Red Warning"); % Creates a progress bar
for indent_loop = 1:initial_number_of_data % For count through each remaining indent
    completion_fraction = indent_loop/initial_number_of_data; % Calculates fraction for progress bar
    waitbar(completion_fraction); % Updates progress bar
    displacement_data_test = original_load_displacement(indent_loop).Displacement_Load_Data(:,1); % Gets all displacement data for indent
    maximum_displacement_test = max(displacement_data_test); % Finds maximum displacement value recorded for indent (before final zero correction)
    if maximum_displacement_test > maximum_displacement_tolerance % If maximum displacement above threshold for bad data
        red_indents_list(end+1) = original_load_displacement(indent_loop).Indent_Index; % Appends bad indent index to naughty list
        new_red_indents_list(end+1) = original_load_displacement(indent_loop).Indent_Index; % Appends bad indent index to naughty list
        red_indents_list = sort(red_indents_list); % Reorders list
        original_load_displacement(indent_loop).Error_Code = strcat("Red: Maximum displacement is above ",string(maximum_displacement_tolerance)," um, i.e. missing surface error."); % Writes error code to struct
    end
end
close(progress_bar)

number_dodgy = length(new_red_indents_list);
disp(strcat("Number of dodgy indents in red category due to maximum displacement being above ",string(maximum_displacement_tolerance)," um, i.e. missing surface error, is ",string(number_dodgy)," indents."))

final_load_displacement_data = original_load_displacement; % Rewrite struct for function output
amber_indents_list;
red_indents_list;