function [load_displacement_data,amber_indents_list,red_indents_list] = Premier_mapping_import_V2(base_file_directory,rows,columns,spacing,row_overlap,column_overlap,negative_displacement_tolerance,minimum_load_tolerance);

indent_file_locations = strcat(base_file_directory,"Indent_Data"); % Gets the full folder path for the indentation data
folder_info = dir(fullfile(indent_file_locations, '/*.txt')); % Gets a list of file properties within the folder
initial_number_of_data = size(folder_info,1); % Counts number of files in the folder


progress_bar = waitbar(0,"Importing Indentation Data - seperate"); % Creates a progress bar
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


load_function_path= strcat(base_file_directory,"Load_Function");
folder_info = dir(fullfile(load_function_path, '/*.txt'));
file_name = folder_info.name; 
full_file_name = fullfile(load_function_path, file_name); 
load_function=readlines(full_file_name);%takes each line of the text file and turns it into an array
Indexnoofseqpoints = find(contains(load_function,'NumofSeqPoints'));

noofsegments=3;

for segmentno=1
   Indexforsegment=Indexnoofseqpoints(1+segmentno);
   noofseqpointsforsegmentstring=load_function(Indexforsegment);
   noofseqpointsforsegment = sscanf(noofseqpointsforsegmentstring, '%d_→:NumofSeqPoints');
   for file_loop = 1:initial_number_of_data
       extractingPandH=original_load_displacement(file_loop).Displacement_Load_Data;
       Pandhforsegment=extractingPandH(1:noofseqpointsforsegment,1:2);
       original_load_displacement(file_loop).Loadingsegment = Pandhforsegment;
   end
 
end

for segmentno=noofsegments
   Indexforsegment=Indexnoofseqpoints(1+segmentno);
   noofseqpointsforsegmentstring=load_function(Indexforsegment);
   noofseqpointsforsegment = sscanf(noofseqpointsforsegmentstring, '%d_→:NumofSeqPoints');
   for file_loop = 1:initial_number_of_data
       extractingPandH=original_load_displacement(file_loop).Displacement_Load_Data;
       Pandhforsegment=extractingPandH(end-noofseqpointsforsegment-1:end,1:2);
       original_load_displacement(file_loop).UnloadingSegment = Pandhforsegment;
   end
 
end

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

%% Check for problem indents
%  Other conditions for excluding indents can be added here at a later date

% Amber warning: displacement drops below dodgy tolerance
non_overlapping_indents_count = length([original_load_displacement.Indent_Index]);
progress_bar = waitbar(0,"Checking for Problem Indents - Amber Warning"); % Creates a progress bar
amber_indents_list = []; % List for storing index of dodgy indents
for indent_loop = 1:non_overlapping_indents_count % For count through each remaining indent
    completion_fraction = indent_loop/non_overlapping_indents_count; % Calculates fraction for progress bar
    waitbar(completion_fraction); % Updates progress bar
    displacement_data_test = original_load_displacement(indent_loop).Displacement_Load_Data(:,1); % Gets all displacement data for indent
    maximum_indent_displacement_test = max(displacement_data_test); % Finds maximum displacement for indent
    maximum_index_test = find(displacement_data_test == maximum_indent_displacement_test); % Finds index in list where maximum displacement occured
    displacement_data_loading_test = displacement_data_test(1:maximum_index_test); % Appends loading displacement values
    minimum_displacement_data_test = min(displacement_data_loading_test); % Calculates minimum recorded displacement for indent in loading section
    if minimum_displacement_data_test < (-1*negative_displacement_tolerance) % If minimum displacement below threshold for bad data
        amber_indents_list(end+1) = original_load_displacement(indent_loop).Indent_Index; % Appends bad indent index to naughty list
        original_load_displacement(indent_loop).Error_Code = strcat("Amber: Displacement drops below ",string(-1*negative_displacement_tolerance)," um"); % Writes error code to struct
    end
end
close(progress_bar)

number_dodgy = length(amber_indents_list);
disp(strcat("Number of dodgy indents in amber category due to displacements dropping below ",string(-1*negative_displacement_tolerance)," um is ",string(number_dodgy)," indents."))
  
% Red warning: indent load never drops below zero

progress_bar = waitbar(0,"Checking for Problem Indents - Red Warning"); % Creates a progress bar
red_indents_list = []; % List for storing index of dodgy indents
for indent_loop = 1:non_overlapping_indents_count % For count through each remaining indent
    completion_fraction = indent_loop/non_overlapping_indents_count; % Calculates fraction for progress bar
    waitbar(completion_fraction); % Updates progress bar
    load_data_test = original_load_displacement(indent_loop).Displacement_Load_Data(:,2); % Gets all load data for indent
    minimum_load_test = min(load_data_test(20:end)); % Excludes first few points in case those are also negative
    if minimum_load_test > minimum_load_tolerance % If minimum displacement below threshold for bad data
        red_indents_list(end+1) = original_load_displacement(indent_loop).Indent_Index; % Appends bad indent index to naughty list
        original_load_displacement(indent_loop).Error_Code = strcat("Red: Load does not drop below ",string(minimum_load_tolerance)," um when unloading."); % Writes error code to struct
    end
end
close(progress_bar)

number_dodgy = length(red_indents_list);
disp(strcat("Number of dodgy indents in red category due to unloading load not dropping below ",string(minimum_load_tolerance)," um is ",string(number_dodgy)," indents."))

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

%% Zero the displacement data

progress_bar = waitbar(0,"Zeroing Displacement from Initial Loading Value"); % Creates a progress bar
zeroed_load_displacement = original_load_displacement;
for indent_loop = 1:initial_number_of_data % For count through each remaining indent
    completion_fraction = indent_loop/initial_number_of_data; % Calculates fraction for progress bar
    waitbar(completion_fraction); % Updates progress bar
    indent_displacement_data = original_load_displacement(indent_loop).Displacement_Load_Data(:,1); % Gets all displacement data for indent
    indent_load_data = original_load_displacement(indent_loop).Displacement_Load_Data(:,2); % Gets all displacement data for indent
    new_displacement_data = []; % List for storing new displacement data
    new_data = []; % Create list for storing new displacement_load_data
    minimum_indent_displacement_loading = indent_displacement_data(1); % Round mimimum loading displacement up so able to interp
    new_displacement_data = indent_displacement_data - minimum_indent_displacement_loading;
    new_data(:,1) = new_displacement_data; % Append all new data to new list
    new_data(:,2) = indent_load_data;
    zeroed_load_displacement(indent_loop).Displacement_Load_Data = []; % Delete old data from struct
    zeroed_load_displacement(indent_loop).Displacement_Load_Data = new_data; % Write new data to struct
    zeroed_load_displacement(indent_loop).Surface_Displacement = minimum_indent_displacement_loading; % Write surface displacement value to struct
end

close(progress_bar) % Close progress bar


amber_indents_list = [];
red_indents_list = [];

load_displacement_data = zeroed_load_displacement; % Rewrite struct for function output
amber_indents_list;
red_indents_list;
end







