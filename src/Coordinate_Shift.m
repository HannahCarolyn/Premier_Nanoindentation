function [cs_original_struct] = Coordinate_Shift(cs_coordinate_axis,cs_original_struct,indent_spacing,continuous,cs_new_coordinates)

% This function transposes coordinates (user defines either x or y) from 
% the coordinates in the struct to "cs_new coordinates"; cs_ prefix indicates
% local data structure to this function

progress_bar_shift = waitbar(0,"Applying Coordinate Shift"); % Creates a progress bar

cs_original_coordinates = [cs_original_struct.(cs_coordinate_axis)]; % Gets updated coordinates from struct into list
cs_original_coordinate_list_once = unique(cs_original_coordinates); % Finds unique value of updated coordinates in sorted order
if cs_original_coordinate_list_once(1) == -0.1 % If -0.1 value present (i.e. if coordinates removed)
    cs_original_coordinate_list_once(1) = []; % Removes the -0.1 value so not effect the below
end
cs_coordinate_dimension = length(cs_original_coordinate_list_once); % Finds number of original coordinates
if continuous == "continuous" % If coordinates are to made continuous in the axis direction (no gaps), calculate the values here
    cs_new_coordinate_list_once = [0:indent_spacing:(cs_coordinate_dimension-1)*indent_spacing]; % Create list which will have alterations applied and compared to original later on
else % Otherwise take user inputted values for different calculation
    cs_new_coordinate_list_once = unique(cs_new_coordinates); % Create list to which original coordinates will be transposed to
end
for cs_unique_coordinate_loop = 1:cs_coordinate_dimension % For going through indices of each coordinate value once
    completion_fraction = cs_unique_coordinate_loop/cs_coordinate_dimension; % Calculates fraction for progress bar
    waitbar(completion_fraction); % Updates progress bar
    if cs_original_coordinate_list_once(cs_unique_coordinate_loop) == cs_new_coordinate_list_once(cs_unique_coordinate_loop) % If value unchanged, do nothing
        % Do nothing
    else
        cs_logical_original_coordinate_find = []; % Creates empty list for logical array (where 1 will give a find of the original coordindate, 0 is other)
        cs_single_coordinate_find_index = []; % Creates empty list for storing the index of where the logical array returns a 1
        cs_logical_original_coordinate_find = cs_original_coordinates == cs_original_coordinate_list_once(cs_unique_coordinate_loop); % Returns logical array for the original coordinate being checked in this loop run through
        cs_single_coordinate_find_index = find(cs_logical_original_coordinate_find); % Returns indices of where logical array shows a find for the coordinate being checked in this loop
        for cs_coordinate_to_change_index_loop = [cs_single_coordinate_find_index] % For each index found for this coordinate
            cs_original_struct(cs_coordinate_to_change_index_loop).(cs_coordinate_axis) = cs_new_coordinate_list_once(cs_unique_coordinate_loop); % Changes old coordinate to new coordinate in struct
        end
    end
end

close(progress_bar_shift) % Closes progress bar

%end