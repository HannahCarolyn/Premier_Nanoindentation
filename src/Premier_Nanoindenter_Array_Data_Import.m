function [final_load_displacement_data,bad_indents_list] = Premier_Nanoindenter_Array_Data_Import(base_file_directory,rows,columns,spacing,exclude_dodgy,dodgy_tolerance)

%% Importing all indentation data

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

%% Calculate zeroed coordinates

if initial_number_of_data ~= (rows*columns) % Quick check if rows and columns consistent with files
    disp("WARNING: The user inputted rows and columns does not correspond to the number of indents saved. Recommend abort.")
end

progress_bar = waitbar(0,"Calculating Coordinate Data"); % Creates a progress bar

x_coordinate_list = []; % Create an empty list for storing x coordinates
y_coordinate_list = []; % Create an empty list for storing y coordinates

for y_loop = 0:(rows-1) % For loop through number of rows (y coordinates)
    for x_loop = 0:(columns-1) % For loop through number of columns (x coordinates) - note automated grid array works lateral and not serpentine
        x_coordinate_list(end+1) = x_loop; % Add x coordinate to list
        y_coordinate_list(end+1) = y_loop; % Add y coordinate to list
    end
    completion_fraction = y_loop/(rows-1); % Calculates fraction for progress bar
    waitbar(completion_fraction); % Updates progress bar
end

x_coordinate_list = x_coordinate_list*spacing; % Converts generated coordinates to actual coordinates in um
y_coordinate_list = y_coordinate_list*spacing;

close(progress_bar) % Closes progress bar
progress_bar = waitbar(0,"Writing Coordinate Data"); % Creates a progress bar

for indent_loop = 1:initial_number_of_data
    completion_fraction = indent_loop/initial_number_of_data; % Calculates fraction for progress bar
    waitbar(completion_fraction); % Updates progress bar
    original_load_displacement(indent_loop).X_Coordinate = x_coordinate_list(indent_loop); % Writes coordinate data to struct
    original_load_displacement(indent_loop).Y_Coordinate = y_coordinate_list(indent_loop);
end

close(progress_bar) % Closes progress bar

%% Crop indent data - this has been removed as it interferes with Oliver Parr Calculations
% Remove data when negative load

% progress_bar = waitbar(0,"Cropping Negative Load Values"); % Creates a progress bar
% 
% for indent_loop = 1:initial_number_of_data % Loop through each indent
%     completion_fraction = indent_loop/initial_number_of_data; % Calculates fraction for progress bar
%     waitbar(completion_fraction); % Updates progress bar
%     displacement_data = []; % List for indent displacement data
%     load_data = []; % List for indent load data
%     displacement_data = original_load_displacement(indent_loop).Displacement_Load_Data(:,1); % Get displacement data for indent
%     load_data = original_load_displacement(indent_loop).Displacement_Load_Data(:,2); % Get load data for indent
%     displacement_data(1:10) = []; % Remove first 10 data points (sometimes load is positive there)
%     load_data(1:10) = []; % Remove first 10 data points (sometimes load is positive there)
%     cropped_displacement_data = []; % Create list to store cropped displacement data
%     cropped_load_data = []; % Create list to store cropped load data
%     for load_data_loop = 1:length(load_data) % For each load value of indent
%         if load_data(load_data_loop) >= 0 % If load value positive then write to cropped data list
%             cropped_load_data(end+1) = load_data(load_data_loop);
%             cropped_displacement_data(end+1) = displacement_data(load_data_loop);
%         end
%     end
%     cropped_data = []; % Double for both cropped displacement and load data
%     cropped_data(:,1) = cropped_displacement_data;
%     cropped_data(:,2) = cropped_load_data;
%     original_load_displacement(indent_loop).Displacement_Load_Data = []; % Clear original data for indent in struct
%     original_load_displacement(indent_loop).Displacement_Load_Data = cropped_data; % Write cropped data
% end
% 
% close(progress_bar) % Closes progress bar

%% Check for problem indents
%  Other conditions for excluding indents can be added here at a later date

