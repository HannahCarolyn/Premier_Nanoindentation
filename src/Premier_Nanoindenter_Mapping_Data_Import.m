function [final_load_displacement_data,bad_indents_list] = Premier_Nanoindenter_Mapping_Data_Import(base_file_directory,rows,columns,spacing,row_overlap,column_overlap,exclude_dodgy,dodgy_tolerance)
    
%% Importing all indentation data

indent_file_locations = strcat(base_file_directory,"Indent_Data"); % Gets the full folder path for the indentation data
folder_info = dir(fullfile(indent_file_locations, '/*.txt')); % Gets a list of file properties within the folder
initial_number_of_data = size(folder_info,1); % Counts number of files in the folder

% continuous_indent_file_locations = strcat(base_file_directory,"Continuous_Data"); % Gets the full folder path for the indentation data
% continuous_folder_info = dir(fullfile(continuous_indent_file_locations, '/*.txt')); % Gets a list of file properties within the folder
% continuous_number_of_data = size(continuous_folder_info,1); % Counts number of files in the folder

% progress_bar = waitbar(0,"Importing Indentation Data - Continuous"); % Creates a progress bar
% original_load_displacement = struct("Indent_Index",cell(initial_number_of_data,1),"Displacement_Load_Data",cell(initial_number_of_data,1),"X_Coordinate",cell(initial_number_of_data,1),"Y_Coordinate",cell(initial_number_of_data,1)); % Creates an empty struct with 4 fields for each indent 

% continuous_data_displacement = []; % List for storing continuous displacement data stream
% continuous_data_load = []; % List for storing continuous load data stream

% for file_loop = 1:continuous_number_of_data % For count through continuous data files (should be one for each bundle)
%     completion_fraction = file_loop/continuous_number_of_data; % Calculates fraction for progress bar
%     waitbar(completion_fraction); 
%     file_name = continuous_folder_info(file_loop).name; % Extract file name of indent
%     full_file_name = fullfile(continuous_indent_file_locations, file_name); % Extract file name (including path) for each indent
%     full_input = importdata(full_file_name); % Extracts contents of file as struct depending on data structure
%     data_input = full_input.data; % Selects only the numerical data
%     for continuous_data_input_loop = 1:length(data_input(:,2)) % For each continuous data value
%         continuous_data_displacement(end+1) = data_input(continuous_data_input_loop,2); % Adds bundle continuous displacement data stream to existing continuous data stream of previous bundles
%         continuous_data_load(end+1) = data_input(continuous_data_input_loop,3); % Does the same as above but for load
%     end
% end

% close(progress_bar) % Closes progress bar
progress_bar = waitbar(0,"Importing Indentation Data - Seperated"); % Creates a progress bar

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
    
    % Individual indent data has last few useful load values cropped - the
    % continuous data stream will be used to add to this for a complete set of
    % data for a given indent so it gets all data until negative load
    
%     last_displacement_value = raw_input(end,1); % Reads last written displacement value
%     last_load_value = raw_input(end,2); % Reads last written load value
%     last_load_find = continuous_data_load == last_load_value; % Returns logical array for the load being found in the continuous data set
%     last_load_index = find(last_load_find); % Returns indices of where logical array shows a find
%     if length(last_load_index) > 1 % If this load value has a twin, try for previous value instead
%         last_displacement_value = raw_input(end-1,1); % Reads penultimate written displacement value
%         last_load_value = raw_input(end-1,2); % Reads penultimate written load value
%         last_load_find = continuous_data_load == last_load_value; % Returns logical array for the load being found in the continuous data set
%         last_load_index = find(last_load_find); % Returns indices of where logical array shows a find
%         if length(last_load_index) > 1 % If this load value has a twin again!
%             disp(strcat("ERROR: The last load value for indent ",string(initial_number_of_data-1)," is some how not unique! You are more likely to win the lottery than get this error. Recommend abort code if you do get this error."))
%             return
%         end
%     end
%     last_raw_displacement_value = continuous_data_displacement(last_load_index); % Finds raw equivalent (i.e. not edited) depth for the last_displacement_value
%     raw_displacement_offset = last_displacement_value - last_raw_displacement_value; % Calculates the offset that needs to be added to raw depth values when adding them
%     a_sufficiently_large_number = 50; % Finds sufficiently large number for a loop through cropped values at end (should not need to increase this as only need to add a few values - the larger it is, the less efficient the code)
%     for end_data_loop = 1:a_sufficiently_large_number % Count up to sufficiently large number
%         if continuous_data_load(last_load_index + end_data_loop - 1) >= 0 % If next load data value (minus 1 so at least one negative is written) is positive, then do this
%             raw_input(end+1,1) = continuous_data_displacement(last_load_index + end_data_loop) + raw_displacement_offset; % Append next corrected displalcement value
%             raw_input(end+1,2) = continuous_data_load(last_load_index + end_data_loop); % Append next load value
%         else % i.e. 2nd negative value onwards
%             % Do nothing
%         end
%     end
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
    return
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

