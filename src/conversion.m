function conversion(updated_main_data_struct,output_conversion_file_directory)

%% Getting required info and setting up 3D arrays

all_x_coordinates = [updated_main_data_struct.X_Coordinate]; % Gets all x coordinates
number_of_data = length(all_x_coordinates); % Gets number of indents
unique_x_coordinates = unique(all_x_coordinates); % Create non-repeated list of all x coordinates in ascending order
max_x_coordinate = max(all_x_coordinates); % Finds maximum x coordinate
all_y_coordinates = [updated_main_data_struct.Y_Coordinate]; % Gets all y coordinates
% Create non-repeated list of all y coordinates in ascending order
max_y_coordinate = max(all_y_coordinates); % Finds maximum y coordinate
coordinate_spacing = unique_x_coordinates(2) - unique_x_coordinates(1); % Calculates coordinate spacing from difference between two x coordinates

fullres = zeros(((max_x_coordinate + coordinate_spacing)./coordinate_spacing),((max_y_coordinate + coordinate_spacing)./coordinate_spacing),6); % Sets up 3D array with correct number of elements for (in order): Surface Displacement, Displacement into Surface, Load on Sample, Youngs Modulus, Stiffness^2/Load and Hardness
fullresloc = zeros(((max_x_coordinate + coordinate_spacing)./coordinate_spacing),((max_y_coordinate + coordinate_spacing)./coordinate_spacing),2); % Sets up 3D array with correct number of elements for x (1) and y (2) coordinates, see below
fullres_additional = zeros(((max_x_coordinate + coordinate_spacing)./coordinate_spacing),((max_y_coordinate + coordinate_spacing)./coordinate_spacing),9); % 3D array with some extra useful values for nice excel output (in order): Hardness, Youngs Modulus, Reduced Modulus, Stiffness, Maximum Load, Maximum Displacement, Surface Displacement, Hardness divided by Modulus, Stiffness Squared divided by Modulus
fullres_orientated = zeros(((max_y_coordinate + coordinate_spacing)./coordinate_spacing),((max_x_coordinate + coordinate_spacing)./coordinate_spacing),9); % Same as above but will be rotated to heat map coordinates rather than for CMM method

%% Firstly sort out coordinates in fullresloc

% Note convention in 3D array (visually) is as follows for CMM code for (0,0) starting at bottom left in actual sample (excel output variant will be as per heat map coordinates):

% X: 0 ----- 0    Y: 0 ---- Max
%    |       |       |       |
%    |       |       |       |
%   Max --- Max      0 ---- Max

possible_x_coordinates = []; % Create empty list
possible_x_coordinates = 0:coordinate_spacing:max_x_coordinate; % Generate unique set of x coordinates in ascending order (takes into account gaps by giving them a coordinate also)
progress_bar = waitbar(0,"Converting x-coordinate set to CMM format"); % Creates a progress bar
for x_coordinate_index = 1:length(possible_x_coordinates) % Loop through each possible x coordinate
    fullresloc(x_coordinate_index,:,1) = possible_x_coordinates(x_coordinate_index); % Writes each coordinate to entire row in sheet 1 of 3D array
    completion_fraction = x_coordinate_index/length(possible_x_coordinates); % Calculates fraction for progress bar
    waitbar(completion_fraction); % Updates progress bar
end
close(progress_bar) % Closes progress bar
    
possible_y_coordinates = []; % Create empty list
possible_y_coordinates = 0:coordinate_spacing:max_y_coordinate; % Generate unique set of y coordinates in ascending order (takes into account gaps by giving them a coordinate also)
progress_bar = waitbar(0,"Converting y-coordinate set to CMM format"); % Creates a progress bar
for y_coordinate_index = 1:length(possible_y_coordinates) % Loop through each possible y coordinate
    fullresloc(:,y_coordinate_index,2) = possible_y_coordinates(y_coordinate_index); % Writes each coordinate to entire row in sheet 1 of 3D array
    completion_fraction = y_coordinate_index/length(possible_y_coordinates); % Calculates fraction for progress bar
    waitbar(completion_fraction); % Updates progress bar
