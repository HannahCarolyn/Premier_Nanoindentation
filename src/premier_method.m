function [updated_data_struct] = premier_method(base_file_directory,updated_main_data_struct,mapping_type,naughty_indents_list,samplepossionratio)

% Values used in Young's Modulus calculation from tip area function file (copied from Hannah Oliver and Parr):
area_function_path = strcat(base_file_directory,"Area_Function"); % Gets area function path
folder_info = dir(fullfile(area_function_path, '/*.txt')); % Gets text file info
file_name = folder_info.name; % Gets area function file name
full_file_name = fullfile(area_function_path, file_name); % Gets are function full file name with path
area_function = readlines(full_file_name);% Takes each line of the text file and turns it into an array
tipyoungmodulus=str2double(area_function(33)); % Tip Youngs Modulus in GPa
tippoissonratio=str2double(area_function(31)); % Tip Poisson's ratio

% Get data in case of mapping:
if mapping_type == "xpm_indentation_map"
    premier_data_locations = strcat(base_file_directory,"Coordinate_Data"); % Gets the full folder path for the premier data (same file as coordinates)
    folder_info = dir(fullfile(premier_data_locations, '/*.txt')); % Gets a list of file properties within the folder
    number_of_bundles = size(folder_info,1); % Counts number of files in the folder
    all_data = []; % Creates empty list for storing all data
    for file_loop = 1:number_of_bundles
        file_name = folder_info(file_loop).name; % Extract file name of bundle
        full_file_name = fullfile(premier_data_locations, file_name); % Extract file name (including path) for each indent
        full_input = importdata(full_file_name); % Extracts contents of file as struct depending on data structure
        data_input = full_input.data; % Selects only the numerical data
        for data_row = 1:length(data_input(:,1)) % Loop through each row of data
            all_data(end+1,:) = data_input(data_row,:); % Append each row of data
        end
    end
    for indent_loop = 1:length([updated_main_data_struct.Indent_Index]) % For count through number of indents in struct
        if ismember(updated_main_data_struct(indent_loop).Indent_Index,naughty_indents_list) % Note naughty list always contains all error indents now
            updated_main_data_struct(indent_loop).Maximum_Displacement = NaN; % NaN each value for this indent
            updated_main_data_struct(indent_loop).Maximum_Load = NaN;
            updated_main_data_struct(indent_loop).Surface_Displacement = NaN;
            updated_main_data_struct(indent_loop).Hardness = NaN;
            updated_main_data_struct(indent_loop).Reduced_Modulus = NaN;
            updated_main_data_struct(indent_loop).Youngs_Modulus = NaN;
            updated_main_data_struct(indent_loop).Stiffness = NaN;
            updated_main_data_struct(indent_loop).Hardness_Divided_By_Modulus = NaN;
            updated_main_data_struct(indent_loop).Stiffness_Squared_Divided_By_Load = NaN;
        else
            current_indent_index = updated_main_data_struct(indent_loop).Indent_Index; % Find index (starting at 0) of current indent
            updated_main_data_struct(indent_loop).Maximum_Displacement = all_data(current_indent_index+1,5); % all_data(current_indent_index+1,?); % Find relevant values taking into account row index 1 more than indent index
            updated_main_data_struct(indent_loop).Maximum_Load = all_data(current_indent_index+1,2);
            updated_main_data_struct(indent_loop).Hardness = all_data(current_indent_index+1,8);
            Er = all_data(current_indent_index+1,7); % Er has seperate value as used to calculate Young's Modulus Below
            updated_main_data_struct(indent_loop).Reduced_Modulus = Er; % Append Er
            SampleEwithvin = 1/((1/Er) - (1-(tippoissonratio^2))/tipyoungmodulus); % Middle calculation step
            E = (SampleEwithvin*(1-(samplepossionratio^2))); %Young's modulus in (GPa) (copied from Hannah Oliver and Parr)
            updated_main_data_struct(indent_loop).Youngs_Modulus = E; % Append E
            updated_main_data_struct(indent_loop).Stiffness = all_data(current_indent_index+1,3); % Append stiffness
            updated_data_struct=updated_main_data_struct;
        end
    end

% Get data in case of grid array:
else if mapping_type == "automated_indentation_grid_array"
        premier_data_locations = strcat(base_file_directory,"Premier_Analysis"); % Gets the full folder path for the premier data (same file as coordinates)
        folder_info = dir(fullfile(premier_data_locations, '/*.txt')); % Gets a list of file properties within the folder
        noofindents= length([updated_main_data_struct.Indent_Index]);

        for file_loop = 1:1:noofindents % For count through number of indents in folder (note all indents are used so no need to bother with indent indices)
            if ismember(updated_main_data_struct(file_loop).Indent_Index,naughty_indents_list) % Note naughty list always contains all error indents now
                updated_main_data_struct(file_loop).Maximum_Displacement = NaN; % NaN each value for this indent
                updated_main_data_struct(file_loop).Maximum_Load = NaN;
                updated_main_data_struct(file_loop).Surface_Displacement = NaN;
                updated_main_data_struct(file_loop).Hardness = NaN;
                updated_main_data_struct(file_loop).Reduced_Modulus = NaN;
                updated_main_data_struct(file_loop).Youngs_Modulus = NaN;
                updated_main_data_struct(file_loop).Stiffness = NaN;
                updated_main_data_struct(file_loop).Hardness_Divided_By_Modulus = NaN;
                updated_main_data_struct(file_loop).Stiffness_Squared_Divided_By_Load = NaN;
            else
                file_name = folder_info.name;
                full_file_name = fullfile(premier_data_locations, file_name); % Extract file name (including path) for each indent
                full_input = importdata(full_file_name); % Extracts contents of file as struct depending on data structure
                data_input = full_input.data; % Selects only the numerical data
                
                
                updated_main_data_struct(file_loop).Maximum_Displacement = data_input(file_loop,5); % NaN each value for this indent
                updated_main_data_struct(file_loop).Maximum_Load = data_input(file_loop,2);
                updated_main_data_struct(file_loop).Surface_Displacement = NaN;
                updated_main_data_struct(file_loop).Hardness = data_input(file_loop,8);
                updated_main_data_struct(file_loop).hf=data_input(file_loop,10);
                Er = data_input(file_loop,7);
                updated_main_data_struct(file_loop).Reduced_Modulus = data_input(file_loop,7);
                SampleEwithvin = 1/((1/Er) - (1-(tippoissonratio^2))/tipyoungmodulus); % Middle calculation step
                E = (SampleEwithvin*(1-(samplepossionratio^2))); %Young's modulus in (GPa) (copied from Hannah Oliver and Parr)
                updated_main_data_struct(file_loop).Youngs_Modulus = E;
                updated_main_data_struct(file_loop).Stiffness = data_input(file_loop,3);
                updated_data_struct=updated_main_data_struct;

            end
        end
end



end
end
        