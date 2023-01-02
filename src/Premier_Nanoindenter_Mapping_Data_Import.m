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
    for x_index_loop = [overlapping_x_coordinate_indices] % For each index for overlapping x coordinate - note index corresponds to the struct indexing beggining at 1
        original_load_displacement(x_index_loop).X_Coordinate = -0.1; % These 2 lines change the overlapping indent coordinates in struct to -0.1 (unique as not integer) so may be identified when writing new struct below
        original_load_displacement(x_index_loop).Y_Coordinate = -0.1;
    end

    % Shifting x coordinates so it is continuous again

    struct_x_coordinate_list_updated = [original_load_displacement.X_Coordinate]; % Gets updated x coordinates from struct into list
    x_coordinate_list_once = unique(struct_x_coordinate_list_updated); % Finds unique value of updated x coordinates in sorted order
    x_coordinate_list_once(1) = []; % Removes the -0.1 value so not effect the below
    new_x_dimension = length(x_coordinate_list_once); % Finds new total x dimension (number of indents, i.e. number of unique columns left)
    new_x_coordinate_list_once = [0:indent_spacing:(new_x_dimension-1)*indent_spacing]; % Create list which will have alterations applied and compared to original later on
    for new_x_coordinate_loop = 1:new_x_dimension % For going through indices of each x coordinate value once
        if x_coordinate_list_once(new_x_coordinate_loop) == new_x_coordinate_list_once(new_x_coordinate_loop) % If value unchanged, do nothing
            % Do nothing
        else
            logical_x_coordinate_find_to_change = []; % Creates empty list for logical array (where 1 will give a find of the coordindate, 0 is other)
            single_x_coordinate_find_index_to_change = []; % Creates empty list for storing the index of where the logical array returns a 1
            logical_x_coordinate_find_to_change = struct_x_coordinate_list_updated == x_coordinate_list_once(new_x_coordinate_loop); % Returns logical array for the original coordinate being checked in this loop run through that needs to be shifted to new value
            single_x_coordinate_find_index_to_change = find(logical_x_coordinate_find_to_change); % Returns indices of where logical array shows a find for the coordinate being checked in this loop
            for change_index_loop = [single_x_coordinate_find_index_to_change] % For each index found for this coordinate
                original_load_displacement(change_index_loop).X_Coordinate = new_x_coordinate_list_once(new_x_coordinate_loop); % Changes old x coordinate to new x coordinate
            end
        end
    end
end

%% Exclude bundle row overlap and take into account bundle gaps (shift y as needed)

waitbar(0.5) % Updates wait bar halfway

bundle_y_coordinate_start = []; % Create empty list for storing bundle y start coordinates

for row_loop = 1:rows % For loop each bundle row (y direction)
    bundle_y_coordinate_start(end+1) = ((row_loop-1)*bundle_dimensions) + ((row_loop-1)*indent_spacing); % Work out bundle starting y coordinate
end

bundle_y_coordinate_start(1) = []; % Remove first bundle coordinate since this won't be overlapping

bundle_y_coordinate_overlap = []; % Create empty list for overlapping y coordinates

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
    for y_index_loop = [overlapping_y_coordinate_indices] % For each index for overlapping y coordinate - note index corresponds to the struct indexing beggining at 1
        original_load_displacement(y_index_loop).X_Coordinate = -0.1; % These 2 lines change the overlapping indent coordinates in struct to -0.1 (unique as not integer) so may be identified when writing new struct below
        original_load_displacement(y_index_loop).Y_Coordinate = -0.1;
    end

    % Shifting y coordinates so it is continuous again

    struct_y_coordinate_list_updated = [original_load_displacement.Y_Coordinate]; % Gets updated y coordinates from struct into list
    y_coordinate_list_once = unique(struct_y_coordinate_list_updated); % Finds unique value of updated y coordinates in sorted order
    y_coordinate_list_once(1) = []; % Removes the -0.1 value so not effect the below
    new_y_dimension = length(y_coordinate_list_once); % Finds new total y dimension (number of indents, i.e. number of unique rows left)
    new_y_coordinate_list_once = [0:indent_spacing:(new_y_dimension-1)*indent_spacing]; % Create list which will have alterations applied and compared to original later on
    for new_y_coordinate_loop = 1:new_y_dimension % For going through indices of each y coordinate value once
        if y_coordinate_list_once(new_y_coordinate_loop) == new_y_coordinate_list_once(new_y_coordinate_loop) % If value unchanged, do nothing
            % Do nothing
        else
            logical_y_coordinate_find_to_change = []; % Creates empty list for logical array (where 1 will give a find of the coordindate, 0 is other)
            single_y_coordinate_find_index_to_change = []; % Creates empty list for storing the index of where the logical array returns a 1
            logical_y_coordinate_find_to_change = struct_y_coordinate_list_updated == y_coordinate_list_once(new_y_coordinate_loop); % Returns logical array for the original coordinate being checked in this loop run through that needs to be shifted to new value
            single_y_coordinate_find_index_to_change = find(logical_y_coordinate_find_to_change); % Returns indices of where logical array shows a find for the coordinate being checked in this loop
            for change_index_loop = [single_y_coordinate_find_index_to_change] % For each index found for this coordinate
                original_load_displacement(change_index_loop).Y_Cooordinate = new_y_coordinate_list_once(new_y_coordinate_loop); % Changes old y coordinate to new y coordinate
            end
        end
    end
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
    
%% Adjust for gaps - will have to take into account previous shift when working out bundle start coordinates

%% Check for problem indents

%% Have even depth spacings (split into loading and unloading)








load_displacement_data = 1;
bad_indents_list = 1;



end