end
close(progress_bar) % Closes progress bar

%% Secondly find the right data for these coordinates

progress_bar = waitbar(0,"Rewriting Data to CMM format"); % Creates a progress bar
for x_coordinate_index = 1:length(possible_x_coordinates) % Loop through each possible x coordinate
    x_coordinate = possible_x_coordinates(x_coordinate_index); % Notes current x coordinate
    x_coordinate_find_indices = find(all_x_coordinates == x_coordinate,number_of_data); % Find indent indices corresponding to x coordinate
    completion_fraction = x_coordinate_index/length(possible_x_coordinates); % Calculates fraction for progress bar
    waitbar(completion_fraction); % Updates progress bar
    for y_coordinate_index = 1:length(possible_y_coordinates) % Loop through each possible y coordinate
        y_coordinate = possible_y_coordinates(y_coordinate_index); % Notes current y coordinate
        y_coordinate_find_indices = find(all_y_coordinates == y_coordinate,number_of_data); % Find indent indices corresponding to y coordinate
     % try % Try used in case gap in data in which case indent coordinate pair not exist 
            indent_field_index = intersect(x_coordinate_find_indices,y_coordinate_find_indices); % Finds the specific indent of the current x,y coordinates based on struct field number (not indent number)
            % Writes values in correct order in fullres for CMM XPCorrelate
            fullres(x_coordinate_index,y_coordinate_index,1) = NaN; %updated_main_data_struct(indent_field_index).Surface_Displacement;
            fullres(x_coordinate_index,y_coordinate_index,2) = updated_main_data_struct(indent_field_index).Maximum_Displacement;
            fullres(x_coordinate_index,y_coordinate_index,3) = updated_main_data_struct(indent_field_index).Maximum_Load;
            fullres(x_coordinate_index,y_coordinate_index,4) = updated_main_data_struct(indent_field_index).Modulus;
            fullres(x_coordinate_index,y_coordinate_index,5) = updated_main_data_struct(indent_field_index).Stiffness_Squared_Divided_By_Load;
            fullres(x_coordinate_index,y_coordinate_index,6) = updated_main_data_struct(indent_field_index).Hardness;
            % Writes values in fullres_additional for excel output (currently wrong orientation for output)
            fullres_additional(x_coordinate_index,y_coordinate_index,1) = updated_main_data_struct(indent_field_index).Hardness;
            fullres_additional(x_coordinate_index,y_coordinate_index,2) = updated_main_data_struct(indent_field_index).Modulus;
            fullres_additional(x_coordinate_index,y_coordinate_index,3) = updated_main_data_struct(indent_field_index).Reduced_Modulus;
            fullres_additional(x_coordinate_index,y_coordinate_index,4) = updated_main_data_struct(indent_field_index).Stiffness;
            fullres_additional(x_coordinate_index,y_coordinate_index,5) = updated_main_data_struct(indent_field_index).Maximum_Load;
            fullres_additional(x_coordinate_index,y_coordinate_index,6) = updated_main_data_struct(indent_field_index).Maximum_Displacement;
            %fullres_additional(x_coordinate_index,y_coordinate_index,7) = updated_main_data_struct(indent_field_index).Surface_Displacement;
            fullres_additional(x_coordinate_index,y_coordinate_index,8) = updated_main_data_struct(indent_field_index).Hardness_Divided_By_Modulus;
            fullres_additional(x_coordinate_index,y_coordinate_index,9) = updated_main_data_struct(indent_field_index).Stiffness_Squared_Divided_By_Load;