%% Make coordinates continuous in case user used bigger bundle spacing than needed

% Shift x
original_load_displacement = Coordinate_Shift("X_Coordinate",original_load_displacement,indent_spacing,"continuous",0);

% Shift y
original_load_displacement = Coordinate_Shift("Y_Coordinate",original_load_displacement,indent_spacing,"continuous",0);

%% Exclude bundle column overlap and take into account bundle gaps (shift x as needed)

progress_bar = waitbar(0,"Removing user defined overlapping indents"); % Creates a progress bar

bundle_x_coordinate_start = []; % Create empty list for storing bundle x start coordinates

for column_loop = 1:columns % For loop each bundle column (x direction)
    bundle_x_coordinate_start(end+1) = ((column_loop-1)*bundle_dimensions) + ((column_loop-1)*indent_spacing); % Work out bundle starting x coordinate
end

bundle_x_coordinate_start(1) = []; % Remove first bundle coordinate since this won't be overlapping
bundle_x_coordinate_overlap = []; % Create empty list for overlapping x coordinates

if column_overlap >= 0 % Check if user entered negative column overlap, i.e. a gap (process this differently below)
    
    % Identifying overlapping indent
    
    for coordinate_loop = [bundle_x_coordinate_start] % For loop each bundle starting overlapping coordinate
        for overlap_loop = 0:column_overlap % For loop through overlapping columns per bundle
            if overlap_loop == 0 % If no column overlap, do nothing
                % Do nothing
            else % Otherwise do this
                bundle_x_coordinate_overlap(end+1) = coordinate_loop + (overlap_loop-1)*indent_spacing; % Gets all overlapping x coordinates (of repeated indent)
            end
        end
    end
    struct_x_coordinate_list = [original_load_displacement.X_Coordinate]; % Gets x coordinates from struct in order of entries
    overlapping_x_coordinate_indices = []; % Creates empty list for storing the indices (i.e. struct number)
    for overlapping_coordinate_loop = [bundle_x_coordinate_overlap] % For each overlapping x coordinate
        logical_x_coordinate_find = []; % Creates empty list for logical array (where 1 will give a find of the coordindate, 0 is other)
        single_x_coordinate_find_index = []; % Creates empty list for storing the index of where the logical array returns a 1
        logical_x_coordinate_find = struct_x_coordinate_list == overlapping_coordinate_loop; % Returns logical array for the coordinate being checked in this loop run through
        single_x_coordinate_find_index = find(logical_x_coordinate_find); % Returns indices of where logical array shows a find for the coordinate being checked in this loop
        for append_index_loop = [single_x_coordinate_find_index] % For each index found for this coordinate
            overlapping_x_coordinate_indices(end+1) = append_index_loop; % Appends indices for all overlapping x coordinates (each run through the loop)
        end
    end

    % Removing overlapping indent from dataset

    for x_index_loop = [overlapping_x_coordinate_indices] % For each index for overlapping x coordinate - note index corresponds to the struct indexing beggining at 1
        original_load_displacement(x_index_loop).X_Coordinate = -0.1; % These 2 lines change the overlapping indent coordinates in struct to -0.1 (unique as not integer) so may be identified when writing new struct below
        original_load_displacement(x_index_loop).Y_Coordinate = -0.1;
    end

    % Shifting x coordinates so it is continuous again (calls function)

    original_load_displacement = Coordinate_Shift("X_Coordinate",original_load_displacement,indent_spacing,"continuous",0);
end

%% Exclude bundle row overlap and take into account bundle gaps (shift y as needed)

waitbar(0.5) % Updates wait bar halfway

bundle_y_coordinate_start = []; % Create empty list for storing bundle y start coordinates
bundle_y_coordinate_overlap = []; % Create empty list for overlapping y coordinates

for row_loop = 1:rows % For loop each bundle row (y direction)
    bundle_y_coordinate_start(end+1) = ((row_loop-1)*bundle_dimensions) + ((row_loop-1)*indent_spacing); % Work out bundle starting y coordinate
end

