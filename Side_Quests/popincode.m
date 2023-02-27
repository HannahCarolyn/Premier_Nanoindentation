function [popinfitting,naughty_indents_list,red_indents_list,updated_main_data_struct] = popincode(base_file_directory,updated_main_data_struct,tolerancepopin,smoothingvalue,MPH,naughty_indents_list,red_indents_list,cutofflow,cutoffhigh,numberofexpectedpopin)
close all

    progress_bar = waitbar(0,"Pop-In Fitting"); % Creates a progress bar
nbytes = fprintf('Processing indent 0.'); % Initialising changing number display
noofindents=length([updated_main_data_struct.Indent_Index]);
samplesize=10;
 fig1=figure;
  fig2=figure;
  fig3=figure;
  fig4=figure;
  fig5=figure;


%numberofexpectedpopin=6;
  valuesofpopinPsaving = zeros([noofindents numberofexpectedpopin]);

for i=0:noofindents-1 % loop for each of the indents with zero corrections
       fprintf(repmat('\b',1,nbytes)) % Changing number display
    nbytes = fprintf('Processing indent %d.', i); % Changing number display
    j=i+1; % correcting zero problem when putting data into the arrays
    completion_fraction = i/(noofindents-1); % Calculates fraction for progress bar
        waitbar(completion_fraction); % Updates progress bar
    if ismember(updated_main_data_struct(j).Indent_Index,naughty_indents_list) % Note naughty list always contains red error indents, but only contains amber indents if user says so using exclude_dodgy
      % Do nothing
    else
    
     values_of_popin=[];
     dataabovezero=[];
    
        indentsnostring= sprintf('indent_%04d',i); %string of the field name
        loading_P_h_data=updated_main_data_struct(j).Displacement_Load_Data;

        h=loading_P_h_data(:,1);
        P=loading_P_h_data(:,2);
        
        numberofpoints=numel(h);

%          maximumh=max(h);
%         if maximumh > 700 %unhard code this
%     valuesofpopinPsaving(j,1)= NaN;
%             continue
%           
%         end

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
%      figure(fig1);
%         plot(loadinghabovezero,loadingPabovezero,"black x","MarkerSize",3)
%         ylabel("Load (uN)")
%         xlabel("displacement (nm)")
%         hold on
% 
%      figure(fig1);
%         plot(smoothloadinghabovezero,smoothloadingPabovezero,"blue")
%         ylabel("Load (uN)")
%         xlabel("displacement (nm)")
%         hold on

%finding pop-ins from displacement
% figure(fig4)
changeindisp=diff(loadinghabovezero);

%changeindisp(end+1)=NaN;
% plot(loadinghabovezero,changeindisp);
hold on
xlabel 'displacement (nm)'
ylabel 'Change in displacment'
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

% figure(fig1)
% plot(popinh,popinP,"red x","MarkerSize",10)
% hold on
%         
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
updated_main_data_struct(j).PopinData=valuesofpopinPsaving(j,:);





%    %finding pop-ins from displacement
%    tolerancepop=1.5; 
%    popingindex = find( abs(diff(loadinghabovezero)) > tolerancepop );
%    no_of_popinindex=numel(popingindex);
% 
% 
% 
% for popin=1:1:no_of_popinindex
% popin_index=popingindex(popin);
% popinP=loadingPabovezero(popin_index);
% popinh=loadinghabovezero(popin_index);
% values_of_popin(popin,1)= popin_index;
% values_of_popin(popin,2)= popinP;
% values_of_popin(popin,3)= popinh;
% 
% figure(fig1)
% plot(popinh,popinP,"red o")
% hold on
% %         
% end
% 
% values_of_popin_diff.(indentnostring)=values_of_popin;
% 
% try
% valuesofpopinP=(values_of_popin_diff.(indentnostring)(:,2))';
% noofvaluesofpopinP=numel(valuesofpopinP);
% valuesofpopinPsaving(j,1:1:noofvaluesofpopinP)=valuesofpopinP;
% valuesofpopinPsaving(valuesofpopinPsaving == 0) = NaN;
% catch
% valuesofpopinPsaving(j,1:1:noofvaluesofpopinP)= NaN;
% end
% 
% if isnan(valuesofpopinPsaving(j,1)) == true
%     continue
% end
% 
% if noofvaluesofpopinP == 1
%     valuesofpopinPsavingsingle(j,1)=valuesofpopinPsaving(j,1);
%     continue
% 
% end
% 
% valuesofpopinPdiff=abs(diff(valuesofpopinPsaving(j,:)));
% noofvaluesofpopinPdiff=numel(valuesofpopinPdiff);
% valuesofpopinPsavingdiff(j,1:1:noofvaluesofpopinPdiff)=valuesofpopinPdiff;
% 
% for differencevalues=1:1:noofvaluesofpopinPdiff
%     if valuesofpopinPsavingdiff(j,differencevalues) < 10
%         valuesofpopinPsaving(j,(differencevalues+1))=NaN;
%     end    
% end

