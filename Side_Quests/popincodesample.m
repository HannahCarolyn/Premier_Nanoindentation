function[popinfittingsample,naughty_indents_list,red_indents_list] = popincodesample(base_file_directory,mapping_type,updated_main_data_struct,tolerancepopin,smoothingvalue,MPH,naughty_indents_list,red_indents_list,cutofflow,cutoffhigh,samplesize,numberofexpectedpopin);
noofindents=length([updated_main_data_struct.Indent_Index]);
%samplesize=10;
%indentnotoinvestigate=15;
 fig1=figure;
  fig2=figure;
  

sampleindentsnumbers=randi([0,noofindents-1],samplesize,1);

%numberofexpectedpopin=6;
valuesofpopinPsaving = zeros([noofindents numberofexpectedpopin]);
valuesofpopinPsaving_grad =zeros([noofindents numberofexpectedpopin]);
values_of_popin_grad=[];

for i=1:samplesize; % loop for each of the indents with zero corrections

    sampleindentnumberforloop=sampleindentsnumbers(i);
%        fprintf(repmat('\b',1,nbytes)) % Changing number display
%     nbytes = fprintf('Processing indent %d.', i); % Changing number display
    j=sampleindentnumberforloop+1; % correcting zero problem when putting data into the arrays
%     completion_fraction = i/(noofindents-1); % Calculates fraction for progress bar
%         waitbar(completion_fraction); % Updates progress bar
   % if ismember(updated_main_data_struct(j).Indent_Index,naughty_indents_list) % Note naughty list always contains red error indents, but only contains amber indents if user says so using exclude_dodgy
      % Do nothing
   % else
    
     values_of_popin=[];
     dataabovelower=[];
    if mapping_type == "automated_indentation_grid_array"
            indentsnostring= sprintf('indent_%04d',i); %string of the field name
            loading_P_h_data=updated_main_data_struct(j).Displacement_Load_Data;
    
            h=loading_P_h_data(:,1);
            P=loading_P_h_data(:,2);
            
            numberofpoints=numel(h);
    
   
    
       % loading section of curve
    
    
    
        tolerance=0.01; 
        index = find( abs(gradient(P)) < tolerance );
        noofdatappoint=numel(P);
        limit=round(noofdatappoint*0.95); %unhard code this
        indexcatch= find(index < limit);
        index =index(indexcatch);
        Pmaxindex=max(index);
        saving_Pmaxindex(j,1)=Pmaxindex;
            loadingP=P(1:Pmaxindex); %extracting the loading section of load
        loadingh=h(1:Pmaxindex); % extracting the loading section of load
    
      else if mapping_type == "xpm_indentation_map"
                  indentsnostring= sprintf('indent_%04d',i); %string of the field name
            loading_P_h_data=updated_main_data_struct(j).Loading_Segment;
    
            loadingh=loading_P_h_data(:,1);
            loadingP=loading_P_h_data(:,2);
        end
    end

    loadingPabovelowerindex= find(loadingP >cutofflow);
    loadingPabovelower=loadingP(loadingPabovelowerindex);
    loadinghabovelower=loadingh(loadingPabovelowerindex);
    dataabovelower(:,1)=loadingPabovelower;
    dataabovelower(:,2)=loadinghabovelower;

   smoothingvalue=7;
   smoothloading_P_h_data=smoothdata(dataabovelower,'movmean',smoothingvalue);
   smoothloadingPabovelower=smoothloading_P_h_data(:,1);
   smoothloadinghabovelower=smoothloading_P_h_data(:,2);


         %plot the raw data
     figure(fig1);
        plot(loadinghabovelower,loadingPabovelower,"black x","MarkerSize",3)
        ylabel("Load (uN)")
        xlabel("displacement (nm)")
        title("Sample Indent Pop-in Fitting")
        legend 'Raw Data' 'Smooth Data' 'Displacement Change Fit' 'Gradient Change Fit'
        hold on

     figure(fig1);
        plot(smoothloadinghabovelower,smoothloadingPabovelower,"blue")
        ylabel("Load (uN)")
        xlabel("displacement (nm)")
        hold on



figure(fig2)
changeindisp=diff(loadinghabovelower);
changeindisp(end+1)=NaN;
plot(loadinghabovelower,changeindisp);
hold on
xlabel 'displacement (nm)'
ylabel 'Change in displacement'
legend 'Displacement Change Fit'
title("Sample Indent Peak Finding")
% MPH=0.4;
[PKS,LOCS]=findpeaks(changeindisp,'MinPeakHeight',MPH);
popindex=LOCS-1;
no_of_popinindex=numel(popindex);


 for popin=1:1:no_of_popinindex
popin_index=popindex(popin);
popinP=loadingPabovelower(popin_index);
popinh=loadinghabovelower(popin_index);
values_of_popin(popin,1)= popin_index;
values_of_popin(popin,2)= popinP;
values_of_popin(popin,3)= popinh;

figure(fig1)
plot(popinh,popinP,"red x","MarkerSize",10)
hold on
        
 end
values_of_popin_indents.(indentsnostring)=values_of_popin;

 


try
values_of_popinP=values_of_popin_indents.(indentsnostring)(:,2);
noofvaluesofpopinP=numel(values_of_popinP);
valuesofpopinPsaving(j,1:1:noofvaluesofpopinP)=values_of_popinP;
valuesofpopinPsaving(valuesofpopinPsaving == 0) = NaN;
catch
valuesofpopinPsaving(j,1)= NaN;
valuesofpopinPsaving(valuesofpopinPsaving == 0) = NaN;
end



%updated_main_data_struct(j).PopinData=valuesofpopinPsaving(j,:);


% figure(fig5)
%  title 'Pop-in load against indent number'
%  ylabel 'Pop-in load (uN)'
%  xlabel 'Indent number'
%  
% 
% if isnan(valuesofpopinPsaving(j,1)) 
%     figure(fig5)
%     y=0;
%     plot(i,y, "red o")
%     hold on
% else
%     figure(fig5)
%     plot(i,valuesofpopinPsaving(j,:), "black x");
%     hold on
% 
% end
% legend 'Marker for no indents' 'Pop-in'

popinfittingsample=valuesofpopinPsaving;

    end
end