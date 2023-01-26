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

         %plot the raw data
     figure(fig1);
        plot(loadinghabovezero,loadingPabovezero,"black x")
        ylabel("Load (uN)")
        xlabel("displacement (nm)")
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
valuesofpopinPsaving(j,[1:1:noofvaluesofpopinP])=valuesofpopinP;
valuesofpopinPsaving(valuesofpopinPsaving == 0) = NaN;
catch
valuesofpopinPsaving(j,[1:1:noofvaluesofpopinP])= NaN;
end

if valuesofpopinPsaving(j,1) == NaN;
    continue
end

if noofvaluesofpopinP == 1
    continue
end

valuesofpopinPdiff=abs(diff(valuesofpopinPsaving(j,:)));
noofvaluesofpopinPdiff=numel(valuesofpopinPdiff);
valuesofpopinPsavingdiff(j,[1:1:noofvaluesofpopinPdiff])=valuesofpopinPdiff;

% for differencevalues=1:1:noofvaluesofpopinPdiff
%     if valuesofpopinPsavingdiff(j,differencevalues) < 5;
%         


end

close(progress_bar) % Closes progress bar



valuesofpopinPsavingvector = valuesofpopinPsaving(:);
figure(fig2)
histogram(valuesofpopinPsavingvector,150);
xlabel 'Pop-in Load (uN)'
ylabel 'Frequency'
title 'Large Pop-in Histogram x65 NG 11000um'
valuesofpopinPsavingvectorlimitedindex = find(valuesofpopinPsavingvector < 300); %unhard code this
valuesofpopinPsavingvectorlimited=valuesofpopinPsavingvector(valuesofpopinPsavingvectorlimitedindex);
figure(fig3)
histogram(valuesofpopinPsavingvectorlimited,20);
xlabel 'Pop-in Load (uN)'
ylabel 'Frequency'
title 'Narrow Pop-in Histogram x65 NG 11000um'
popinlimmean= mean(valuesofpopinPsavingvectorlimited);
popinlimstd = std(valuesofpopinPsavingvectorlimited);
popinlimmedian= median(valuesofpopinPsavingvectorlimited);
hold on
xline(popinlimmean,"red");
xline(popinlimmedian, "blue")
hold off
