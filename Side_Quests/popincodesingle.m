function [popinfittingsingle,naughty_indents_list,red_indents_list] = popincodesingle(base_file_directory,tolerancepopin,smoothingvalue,MPH,naughty_indents_list,red_indents_list,cutofflow,cutoffhigh,individual_indent_no,numberofexpectedpopin);
noofindents=length([updated_main_data_struct.Indent_Index]);

%samplesize=10;
%indentnotoinvestigate=15;
 fig1=figure;
  fig2=figure;
  


%numberofexpectedpopin=6;
valuesofpopinPsaving = zeros([noofindents numberofexpectedpopin]);
i=individual_indent_no;


%        fprintf(repmat('\b',1,nbytes)) % Changing number display
%     nbytes = fprintf('Processing indent %d.', i); % Changing number display
    j=i+1; % correcting zero problem when putting data into the arrays
%     completion_fraction = i/(noofindents-1); % Calculates fraction for progress bar
%         waitbar(completion_fraction); % Updates progress bar
   % if ismember(updated_main_data_struct(j).Indent_Index,naughty_indents_list) % Note naughty list always contains red error indents, but only contains amber indents if user says so using exclude_dodgy
      % Do nothing
   % else
    
     values_of_popin=[];
     dataabovezero=[];
    
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
    loadingPabovezeroindex= find(loadingP >1);
    loadingPabovezero=loadingP(loadingPabovezeroindex);
    loadinghabovezero=loadingh(loadingPabovezeroindex);
    dataabovezero(:,1)=loadingPabovezero;
    dataabovezero(:,2)=loadinghabovezero;

   smoothingvalue=7;
   smoothloading_P_h_data=smoothdata(dataabovezero,'movmean',smoothingvalue);
   smoothloadingPabovezero=smoothloading_P_h_data(:,1);
   smoothloadinghabovezero=smoothloading_P_h_data(:,2);


         %plot the raw data
     figure(fig1);
        plot(loadinghabovezero,loadingPabovezero,"black x","MarkerSize",3)
        ylabel("Load (uN)")
        xlabel("displacement (nm)")
        title("Single Indent Pop-in Finding")
        hold on

     figure(fig1);
        plot(smoothloadinghabovezero,smoothloadingPabovezero,"blue")
        ylabel("Load (uN)")
        xlabel("displacement (nm)")
        hold on

%finding pop-ins from displacement
figure(fig2)
changeindisp=diff(loadinghabovezero);
changeindisp(end+1)=NaN;
plot(loadinghabovezero,changeindisp);
hold on
xlabel 'displacement (nm)'
ylabel 'Change in displacment'
title("Single Indent Peak Finding")
% MPH=0.4;
[PKS,LOCS]=findpeaks(changeindisp,'MinPeakHeight',MPH);
popindex=LOCS-1;
no_of_popinindex=numel(popindex);

 for popin=1:1:no_of_popinindex
popin_index=popindex(popin);
popinP=loadingPabovezero(popin_index);
popinh=loadinghabovezero(popin_index);
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

popinfittingsingle=valuesofpopinPsaving;
   
end