function[doessomemath,naughty_indents_list,red_indents_list] = calculationsofotherusefulvalues(base_file_directory,load_displacement_data,main_data_struct,naughty_indents_list,red_indents_list)

noofindents= length([load_displacement_data.Indent_Index]);
for j=1:noofindents % loop for each of the indents with zero correction
 
    if ismember(load_displacement_data(j).Indent_Index,naughty_indents_list) % Note naughty list always contains red error indents, but only contains amber indents if user says so using exclude_dodgy
      % Do nothing
    else
        completion_fraction = j/(noofindents); % Calculates fraction for progress bar
        waitbar(completion_fraction); % Updates progress bar
        
LoadingHardness=main_data_struct(j).Hardness;
LoadingModulus=main_data_struct(j).Youngs_Modulus;
LoadingStiffness=main_data_struct(j).Stiffness;
LoadingPmax=main_data_struct(j).Maximum_Load;

Hardnessdividedbymodulus=LoadingHardness/LoadingModulus;
Stiffnesssqaureddividedbyload=((LoadingStiffness^2)/LoadingPmax);

main_data_struct(j).Hardness_Divided_By_Modulus=Hardnessdividedbymodulus;
main_data_struct(j).Stiffness_Sqaured_Divided_By_Load=Stiffnesssqaureddividedbyload;

    end
    doessomemath=main_data_struct;
   
end
