function [load_displacement_data,bad_indents_list] = Premier_Nanoindenter_Mapping_Data_Import(base_file_directory,rows,columns,spacing,row_overlap,column_overlap,exclude_dodgy)
    
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

%% Get coordinates of each indent in order of data recorded 
% (and correct to continuous coordinates if user altered bundle spacing)

coordinate_file_locations = strcat(base_file_directory,"Coordinate_Data"); % Gets the full folder path for the coordinate data
folder_info = dir(fullfile(coordinate_file_locations, '/*.txt')); % Gets a list of file properties within the folder
number_of_bundles = size(folder_info,1); % Counts number of files in the folder

if number_of_bundles ~= (rows*columns) % Quick check if rows and columns consistent with files
    disp("WARNING: The user inputted rows and columns does not correspond to the number of bundles saved. Recommend abort.")
end

progress_bar = waitbar(0,"Importing Coordinate Data"); % Creates a progress bar

for file_loop = 1:number_of_bundles % For count through number of bundles in folder
    completion_fraction = file_loop/number_of_bundles; % Calculates fraction for progress bar
    waitbar(completion_fraction); % Updates progress bar
    file_name = folder_info(file_loop).name; % Extract file name of bundle
    full_file_name = fullfile(coordinate_file_locations, file_name); % Extract file name (including path) for each bundle
    full_input = importdata(full_file_name); % Extracts contents of file as struct depending on data structure
    bundle_size_strings = split(string(full_input.textdata(1,1)),"= "); % Extracts bundle size as two strings
    bundle_size = str2double(bundle_size_strings(2)); % Gets bundle size (bundle indents) as number
    bundle_length = sqrt(bundle_size); % Gets side length of bundle in number of indents

    if file_loop == 1 % Only run once
        indent_spacing = round(full_input.data(2,12)*1000) - round(full_input.data(1,12)*1000); % Works out individual indent spacing from first two indent coordinates
        bundle_dimensions = indent_spacing*(bundle_length-1); % Calculates the length of a bundle in um
        expected_bundle_spacing = bundle_dimensions + indent_spacing; % Calculates the expected bundle spacing based on indent spacing and bundle size
        bundle_spacing_overshoot = spacing - expected_bundle_spacing; % Compares expected bundle spacing to that set by the user (user likely to use too large of a value to correct overlap)
    end

    bundle_column_number = rem(file_loop,columns); % Gets column number using remainder function
    if bundle_column_number == 0 % If columns is divisible by file_loop, it gives remainder 0 corresponding to a column_number equal to columns
        bundle_column_number = columns; % Changes 0 result to final column number
    end
    bundle_column_number = bundle_column_number - 1; % Start column indexing at 0
    bundle_row_number = rem(file_loop,rows); % Gets row number using remainder function
    if bundle_row_number == 0 % If rows is divisible by file_loop, it gives remainder 0 corresponding to a row_number equal to rows
        bundle_row_number = rows; % Changes 0 result to final row number
    end
    bundle_row_number = bundle_row_number - 1; % Start row indexing at 0

    for indent_loop = 1:bundle_size % For count through number of indents in bundle
        indent_x_coordinate = round(full_input.data(indent_loop,12)*1000); % Obtains x coordinate of indent in um to nearest integer
        indent_y_coordinate = round(full_input.data(indent_loop,13)*1000); % Obtains y coordinate of indent in um to nearest integer
        shift_indent_x_coordinate = indent_x_coordinate - (bundle_column_number*bundle_spacing_overshoot); % Shifts indent x coordinate by user defined overshoot (multiplied by column) for continuous x coordinate data set
        shift_indent_y_coordinate = indent_y_coordinate - (bundle_row_number*bundle_spacing_overshoot); % Shifts indent y coordinate by user definted overshoot (multiplied by row) for continuous y coordinate data set
        original_load_displacement(indent_loop+((file_loop-1)*bundle_size)).X_Coordinate = shift_indent_x_coordinate; % Writes x coordinate to main struct taking into account bundle dependent total indent number
        original_load_displacement(indent_loop+((file_loop-1)*bundle_size)).Y_Coordinate = shift_indent_y_coordinate; % Writes y coordinate to main struct taking into account bundle dependent total indent number
    end
end   

close(progress_bar) % Closes progress bar

%% Zero corrdinates

progress_bar = waitbar(0,"Zeroing Coordinate Data"); % Creates a progress bar

x_coordinate_list = []; % Create empty list for storing all x coordinates
y_coordinate_list = []; % Create empty list for storing all y coordinates

for indent_loop = 1:initial_number_of_data % For count through each indent in struct
    x_coordinate_list(end+1) = original_load_displacement(indent_loop).X_Coordinate; % Adds indent x coordinate to list
    y_coordinate_list(end+1) = original_load_displacement(indent_loop).Y_Coordinate; % Adds indent y coordinate to list
end

minimum_x_coordinate = min(x_coordinate_list); % Finds minimum x coordinate
minimum_y_coordinate = min(y_coordinate_list); % Finds minimum y coordinate

waitbar(0.5) % Updates wait bar halfway

for indent_loop = 1:initial_number_of_data % For count through each indent in struct
    original_load_displacement(indent_loop).X_Coordinate = original_load_displacement(indent_loop).X_Coordinate - minimum_x_coordinate; % Subtracts minimum x coordinate to zero coordinate and alter this in the struct
    original_load_displacement(indent_loop).Y_Coordinate = original_load_displacement(indent_loop).Y_Coordinate - minimum_y_coordinate; % Subtracts minimum y coordinate to zero coordinate and alter this in the struct
end

waitbar(1) % Updates wait bar when done
close(progress_bar) % Closes wait bar

%% Exclude overlap (shift x,y as needed)

%% Check for problem indents

%% Have even depth spacings (split into loading and unloading)








load_displacement_data = 1;
indent_positions = 1;
bad_indents_list = 1;



end