bundle_y_coordinate_start(1) = []; % Remove first bundle coordinate since this won't be overlapping

if row_overlap >= 0 % Check if user entered negative row overlap, i.e. a gap (process this differently below)
    
    % Identifying overlapping indent
    
    for coordinate_loop = [bundle_y_coordinate_start] % For loop each bundle starting overlapping coordinate
        for overlap_loop = 0:row_overlap % For loop through overlapping rows per bundle
            if overlap_loop == 0 % If no row overlap, do nothing
                % Do nothing
            else % Otherwise do this
                bundle_y_coordinate_overlap(end+1) = coordinate_loop + (overlap_loop-1)*indent_spacing; % Gets all overlapping y coordinates (of repeated indent)
            end
        end
    end
    struct_y_coordinate_list = [original_load_displacement.Y_Coordinate]; % Gets y coordinates from struct in order of entries
    overlapping_y_coordinate_indices = []; % Creates empty list for storing the indices (i.e. struct number)
    for overlapping_coordinate_loop = [bundle_y_coordinate_overlap] % For each overlapping y coordinate
        logical_y_coordinate_find = []; % Creates empty list for logical array (where 1 will give a find of the coordindate, 0 is other)
        single_y_coordinate_find_index = []; % Creates empty list for storing the index of where the logical array returns a 1
        logical_y_coordinate_find = struct_y_coordinate_list == overlapping_coordinate_loop; % Returns logical array for the coordinate being checked in this loop run through
        single_y_coordinate_find_index = find(logical_y_coordinate_find); % Returns indices of where logical array shows a find for the coordinate being checked in this loop
        for append_index_loop = [single_y_coordinate_find_index] % For each index found for this coordinate
            overlapping_y_coordinate_indices(end+1) = append_index_loop; % Appends indices for all overlapping y coordinates (each run through the loop)
        end
    end

    % Removing overlapping indent from dataset

    for y_index_loop = [overlapping_y_coordinate_indices] % For each index for overlapping y coordinate - note index corresponds to the struct indexing beggining at 1
        original_load_displacement(y_index_loop).X_Coordinate = -0.1; % These 2 lines change the overlapping indent coordinates in struct to -0.1 (unique as not integer) so may be identified when writing new struct below
        original_load_displacement(y_index_loop).Y_Coordinate = -0.1;
    end

    % Shifting y coordinates so it is continuous again (calls function)

    original_load_displacement = Coordinate_Shift("Y_Coordinate",original_load_displacement,indent_spacing,"continuous",0);

end

waitbar(1) % Updates wait bar when done
close(progress_bar) % Closes wait bar

%% Rewrite new struct with overlapping indents removed

progress_bar = waitbar(0,"Tidying Up Data Structure"); % Creates a progress bar

% Find required size of struct
struct_x_coordinate_list_shifted = [original_load_displacement.X_Coordinate]; % Gets newest list of x coordinates
number_of_overlap_indents_index = count(string(struct_x_coordinate_list_shifted),string(-0.1)); % Gives logical array of where the x coordinates have value -0.1
number_of_overlap_indents = sum(number_of_overlap_indents_index); % Sums up logical array to give total number of overlapping indents
number_of_non_overlapping_indents = length(struct_x_coordinate_list_shifted) - number_of_overlap_indents; % Gives number of non-overlapping indents

% Create new struct
non_overlapping_load_displacement = struct("Indent_Index",cell(number_of_non_overlapping_indents,1),"Displacement_Load_Data",cell(number_of_non_overlapping_indents,1),"X_Coordinate",cell(number_of_non_overlapping_indents,1),"Y_Coordinate",cell(number_of_non_overlapping_indents,1)); % Creates new empty struct
new_struct_count = 0; % Will be used below to keep track of which row to write to in new struct

% Transfer data
for original_struct_loop = 1:initial_number_of_data % For count through each indent in original struct
    completion_fraction = original_struct_loop/initial_number_of_data; % Calculates fraction for progress bar
    waitbar(completion_fraction); % Updates progress bar
    if original_load_displacement(original_struct_loop).X_Coordinate == -0.1 % If an overlapping indent
        % Do nothing
    else % If not overlapping indent, write to new struct
        new_struct_count = new_struct_count + 1; % Keeps track of row writing to in new struct (data written across in below 4 lines)
        non_overlapping_load_displacement(new_struct_count).Indent_Index = original_load_displacement(original_struct_loop).Indent_Index;
        non_overlapping_load_displacement(new_struct_count).Displacement_Load_Data = original_load_displacement(original_struct_loop).Displacement_Load_Data;
        non_overlapping_load_displacement(new_struct_count).X_Coordinate = original_load_displacement(original_struct_loop).X_Coordinate;
        non_overlapping_load_displacement(new_struct_count).Y_Coordinate = original_load_displacement(original_struct_loop).Y_Coordinate;
    end