%         catch % If coordinate pair not exist, NaN values written instead
%             % Writes values in correct order in fullres for CMM XPCorrelate
%             fullres(x_coordinate_index,y_coordinate_index,1) = NaN;
%             fullres(x_coordinate_index,y_coordinate_index,2) = NaN;
%             fullres(x_coordinate_index,y_coordinate_index,3) = NaN;
%             fullres(x_coordinate_index,y_coordinate_index,4) = NaN;
%             fullres(x_coordinate_index,y_coordinate_index,5) = NaN;
%             fullres(x_coordinate_index,y_coordinate_index,6) = NaN;
%             % Writes values in fullres_additional for excel output (currently wrong orientation for output)
%             fullres_additional(x_coordinate_index,y_coordinate_index,1) = NaN;
%             fullres_additional(x_coordinate_index,y_coordinate_index,2) = NaN;
%             fullres_additional(x_coordinate_index,y_coordinate_index,3) = NaN;
%             fullres_additional(x_coordinate_index,y_coordinate_index,4) = NaN;
%             fullres_additional(x_coordinate_index,y_coordinate_index,5) = NaN;
%             fullres_additional(x_coordinate_index,y_coordinate_index,6) = NaN;
%             fullres_additional(x_coordinate_index,y_coordinate_index,7) = NaN;
%             fullres_additional(x_coordinate_index,y_coordinate_index,8) = NaN;
%             fullres_additional(x_coordinate_index,y_coordinate_index,9) = NaN;
        %end
    end
end
close(progress_bar) % Closes progress bar

%% Thirdly, convert fullres_additional to heat map orientation for nice excel output

% o ---- y              y            fullres_orientated is only for visualisation in excel output and should never be used for code data handling
% |            --->     |
% |                     |
% x                     o ---- x

progress_bar = waitbar(0,"Generating Excel Data Output"); % Creates a progress bar
for sheet_index = 1:9 % Loop through each fullres_additional sheet
    completion_fraction = sheet_index/9; % Calculates fraction for progress bar
    waitbar(completion_fraction); % Updates progress bar
    for y_coordinate_index = 1:length(possible_y_coordinates) % Loop through each column (i.e. all x coordinates of a given y coordinate in ascending x)
            given_y_coordinate_data_set = [fullres_additional(:,y_coordinate_index,sheet_index)]; % Gets all data values for given y coordinate in ascending x coordinate
            fullres_orientated(end+1-y_coordinate_index,:,sheet_index) = given_y_coordinate_data_set; % Writes these values to rows in orientated version starting from bottom
    end
end
close(progress_bar) % Closes progress bar

%% Finally save files

excel_file_name = strcat(output_conversion_file_directory,"\","Excel_Output.xlsx"); % Creates full file name
% These write to excel sheets:
xlswrite(excel_file_name,[fullres_orientated(:,:,1)],"Hardness (GPa)");
xlswrite(excel_file_name,[fullres_orientated(:,:,2)],"Modulus (GPa)");
xlswrite(excel_file_name,[fullres_orientated(:,:,3)],"Reduced Modulus (GPa)");
xlswrite(excel_file_name,[fullres_orientated(:,:,4)],"Stiffness (uN nm^-1)");
xlswrite(excel_file_name,[fullres_orientated(:,:,5)],"Maximum Load (uN)");
xlswrite(excel_file_name,[fullres_orientated(:,:,6)],"Maximum Displacement (nm)");
xlswrite(excel_file_name,[fullres_orientated(:,:,7)],"Surface Displacement (nm)");
xlswrite(excel_file_name,[fullres_orientated(:,:,8)],"Hardness over Modulus");
xlswrite(excel_file_name,[fullres_orientated(:,:,9)],"S^2 over P (uN (nm^2)^-1)");
% Delete "sheet1"
newExcel = actxserver('excel.application');
newExcel.DisplayAlerts = false; % Hide are you sure pop-up
excelWB = newExcel.Workbooks.Open(excel_file_name,0,false);
excelWB.Sheets.Item(1).Delete;
excelWB.Save();
excelWB.Close();
newExcel.Quit();
delete(newExcel);

% Create any extra variables needed for CMM:
X = fullresloc(:,:,1);
Y = fullresloc(:,:,2);
folders = split(output_conversion_file_directory,"\");
filename = folders(end-1);
resultsdir = output_conversion_file_directory;

% Save selected variables in workspace file
workspace_file = strcat(output_conversion_file_directory,"\", "Workspace_Output_2");
save(workspace_file,"filename","resultsdir","X","Y","fullres");

disp("All data converted to appropriate formats.")

end