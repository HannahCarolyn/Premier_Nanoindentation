clear all  
data_path= "D:\premier\week1HT\Sample6L450CMX11000\Sample6L450CMX11000CMXoutput\CMXoutput";
    folder_info = dir(fullfile(data_path, '/*.txt'));
    initial_number_of_data = size(folder_info,1);
    for file_loop = 1:initial_number_of_data
    file_name = folder_info(file_loop).name;
    full_file_name = fullfile(data_path, file_name);
    full_input = importdata(full_file_name);
    data_input = full_input.data;
    raw_input = [];
    raw_input(:,1) = data_input(:,2); %indentdepth
    raw_input(:,2) = data_input(:,17); %hardness
    raw_input(:,3) = data_input(:,15);%storagemodulus

    original_CMX_Data(file_loop).Indent_Index = file_loop-1; % Writes indent number to struct (starting indexing at zero as per files)
    original_CMX_Data(file_loop).Data = raw_input;

    end
    fig1=figure;
    fig2=figure;

 for i=0:1:99
    j=i+1;
    indent_CMX_data=original_CMX_Data(j).Data;
    indentdepthforindent=indent_CMX_data(:,1);
    Hardnessforindent=indent_CMX_data(:,2);
    Storagemodulusforindent=indent_CMX_data(:,3);

    %hardness processing
    Lowerdepthcutoff=100;
    findindexoflowcutoff=find(indentdepthforindent < 100);
    indexoflowcutoff=max(findindexoflowcutoff);
    Upperdepthcutoff=300;
    findindexofuppercutoff=find(indentdepthforindent < 300);
    indexofuppercutoff=max(findindexofuppercutoff);
    rangeindentdepth=indentdepthforindent(indexoflowcutoff:indexofuppercutoff,:);
    rangehardness=Hardnessforindent(indexoflowcutoff:indexofuppercutoff,:);
    rangestoragemodulus=Storagemodulusforindent(indexoflowcutoff:indexofuppercutoff,:);

    averagehardness=mean(rangehardness);
    averagestoragemodlus=mean(rangestoragemodulus);


    values_of_averageH_and_E(j,2) = averagehardness;
    values_of_averageH_and_E(j,1) = i;
    values_of_averageH_and_E(j,3)= real(averagestoragemodlus);


    original_CMX_Data(j).Average_Hardness=averagehardness;
    original_CMX_Data(j).Average_Storage_Modulus=averagestoragemodlus;


    
    figure(fig1)
    plot(indentdepthforindent,Hardnessforindent)
    xline(Lowerdepthcutoff);
    xline(Upperdepthcutoff);
    hold on
    
   

    figure(fig2)
    plot(indentdepthforindent,Storagemodulusforindent)
    xline(Lowerdepthcutoff);
    xline(Upperdepthcutoff);
    hold on
 end

 
  header = {'No of indents','Average Hardness (GPa)','Average Storage Modulus (GPa)'}; %headers for the array
  valuesofaverageHandEoutput = [header; num2cell(values_of_averageH_and_E)]; %make an array for outputting data;
    
  writecell (valuesofaverageHandEoutput,'L450CMXoutput11000') %change the file name