%    %finding pop-ins from smooth gradient
%    tolerancesmoothpop=0.5;
%    smoothpopingindex = find((abs(gradient(smoothloadinghabovezero))) > tolerancesmoothpop);
%    smooth_no_of_popinindex=numel(smoothpopingindex);
% 
% for smoothpopin=1:1:smooth_no_of_popinindex
% smooth_popin_index=smoothpopingindex(smoothpopin);
% smoothpopinP=smoothloadingPabovezero(smooth_popin_index);
% smoothpopinh=smoothloadinghabovezero(smooth_popin_index);
% values_of_popin_smooth(smoothpopin,1)= smooth_popin_index;
% values_of_popin_smooth(smoothpopin,2)= smoothpopinP;
% values_of_popin_smooth(smoothpopin,3)= smoothpopinh;
% 
% figure(fig1)
% plot(smoothpopinh,smoothpopinP,"cyan x")
% hold on
% %         
% end
% 
% values_of_popin_diff_smooth.(indentnostring)=values_of_popin_smooth;
% 
% try
% valuesofpopinPsmooth=(values_of_popin_diff_smooth.(indentnostring)(:,2))';
% noofvaluesofpopinPsmooth=numel(valuesofpopinPsmooth);
% valuesofpopinPsavingsmooth(j,1:1:noofvaluesofpopinPsmooth)=valuesofpopinPsmooth;
% valuesofpopinPsavingsmooth(valuesofpopinPsavingsmooth == 0) = NaN;
% catch
% valuesofpopinPsavingsmooth(j,1:1:noofvaluesofpopinPsmooth)= NaN;
% end
% 
% if isnan(valuesofpopinPsavingsmooth(j,1)) == true
%     continue
% end
% 
% if noofvaluesofpopinPsmooth == 1
%     valuesofpopinPsavingsinglesmooth(j,1)=valuesofpopinPsavingsmooth(j,1);
%     continue
% 
% end
% 
% valuesofpopinPdiffsmooth=abs(diff(valuesofpopinPsavingsmooth(j,:)));
% noofvaluesofpopinPdiffsmooth=numel(valuesofpopinPdiffsmooth);
% valuesofpopinPsavingdiffsmooth(j,1:1:noofvaluesofpopinPdiffsmooth)=valuesofpopinPdiffsmooth;

% for differencevaluessmooth=1:1:noofvaluesofpopinPdiffsmooth
%     if valuesofpopinPsavingdiffsmooth(j,differencevaluessmooth) < 10
%         valuesofpopinPsavingsmooth(j,(differencevaluessmooth+1))=NaN;
%     end    
% end
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


end
%close(progress_bar) % Closes progress bar

popinfitting=valuesofpopinPsaving;
% 
for i=0:noofindents-1
    j=i+1;
    for k=1:numberofexpectedpopin;
        if popinfitting(j,k) < cutoffhigh
            popinfittingabovecutoffhigh(j,k)= NaN;
        else
            popinfittingabovecutoffhigh(j,k) = popinfitting(j,k);
        end

        if cutofflow>popinfitting(j,k) 
            popinfittinglimited(j,k)= NaN;
        else
            popinfittinglimited(j,k) = popinfitting(j,k);
        end
         if popinfitting(j,k) > cutoffhigh
            popinfittinglimited(j,k)= NaN;
        else
            popinfittinglimited(j,k) = popinfitting(j,k);
        end
    end

    noofpopinsabovecutoff=nnz(~isnan(popinfittingabovecutoffhigh(j,:)));
    noofpopinsbetweenlimits=nnz(~isnan(popinfittinglimited(j,:)));
    updated_main_data_struct(j).No_Pop_in_Data_Above_Cut_off=noofpopinsabovecutoff;
    updated_main_data_struct(j).No_Pop_in_Data_Between_Limits=noofpopinsbetweenlimits;
end

    end


valuesofpopinPsavingvector = valuesofpopinPsaving(:);
frequencyofpopins=nnz(~isnan(valuesofpopinPsavingvector));
figure(fig2)
histogram(valuesofpopinPsavingvector,150);
xlabel 'Pop-in Load (uN)'
ylabel 'Frequency'
title 'Large Pop-in Histogram'


% cutofflow=0;
% cutoffhigh=120;
valuesofpopinPlimitedindex = find(cutofflow < valuesofpopinPsavingvector  & valuesofpopinPsavingvector < cutoffhigh); %unhard code this
valuesofpopinPlimited=valuesofpopinPsavingvector(valuesofpopinPlimitedindex);
frequencyofpopinslimited=nnz(~isnan(valuesofpopinPlimited));


figure(fig3)
histogram(valuesofpopinPlimited,20);
xlabel 'Pop-in Load (uN)'
ylabel 'Frequency'
title 'Narrow Pop-in Histogram'
popinlimmean= mean(valuesofpopinPlimited);
popinlimstd = std(valuesofpopinPlimited);
popinlimmedian= median(valuesofpopinPlimited);
popinlimstderror=(popinlimstd)./(sqrt(frequencyofpopinslimited));
hold on
xline(popinlimmean,"red");
xline(popinlimmedian, "blue")
hold off

    

disp(strcat("Total frequency of Pop-ins is ", string(frequencyofpopins)));
disp(strcat("Frequency of Pop-ins above ", string(cutofflow)," uN and below ", string(cutoffhigh), " uN is " , string(frequencyofpopinslimited)));
disp(strcat("The following data is calculated from the pop-ins below the limited range see line above."));
disp(strcat("Mean of Pop-ins ", string(popinlimmean)," +/- ", string(popinlimstderror), " uN"));
disp(strcat("Median of Pop-ins ", string(popinlimmedian), " uN"));
disp(strcat("Standard Deviation of Pop-ins ", string(popinlimstd), " uN"));