if exclude_dodgy == "yes" % If user wishes to exclude dodgy indents later, run this
    progress_bar = waitbar(0,"Checking for Problem Indents"); % Creates a progress bar
    bad_indents_list = []; % List for storing index of dodgy indents
    for indent_loop = 1:initial_number_of_data % For count through each indent
        completion_fraction = indent_loop/initial_number_of_data; % Calculates fraction for progress bar
        waitbar(completion_fraction); % Updates progress bar
        displacement_data = []; % List for indent displacement data
        displacement_data = original_load_displacement(indent_loop).Displacement_Load_Data(:,1); % Get displacement data for indent
        maximum_indent_displacement = max(displacement_data); % Finds maximum displacement for indent
        maximum_index = find(displacement_data == maximum_indent_displacement); % Finds index in list where maximum displacement occured
        displacement_data_loading = displacement_data(1:maximum_index); % Appends loading displacement values
        minimum_displacement_data = min(displacement_data_loading); % Calculates minimum recorded displacement for indent in loading section
        if minimum_displacement_data < (-1*dodgy_tolerance) % If minimum displacement below threshold for bad data
            bad_indents_list(end+1) = original_load_displacement(indent_loop).Indent_Index; % Appends bad indent index to naughty list
        end
    end
    close(progress_bar)
    number_dodgy = length(bad_indents_list);
    disp(strcat("Number of dodgy indents found is ",string(number_dodgy)," out of the original ",string(initial_number_of_data)," indents."))
end

%% Have even depth spacings (split into loading and unloading) with zeroed displacement data

progress_bar = waitbar(0,"Creating Continuous Displacement Dataset"); % Creates a progress bar
interpolated_load_displacement = original_load_displacement;
for indent_loop = 1:initial_number_of_data % For count through each remaining indent
    completion_fraction = indent_loop/initial_number_of_data; % Calculates fraction for progress bar
    waitbar(completion_fraction); % Updates progress bar
    indent_displacement_data = original_load_displacement(indent_loop).Displacement_Load_Data(:,1); % Gets all displacement data for indent
    indent_load_data = original_load_displacement(indent_loop).Displacement_Load_Data(:,2); % Gets all displacement data for indent
    maximum_indent_displacement = max(indent_displacement_data); % Finds maximum displacement for indent
    maximum_index = find(indent_displacement_data == maximum_indent_displacement); % Finds index in list where maximum displacement occured
    indent_displacement_data_loading = indent_displacement_data(1:maximum_index); % Appends loading displacement values
    indent_displacement_data_unloading = indent_displacement_data(maximum_index:length(indent_displacement_data)); % Appends unloading displacement values
    indent_load_data_loading = indent_load_data(1:maximum_index); % Appends laoding load values
    indent_load_data_unloading = indent_load_data(maximum_index:length(indent_displacement_data)); % Appends unloading load values
    new_displacement_data = []; % List for storing new displacement data
    new_load_data = []; % List for storing corresponding load data
    new_data = []; % Create list for storing new displacement_load_data
    maximum_indent_displacement = floor(maximum_indent_displacement); % Round maximum displacement down so able to interp
    minimum_indent_displacement_loading = ceil(min(indent_displacement_data_loading)); % Round mimimum loading displacement up so able to interp
    minimum_indent_displacement_unloading = ceil(min(indent_displacement_data_unloading)); % Round minimum unloading displacement up so able to interp
    % Zero all displacement data (next 5 lines)
    indent_displacement_data_loading = indent_displacement_data_loading - minimum_indent_displacement_loading;
    indent_displacement_data_unloading = indent_displacement_data_unloading - minimum_indent_displacement_loading;
    minimum_indent_displacement_unloading = minimum_indent_displacement_unloading - minimum_indent_displacement_loading;
    maximum_indent_displacement = maximum_indent_displacement - minimum_indent_displacement_loading;
    minimum_indent_displacement_loading = 0;
    if minimum_indent_displacement_unloading <0 % Set minimum unloading displacement as 0 for interp if contains non-zero values
        minimum_indent_displacement_unloading = 0;
    end
    for indent_displacement = minimum_indent_displacement_loading:0.1:maximum_indent_displacement % For each displacement step in loading, calculate interpolated values
        try
            load_value = interp1(indent_displacement_data_loading,indent_load_data_loading,indent_displacement);
        catch
            load_value = NaN;
        end
        new_displacement_data(end+1) = indent_displacement; % Append new interpolated values
        new_load_data(end+1) = load_value;
    end
    for indent_displacement = maximum_indent_displacement:-0.1:minimum_indent_displacement_unloading % For each displacement step in unloading, calculate interpolated values
        try
            load_value = interp1(indent_displacement_data_unloading,indent_load_data_unloading,indent_displacement);
        catch
            load_value = NaN;
        end
        new_displacement_data(end+1) = indent_displacement; % Append new interpolated values
        new_load_data(end+1) = load_value;
    end
    new_data(:,1) = new_displacement_data; % Append all new data to new list
    new_data(:,2) = new_load_data;
    interpolated_load_displacement(indent_loop).Displacement_Load_Data = []; % Delete old data from struct
    interpolated_load_displacement(indent_loop).Displacement_Load_Data = new_data; % Write new interpolated data to struct
end

close(progress_bar) % Close progress bar

%% Return values from function

final_load_displacement_data = interpolated_load_displacement; % Rewrite struct for function output
bad_indents_list;

end

% 179 lines total 04/01/2023