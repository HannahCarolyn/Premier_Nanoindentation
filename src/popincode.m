%function [HCpopinfitting] = popincode(base_file_directory,load_displacement_data,tolerance,tolerancepop)


    progress_bar = waitbar(0,"Pop-In Fitting"); % Creates a progress bar
noofindents=length([load_displacement_data.Indent_Index]);
 fig1=figure;
  fig2=figure;
  fig3=figure;
  fig4=figure;
for i=0:noofindents-1 % loop for each of the indents with zero corrections
     
    completion_fraction = i/(noofindents-1); % Calculates fraction for progress bar
        waitbar(completion_fraction); % Updates progress bar
    indentnostring= sprintf('indent_%04d',i); %wrtie field name
     values_of_popin=[];
     dataabovezero=[];
        j=i+1; % correcting zero problem when putting data into the arrays
        indentsnostring= sprintf('indent_%04d',i); %string of the field name
        loading_P_h_data=load_displacement_data(j).Displacement_Load_Data;
        
        h=loading_P_h_data(:,1);
        P=loading_P_h_data(:,2);
        
        numberofpoints=numel(h);

         maximumh=max(h);
        if maximumh > 700 %unhard code this
    valuesofpopinPsaving(j,1)= NaN;
            continue
          
        end

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

   smoothloading_P_h_data=smoothdata(dataabovezero,'movmedian',10);
   smoothloadingPabovezero=smoothloading_P_h_data(:,1);
   smoothloadinghabovezero=smoothloading_P_h_data(:,2);


         %plot the raw data
     figure(fig1);
        plot(loadinghabovezero,loadingPabovezero,"black x","MarkerSize",3)
        ylabel("Load (uN)")
        xlabel("displacement (nm)")
        hold on
        plot(smoothloadinghabovezero,smoothloadingPabovezero,"red")
        hold on



    %finding pop-ins
   tolerancepop=2; 
   popingindex = find( abs(diff(loadinghabovezero)) > tolerancepop );
   no_of_popinindex=numel(popingindex);

for popin=1:1:no_of_popinindex
popin_index=popingindex(popin);
popinP=loadingPabovezero(popin_index);
popinh=loadinghabovezero(popin_index);
values_of_popin(popin,1)= popin_index;
values_of_popin(popin,2)= popinP;
values_of_popin(popin,3)= popinh;

figure(fig1)
plot(popinh,popinP,"red o")
hold on
%         
end

values_of_popin_diff.(indentnostring)=values_of_popin;

try
valuesofpopinP=(values_of_popin_diff.(indentnostring)(:,2))';
noofvaluesofpopinP=numel(valuesofpopinP);
valuesofpopinPsaving(j,1:1:noofvaluesofpopinP)=valuesofpopinP;
valuesofpopinPsaving(valuesofpopinPsaving == 0) = NaN;
catch
valuesofpopinPsaving(j,1:1:noofvaluesofpopinP)= NaN;
end

if isnan(valuesofpopinPsaving(j,1)) == true
    continue
end

if noofvaluesofpopinP == 1
    valuesofpopinPsavingsingle(j,1)=valuesofpopinPsaving(j,1);
    continue

end

valuesofpopinPdiff=abs(diff(valuesofpopinPsaving(j,:)));
noofvaluesofpopinPdiff=numel(valuesofpopinPdiff);
valuesofpopinPsavingdiff(j,1:1:noofvaluesofpopinPdiff)=valuesofpopinPdiff;

for differencevalues=1:1:noofvaluesofpopinPdiff
    if valuesofpopinPsavingdiff(j,differencevalues) < 10
        valuesofpopinPsaving(j,(differencevalues+1))=NaN;
    end    
end
end
close(progress_bar) % Closes progress bar

valuesofpopinPsavingvector = valuesofpopinPsaving(:);
frequencyofpopins=nnz(~isnan(valuesofpopinPsavingvector));
figure(fig2)
histogram(valuesofpopinPsavingvector,150);
xlabel 'Pop-in Load (uN)'
ylabel 'Frequency'
title 'Large Pop-in Histogram x65 NG 11000um'


cutofflow=0;
cutoffhigh=300;
valuesofpopinPsavingvectorlimitedindex = find(cutofflow < valuesofpopinPsavingvector & valuesofpopinPsavingvector< cutoffhigh); %unhard code this
valuesofpopinPsavingvectorlimited=valuesofpopinPsavingvector(valuesofpopinPsavingvectorlimitedindex);
frequencyofpopinslimited=nnz(~isnan(valuesofpopinPsavingvectorlimited));


figure(fig3)
histogram(valuesofpopinPsavingvectorlimited,20);
xlabel 'Pop-in Load (uN)'
ylabel 'Frequency'
title 'Narrow Pop-in Histogram x65 NG 11000um'
popinlimmean= mean(valuesofpopinPsavingvectorlimited);
popinlimstd = std(valuesofpopinPsavingvectorlimited);
popinlimmedian= median(valuesofpopinPsavingvectorlimited);
popinlimstderror=(popinlimstd)/(sqrt(frequencyofpopinslimited));
hold on
xline(popinlimmean,"red");
xline(popinlimmedian, "blue")
hold off


disp(strcat("Total frequency of Pop-ins is ", string(frequencyofpopins)));
disp(strcat("Frequency of Pop-ins above ", string(cutofflow)," uN and below ", string(cutoffhigh), " uN is " , string(frequencyofpopinslimited)));
disp(strcat("The following data is calculated from the pop-ins below the limited range see line above."))
disp(strcat("Mean of Pop-ins ", string(popinlimmean)," +/- ", string(popinlimstderror), " uN"));
disp(strcat("Median of Pop-ins ", string(popinlimmedian), " uN"));
disp(strcat("Standard Deviation of Pop-ins ", string(popinlimstd), " uN"));
