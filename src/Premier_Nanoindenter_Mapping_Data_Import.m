function [load_displacement_data,indent_positions,bad_indents_list] = Premier_Nanoindenter_Mapping_Data_Import(base_file_directory,xpm_pattern,rows,columns,bundle_spacing,row_overlap,column_overlap,exclude_dodgy)
    
%% Importing all indentation data    
indent_file_locations = strcat(base_file_directory,"Indent_Data"); % Gets the full folder path for the indentation data
folder_info = dir(fullfile(indent_file_locations, '/*.txt')); % Gets a list of file properties within the folder
initial_number_of_data = size(folder_info,1); % Counts number of files in the folder

progress_bar = waitbar(0,"Importing Indentation Data"); % Creates a progress bar

for file_loop = 1:initial_number_of_data % For count through number of indents in folder
    completion_fraction = file_loop/initial_number_of_data; % Calculates fraction for progress bar
    waitbar(completion_fraction); % Updates progress bar
    file_name = folder_info(file_loop).name; % Extract file name of indent
    full_file_name = fullfile(indent_file_locations, file_name); % Extract file name (including path) for each indent
    full_input = importdata(full_file_name); % Extracts contents of file as struct depending on data structure
    data_input = full_input.data; % Selects only the numerical data
    raw_input(:,1) = data_input(:,1); % Loads uncorrected depth values into table
    raw_input(:,2) = data_input(:,2); % Loads uncorrected load values into table
    struct_indent_name = strcat("Original_Indent_",string(file_loop-1)); % Converts the loop indent number into a string for naming the struct row "Original_Indent_X", X may be obtained later for ease of manipulation, as per file names the indents start at 0
    original_load_displacment.(struct_indent_name) = raw_input; % Appends the displacement-load table into struct
end

close(progress_bar) % Closes progress bar

%need to convert serpentine to lateral
%then convert lateral to full grid
%then exclude overlap
%then check for problem indents
%then have even depth spacings (split into loading and unloading and
%recombine)








load_displacement_data = 1;
indent_positions = 1;
bad_indents_list = 1;



end