end

close(progress_bar)
    
%% Adjust for gaps (i.e. negative overlap)
%  Will have to take into account previous shift when working out bundle start coordinates

progress_bar = waitbar(0,"Accounting for gaps between bundles"); % Creates a progress bar

if columns > 1 % Only run if more than one column
    if column_overlap < -0.1 % Only run if no overlap and user defines space with negative integer
        column_space = column_overlap*-1; % Convert to positive number for simplicity
        new_bundle_x_start_coordinates = []; % Create list for new bundle x start coordinates
        new_bundle_x_start_coordinates(1) = 0; % First bundle starts at 0
        for column_loop = 2:columns % For loop through remaining number of columns
            new_bundle_x_start_coordinates(end+1) = bundle_x_coordinate_start(column_loop-1) + (column_loop-1)*(indent_spacing*column_space); % Shift starting bundle coordinate by relevant amount
        end
        new_bundle_x_coordinates = []; % Create list for all new x coordinates
        for bundle_column_loop = [new_bundle_x_start_coordinates] % For each bundle column
            for indent_column_loop = 1:bundle_length % For each indent column in a bundle
                new_bundle_x_coordinates(end+1) = bundle_column_loop + (indent_column_loop-1)*indent_spacing; % Writes new x coordinates to list
            end
        end
        % Re-write coordinates
        non_overlapping_load_displacement = Coordinate_Shift("X_Coordinate",non_overlapping_load_displacement,indent_spacing,"not_continuous",new_bundle_x_coordinates);
    end
end

waitbar(0.5)

if rows > 1 % Only run if more than one row
    if row_overlap < -0.1 % Only run if no overlap and user defines space with negative integer
        row_space = row_overlap*-1; % Convert to positive number for simplicity
        new_bundle_y_start_coordinates = []; % Create list for new bundle y start coordinates
        new_bundle_y_start_coordinates(1) = 0; % First bundle starts at 0
        for row_loop = 2:rows % For loop through remaining number of rows
            new_bundle_y_start_coordinates(end+1) = bundle_y_coordinate_start(row_loop-1) + (row_loop-1)*(indent_spacing*row_space); % Shift starting bundle coordinate by relevant amount
        end
        new_bundle_y_coordinates = []; % Create list for all new y coordinates
        for bundle_row_loop = [new_bundle_y_start_coordinates] % For each bundle row
            for indent_row_loop = 1:bundle_length % For each indent row in a bundle
                new_bundle_y_coordinates(end+1) = bundle_row_loop + (indent_row_loop-1)*indent_spacing; % Writes new y coordinates to list
            end
        end
        % Re-write coordinates
        non_overlapping_load_displacement = Coordinate_Shift("Y_Coordinate",non_overlapping_load_displacement,indent_spacing,"not_continuous",new_bundle_y_coordinates);
    end
end

waitbar(1)
close(progress_bar)

%% Check for problem indents
%  Other conditions for excluding indents can be added here at a later date

if exclude_dodgy == "yes" % If user wishes to exclude dodgy indents later, run this
    non_overlapping_indents_count = length([non_overlapping_load_displacement.Indent_Index]);
    progress_bar = waitbar(0,"Checking for Problem Indents"); % Creates a progress bar
    bad_indents_list = []; % List for storing index of dodgy indents
    for indent_loop = 1:non_overlapping_indents_count % For count through each remaining indent
        completion_fraction = indent_loop/non_overlapping_indents_count; % Calculates fraction for progress bar
        waitbar(completion_fraction); % Updates progress bar
        displacement_data_test = non_overlapping_load_displacement(indent_loop).Displacement_Load_Data(:,1); % Gets all displacement data for indent
        maximum_indent_displacement_test = max(displacement_data_test); % Finds maximum displacement for indent
        maximum_index_test = find(displacement_data_test == maximum_indent_displacement_test); % Finds index in list where maximum displacement occured
        displacement_data_loading_test = displacement_data_test(1:maximum_index_test); % Appends loading displacement values
        minimum_displacement_data_test = min(displacement_data_loading_test); % Calculates minimum recorded displacement for indent in loading section
        if minimum_displacement_data_test < (-1*dodgy_tolerance) % If minimum displacement below threshold for bad data
            bad_indents_list(end+1) = non_overlapping_load_displacement(indent_loop).Indent_Index; % Appends bad indent index to naughty list
        end
    end
    close(progress_bar)
    number_dodgy = length(bad_indents_list);
    disp(strcat("Number of dodgy indents found is ",string(number_dodgy)," out of the original ",string(initial_number_of_data)," indents."))
