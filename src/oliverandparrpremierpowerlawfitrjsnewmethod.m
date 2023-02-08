function [Fitting,naughty_indents_list,red_indents_list] = oliverandparrpremierpowerlawfitrjsnewmethod(base_file_directory,load_displacement_data,epsilon,samplepossionratio,tolerance,cutofdatavalue,cutofunloadingtoplim,cutofunloadingbottomlim,naughty_indents_list,red_indents_list,minimum_load_tolerance)

%     %code for importing the data for the displacement and load
%     %https://www.sciencedirect.com/topics/engineering/oliver-pharr-method
%     %link above for the method for oliver-parr method example
%     clear
%     close all
%     clc
%     
%     for k=0:9 %This for loop opens the first 10 files (note first indent is called indent 0)
%         filenames= sprintf('301122X65NG_0000%d.txt',k);%writes filename as string
%         indentnostring= sprintf('indent_%04d',k); %wrtie field name
%         indent_no= readtable(filenames, 'VariableNamingRule','preserve');%open file as table
%         indent_k=table2array(indent_no);
%         load_displacement_data.(indentnostring)=indent_k;%write into a structure
%     end
%     
%     %The following for loop is the same as before but accoutns for the 2
%     %digits by having 1 less 0 in the file name.
%     
%     for k=10:35
%         filenames= sprintf('301122X65NG_000%d.txt',k);
%         indent_no= readtable(filenames, 'VariableNamingRule','preserve');
%         indent_k=table2array(indent_no);
%         indentnostring= sprintf('indent_%04d',k);
%         load_displacement_data.(indentnostring)=indent_k;
%     end
%     %array of the filenames
%      fnms = fieldnames(load_displacement_data)
    %defining variables
%     epsilon=0.75; %indenter geometry function e.g. 0.75 
    %This opens the ara file (you have to convert it to a text file to get it
    %work)

area_function_path= strcat(base_file_directory,"Area_Function");
folder_info = dir(fullfile(area_function_path, '/*.txt'));
file_name = folder_info.name; 
full_file_name = fullfile(area_function_path, file_name); 
area_function=readlines(full_file_name);%takes each line of the text file and turns it into an array
C0=str2double(area_function(3));
C1=str2double(area_function(5));
C2=str2double(area_function(7));
C3=str2double(area_function(9));
C4=str2double(area_function(11));
C5=str2double(area_function(13)); 
%Values for the tips from the ara file
tipyoungmodulus=str2double(area_function(33)); %GPa
tippossionratio=str2double(area_function(31));
%user defined sample possion ratio
%     samplepossionratio=0.3;
%no of indents
noofindents= length([load_displacement_data.Indent_Index]);

%define figures and array to put data in
fig1 = figure;
fig2 = figure;
fig3 = figure;

values_of_H_and_E=[];  
progress_bar = waitbar(0,"Oliver and Parr Fitting"); % Creates a progress bar
nbytes = fprintf('Processing indent 0.'); % Initialising changing number display

for i=0:noofindents-1 % loop for each of the indents with zero corrections
    fprintf(repmat('\b',1,nbytes)) % Changing number display
    nbytes = fprintf('Processing indent %d.', i); % Changing number display
    j=i+1; % correcting zero problem when putting data into the arrays
    if ismember(load_displacement_data(j).Indent_Index,naughty_indents_list) % Note naughty list always contains red error indents, but only contains amber indents if user says so using exclude_dodgy
      % Do nothing
    else
        completion_fraction = i/(noofindents-1); % Calculates fraction for progress bar
        waitbar(completion_fraction); % Updates progress bar
        
        indentsnostring= sprintf('indent_%04d',i); %string of the field name
%         h=load_displacement_data.(indentsnostring)(:,1);%extracting displacement data from the array (nm)
%         P=(load_displacement_data.(indentnostring)(:,2)); %extracting load data from the array (uN)
        loading_P_h_data=load_displacement_data(j).Displacement_Load_Data;
        h=loading_P_h_data(:,1);
        P=loading_P_h_data(:,2);
        maximumh=max(h);
        
    %plot the raw data
%         figure(fig1);
%         plot(h,P,"black x")
%         ylabel("Load (uN)")
%         xlabel("displacment (nm)")
%         hold on
    % finding the unloading segment by finding when the gradient is below a
    % tolerance and then taking the max value of this index
