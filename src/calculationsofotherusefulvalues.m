function[doessomemath,naughty_indents_list,red_indents_list] = calculationsofotherusefulvalues(base_file_directory,updated_data_struct,naughty_indents_list,red_indents_list)

%progress_bar = waitbar(0,"Calculating Extra Values"); % Creates a progress bar
noofindents= length([updated_data_struct.Indent_Index]);
for j=1:noofindents % loop for each of the indents with zero correction
 
    if ismember(updated_data_struct(j).Indent_Index,naughty_indents_list) % Note naughty list always contains red error indents, but only contains amber indents if user says so using exclude_dodgy
      % Do nothing
    else
        %completion_fraction = j/(noofindents); % Calculates fraction for progress bar
        %waitbar(completion_fraction); % Updates progress bar
        
LoadingHardness=updated_data_struct(j).Hardness;
LoadingModulus=updated_data_struct(j).Youngs_Modulus;
LoadingStiffness=updated_data_struct(j).Stiffness;
LoadingPmax=updated_data_struct(j).Maximum_Load;

Hardnessdividedbymodulus=LoadingHardness/LoadingModulus;
Stiffnesssqaureddividedbyload=((LoadingStiffness^2)/LoadingPmax);

updated_data_struct(j).Hardness_Divided_By_Modulus=Hardnessdividedbymodulus;
updated_data_struct(j).Stiffness_Squared_Divided_By_Load=Stiffnesssqaureddividedbyload;

    end
    doessomemath=updated_data_struct;

%close(progress_bar)
   
end
