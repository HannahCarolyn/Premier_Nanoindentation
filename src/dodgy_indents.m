function [updated_main_data_struct,naughty_indents_list] = dodgy_indents(load_displacement_data,amber_indents_list,red_indents_list,exclude_dodgy)

%% Firstly, get correct naughty list

naughty_indents_list = []; % Create empty naughty list
if exclude_dodgy == "no" % If amber indents not to be excluded from calculations, only put red indents on naughty list
    naughty_indents_list = red_indents_list;
else if exclude_dodgy == "yes" % If amber indents to be included
        naughty_indents_list = red_indents_list; % First write red indents
        for indent = [amber_indents_list] % Go through each amber and add to list
            naughty_indents_list(end+1) = indent;
        end
    end
end
naughty_indents_list = sort(naughty_indents_list); % Put list in order of indent indices

%% Secondly write NaN in struct where naughty

progress_bar = waitbar(0,"Dealing with those naughty indents"); % Creates a progress bar
waitbar_count = 0; % Count variable for waitbar
for indent = [naughty_indents_list] % For through each naughty indent
    waitbar_count = waitbar_count + 1 % Increment for loop count for wait bar
    completion_fraction = waitbar_count/length(naughty_indents_list); % Calculates fraction for progress bar
    waitbar(completion_fraction); % Updates wait bar
    load_displacement_data(indent+1).Displacement_Load_Data = NaN; % This line and below writes NaN where naughy index (note +1 to go from indent index to struct index)
    load_displacement_data(indent+1).Hardness = NaN;
    load_displacement_data(indent+1).Youngs_Modulus = NaN;
    load_displacement_data(indent+1).Reduced_Modulus = NaN;
    load_displacement_data(indent+1).Stiffness = NaN;
    load_displacement_data(indent+1).Maximum_Load = NaN;
    load_displacement_data(indent+1).Maximum_Displacement = NaN;
    load_displacement_data(indent+1).Surface_Displacement = NaN;
    load_displacement_data(indent+1).Hardness_Divided_By_Modulus = NaN;
    load_displacement_data(indent+1).Stiffness_Squared_Divided_By_Load = NaN;
end
close(progress_bar); % Close wait bar
updated_main_data_struct = load_displacement_data; % Rename struct for function output

% Important_Popup = imread("Importantpopup2.png");
% figure(figure);
% imshow(Important_Popup);
% pause(5);
% close all;

end