end

%% Have even depth spacings (split into loading and unloading) with zeroed displacement data

% progress_bar = waitbar(0,"Creating Continuous Displacement Dataset"); % Creates a progress bar
% interpolated_load_displacement = non_overlapping_load_displacement;
% for indent_loop = 1:non_overlapping_indents_count % For count through each remaining indent
%     completion_fraction = indent_loop/non_overlapping_indents_count; % Calculates fraction for progress bar
%     waitbar(completion_fraction); % Updates progress bar
%     indent_displacement_data = non_overlapping_load_displacement(indent_loop).Displacement_Load_Data(:,1); % Gets all displacement data for indent
%     indent_load_data = non_overlapping_load_displacement(indent_loop).Displacement_Load_Data(:,2); % Gets all displacement data for indent
%     maximum_indent_displacement = max(indent_displacement_data); % Finds maximum displacement for indent
%     maximum_index = find(indent_displacement_data == maximum_indent_displacement); % Finds index in list where maximum displacement occured
%     indent_displacement_data_loading = indent_displacement_data(1:maximum_index); % Appends loading displacement values
%     indent_displacement_data_unloading = indent_displacement_data(maximum_index:length(indent_displacement_data)); % Appends unloading displacement values
%     indent_load_data_loading = indent_load_data(1:maximum_index); % Appends laoding load values
%     indent_load_data_unloading = indent_load_data(maximum_index:length(indent_displacement_data)); % Appends unloading load values
%     new_displacement_data = []; % List for storing new displacement data
%     new_load_data = []; % List for storing corresponding load data
%     new_data = []; % Create list for storing new displacement_load_data
%     maximum_indent_displacement = floor(maximum_indent_displacement); % Round maximum displacement down so able to interp
%     minimum_indent_displacement_loading = ceil(min(indent_displacement_data_loading)); % Round mimimum loading displacement up so able to interp
%     minimum_indent_displacement_unloading = ceil(min(indent_displacement_data_unloading)); % Round minimum unloading displacement up so able to interp
%     % Zero all displacement data (next 5 lines)
%     indent_displacement_data_loading = indent_displacement_data_loading - minimum_indent_displacement_loading;
%     indent_displacement_data_unloading = indent_displacement_data_unloading - minimum_indent_displacement_loading;
%     minimum_indent_displacement_unloading = minimum_indent_displacement_unloading - minimum_indent_displacement_loading;
%     maximum_indent_displacement = maximum_indent_displacement - minimum_indent_displacement_loading;
%     minimum_indent_displacement_loading = 0;
%     if minimum_indent_displacement_unloading <0 % Set minimum unloading displacement as 0 for interp if contains non-zero values
%         minimum_indent_displacement_unloading = 0;
%     end
%     for indent_displacement = minimum_indent_displacement_loading:0.1:maximum_indent_displacement % For each displacement step in loading, calculate interpolated values
%         try
%             load_value = interp1(indent_displacement_data_loading,indent_load_data_loading,indent_displacement);
%         catch
%             load_value = NaN;
%         end
%         new_displacement_data(end+1) = indent_displacement; % Append new interpolated values
%         new_load_data(end+1) = load_value;
%     end
%     for indent_displacement = maximum_indent_displacement:-0.1:minimum_indent_displacement_unloading % For each displacement step in unloading, calculate interpolated values
%         try
%             load_value = interp1(indent_displacement_data_unloading,indent_load_data_unloading,indent_displacement);
%         catch
%             load_value = NaN;
%         end
%         new_displacement_data(end+1) = indent_displacement; % Append new interpolated values
%         new_load_data(end+1) = load_value;
%     end
%     new_data(:,1) = new_displacement_data; % Append all new data to new list
%     new_data(:,2) = new_load_data;
%     interpolated_load_displacement(indent_loop).Displacement_Load_Data = []; % Delete old data from struct
%     interpolated_load_displacement(indent_loop).Displacement_Load_Data = new_data; % Write new interpolated data to struct
% end
% 
% close(progress_bar) % Close progress bar

%% Return values from function

final_load_displacement_data = original_load_displacement; % Rewrite struct for function output
bad_indents_list;

end

% 382 lines total 04/01/2023