%     
%     tolerance=0.01; 
        index = find( abs(gradient(P)) < tolerance );
        noofdatappoint=numel(P);
%     cutofdatavalue=0.95;
        limit=round(noofdatappoint*cutofdatavalue); %The user may want to edit this value
        indexcatch= find(index < limit);
        index =index(indexcatch);
        Pmaxindex=max(index);
        saving_Pmaxindex(j,1)=Pmaxindex;
    
%         try %dodgy indent for when it doesn't go below zero
        unloadingP=P(Pmaxindex:noofdatappoint); %extracting the unloading section of load
        unloadingh=h(Pmaxindex:noofdatappoint); % extracting the unloading section of load
        Pintercept = find(unloadingP < minimum_load_tolerance); %find the point where load is below zero
        findinghf=unloadingh(Pintercept); %from the index of the points where load is less than zero
        hf=max(findinghf); %find the maximum point of this array in order to extract the fitting parameter hf
%     hf=min(unloadingh);
        unloadinghminushf=unloadingh-hf; %this is value needed for the power law fit
        savinghf(j,1)= hf;
%         catch
%                   values_of_H_and_E(j,2) = NaN;
%         values_of_H_and_E(j,1) = i;
%         values_of_H_and_E(j,3)= NaN;
%         values_of_H_and_E(j,4)=NaN; 
%         values_of_H_and_E(j,5)=NaN;
%                 continue
%         end

        %This is what is special about this version- it removes some of the data in
        %order to help with the fit change.
        %noofunloadingdatapoints=numel(unloadingP); %totals the number of unloading points
%         try
        noofunloadingdatapoints=numel(unloadingP);
    %cutofunloadingtoplim=0.05;
    %cutofunloadingbottomlim=0.25;
        indextoplim=round(noofunloadingdatapoints*cutofunloadingtoplim); %This crops the top off the top 5% of the unloading data for the fit. The user may want to change this
        indexbottomlim=round(noofunloadingdatapoints*(1-cutofunloadingbottomlim)); %This crops off the bottom 25% of the unlodaing data for the fit. The user may want to change this
        unloadingPlim=unloadingP(indextoplim:indexbottomlim); %Getting the limited set from unloading load
        unloadinghminushflim=unloadinghminushf(indextoplim:indexbottomlim); %Getting the limited set from unloading diaplsement takeaway hf
%         catch
%          values_of_H_and_E(j,2) = NaN;
%         values_of_H_and_E(j,1) = i;
%         values_of_H_and_E(j,3)= NaN;
%         values_of_H_and_E(j,4)=NaN; 
%         values_of_H_and_E(j,5)=NaN;
%         end

    %powerlawfit 
        [xData, yData] = prepareCurveData( unloadinghminushflim, unloadingPlim );
        xData=flipud(xData); %This flips the data set so it goes from the smallest to the largest number
        yData=flipud(yData);
    
        w = (transpose((1:1:length(yData))).^2);% This is a sqaure weighing such that the top of the data is more accounted for in the fitting of the power law 
     
        try
            % Set up fittype and options.
            ft = fittype( 'power1' );
            opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
            opts.Display = 'Off';
            opts.StartPoint = [78.6937525155057 1.49509087940554];
            opts.Weights = (w);
            % Fit model to data.
            [fitresult, gof] = fit( xData, yData, ft, opts );
        catch % Error catch when poly fit not work
            naughty_indents_list(end+1) = load_displacement_data(j).Indent_Index; % Adds indent index to naughty list
            red_indents_list(end+1) = load_displacement_data(j).Indent_Index; % Adds indent index to red list
            naughty_indents_list = sort(naughty_indents_list); % Reorders naughty list
            red_indents_list = sort(red_indents_list); % Reorders red list
            %disp(strcat("Indent number ",[load_displacement_data(j).Indent_Index]," has also been added to the red list due to a fitting error.")) % Tells user of additional error indent
            load_displacement_data(j).Error_Code = strcat("Red: Fitting failed."); % Writes error code to struct
            load_displacement_data(j).Displacement_Load_Data = NaN; % Puts NaN value in struct data column, and lines below do it for the others also
            load_displacement_data(j).Hardness = NaN;
            load_displacement_data(j).Youngs_Modulus = NaN;
            load_displacement_data(j).Reduced_Modulus = NaN;
            load_displacement_data(j).Stiffness = NaN;
            load_displacement_data(j).Maximum_Load = NaN;
            load_displacement_data(j).Maximum_Displacement = NaN;
            load_displacement_data(j).Surface_Displacement = NaN;
            load_displacement_data(j).Hardness_Divided_By_Modulus = NaN;
            load_displacement_data(j).Stiffness_Squared_Divided_By_Load = NaN;
            % Since red error, values are written as NaN in data
            values_of_H_and_E(j,2) = NaN;
            values_of_H_and_E(j,1) = i;
            values_of_H_and_E(j,3) = NaN;
            values_of_H_and_E(j,4) = NaN; 
            values_of_H_and_E(j,5) = NaN;
            continue
        end
 
    %Plot fit with data.
%      figure(fig2);
%      plot(xData, yData, 'k.', 'DisplayName', 'Raw');
%      hold on
%      f_x = xData;
%      f_y =feval(fitresult, f_x);
%      plot(f_x, f_y, 'b-', 'DisplayName', 'PLF');
%      hold on
%      % Label axes
%      xlabel( 'unloadinghminushf', 'Interpreter', 'none' );
%      ylabel( 'unloadingP', 'Interpreter', 'none' );
%      grid on
%      hold on
    
        %find the derivative of the power law at the Pmax point
        derivativeofpowerlaw=differentiate(fitresult,unloadinghminushf);
        S=derivativeofpowerlaw(1); %stiffness
        savings(j,1)=S;
    
        Pmax=max(unloadingP); %maximum of the the unloading load array
        FindPmax= find(unloadingP == Pmax);%finding the value of the maximum load
        hmax=unloadingh(FindPmax); %find the value of h at Pmax
%     
%      %plotting the gradient line
%      c=Pmax-(S*hmax);
%     lineplot=(S*h)+c;
%      figure(fig1)
%      plot(h,lineplot,"red :",LineWidth=1.2);
%      Pmaxrange= Pmax+200;
%      ylim([0 Pmaxrange])
%     hold on
    
        %Oliver and Parr maths
        hc = hmax-(epsilon*(Pmax/S)); %standard equation
        Ac = (C0*(hc^2))+(C1*hc)+(C2*(hc^(1/2)))+(C3*(hc^(1/4)))+(C4*(hc^(1/8)))+(C5*(hc^(1/16))); %tip area function
        H = (Pmax/Ac)*10^3; %Hardness in (GPa)
        Er= (sqrt(pi)/2)*(S/(sqrt(Ac)))*10^3; %Reduced modulus in (GPa)
        SampleEwithvin = 1/((1/Er) - (1-(tippossionratio^2))/tipyoungmodulus); 
        E = (SampleEwithvin*(1-(samplepossionratio^2))); %Young's modulus in (GPa)
        %putting values into array 
        values_of_H_and_E(j,2) = real(H);
        values_of_H_and_E(j,1) = i;
        values_of_H_and_E(j,3)= real(Er);
        values_of_H_and_E(j,4)=real(E);
        values_of_H_and_E(j,5)=real(S);

        header = {'No of indents','Hardness (GPa)','Reduced Young Modulus (GPa)' 'Young Modulus (GPa)' 'Stiffness (uN/nm'}; %headers for the array
        valuesofHandEoutput = [header; num2cell(values_of_H_and_E)]; %make an array for outputting data;
        writecell (valuesofHandEoutput,'X80CMX11000') %change the file name
    

    load_displacement_data(j).Maximum_Displacement=hmax;
    load_displacement_data(j).Maximum_Load=Pmax;
    

%close(progress_bar) % Closes progress bar

for rowhc=1:length(values_of_H_and_E(:,1))
    load_displacement_data(rowhc).Hardness=values_of_H_and_E(rowhc,2);
    load_displacement_data(rowhc).Reduced_Modulus=values_of_H_and_E(rowhc,3);
    load_displacement_data(rowhc).Youngs_Modulus=values_of_H_and_E(rowhc,4);
    load_displacement_data(rowhc).Stiffness=values_of_H_and_E(rowhc,5);
end
    end
end
 
Fitting=load_displacement_data;
close(progress_bar); % Closes progress bar
figure(fig3);
Important_Popup= imread("Importantpopup.png");
imshow(Important_Popup);

end % Function end





