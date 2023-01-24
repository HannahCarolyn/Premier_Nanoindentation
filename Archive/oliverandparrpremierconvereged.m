clear
close all
clc

for k=0:9 %This for loop opens the first 10 files (note first indent is called indent 0)
    filenames= sprintf('301122X65NG_0000%d.txt',k); %writes filename as string
    indentnostring= sprintf('indent_%04d',k); %wrtie field name
    indent_no= readtable(filenames, 'VariableNamingRule','preserve'); %open file as table
    indent_k=table2array(indent_no); %convert table to array
    load_displacement_data.(indentnostring)=indent_k; %write into a structure
end


%The following for loop is the same as before but accoutns for the 2
%digits by having 1 less 0 in the file name.
for k=10:35
    filenames= sprintf('301122X65NG_000%d.txt',k);
    indent_no= readtable(filenames, 'VariableNamingRule','preserve');
    indent_k=table2array(indent_no);
    indentnostring= sprintf('indent_%04d',k);
    load_displacement_data.(indentnostring)=indent_k;
end
%array of the filenames
fnms = fieldnames(load_displacement_data);
% opens the arrays for which data goes in
values_of_H_and_E= [];
valuesofS=[];
valuesofHandEfordiffS=[];

%defining variables
epsilon=0.75; %indenter geometry function, not 100% sure which one to use
%This opens the ara file (you have to convert it to a text file to get it
%work)
area_function_path= "D:\Hannah\Test Output\22-11-22Tip-Cal-Test.txt";
area_function=readlines(area_function_path); %takes each line of the text file and turns it into an array
%The constants for the tip area function extracted
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
samplepossionratio=0.3;
%no of indents from counting the number of fields
noofindents=numel(fnms);

%Lood_displacement_data.indent_1.load % extra line delete later

for i=0:noofindents-1 %for loop for each indent
    j=i+1; % correcting zero problem when putting data into the arrays
    indentsnostring= sprintf('indent_%04d',i); % name of field
    h=load_displacement_data.(indentsnostring)(:,1);%extracting the displacement data (nm)
    P=(load_displacement_data.(indentnostring)(:,2)); %extracting the load data (uN)

%extra delete these later
% figure(1);
% plot(h,P,"black")
% ylabel("Load (mN)")
% xlabel("displacment (nm)")
% hold on


%finding the unloading section of each indent
tolerance=1*10^-2; 
index = find( abs(gradient(P)) < tolerance ); %if the gradient is less then the tolerance then write into index of that point into an array
Pmaxindex=max(index); %Find the maximum of this index array list and this will be the Pmax index
noofdatappoint=numel(P); %Find the total amount of data points



unloadingP=P(Pmaxindex:noofdatappoint); %unloading section of load data
unloadingh=h(Pmaxindex:noofdatappoint); %unloading section of displacement data
Pintercept = find(unloadingP < 0); % The point where the load is less than zero.
findinghf=unloadingh(Pintercept); % Find the point displacments for each of the points in the P intercept array
hf=max(findinghf); % find the max value of this array this gives a fitting value called hf
unloadinghminushf=unloadingh-hf; % This is the value of the unloading displacement take away hf

for Pminindex=Pmaxindex:noofdatappoint %This is a for loop that tries out everything length of linear slope
    r=(Pminindex-Pmaxindex)+1; %This is the length of the line note that Pminindex will be higher value.(The plus one is to correct for the first line length being zero)
% %defining the region for slope for S finds the Pmax/hmax data point and
% Pmin/hmin data point
datapointPmax = Pmaxindex; 
Pmax = P(datapointPmax);
datapointPmin = Pminindex;
Pmin = P(datapointPmin);
FindPmax = find(P == Pmax);
hmax=h(FindPmax);
FindPmin = find(P == Pmin);
hmin =h(FindPmin);
%This section has been moved
% %Plotting the points that were defined
% plot(hmin,Pmin,"x");
% hold on
% plot(hmax,Pmax,"x");
% hold on

 %finding the gradient
 S=(Pmax-Pmin)/(hmax-hmin);

%This section has been moved
% %plotting the gradient line
% c=Pmax-(S*hmax);
% lineplot=(S*h)+c;
% plot(h,lineplot,"red :",LineWidth=1.2);
% Pmaxrange= 12;
% ylim([0 Pmaxrange])
% hold on

%This puts the values of the gradidnet/stiffness into an array
valuesofS(Pminindex,2)= S;
valuesofS(Pminindex,1)=Pminindex;

%Oliver and Parr maths
hc = hmax-(epsilon*(Pmax/S)); %standard equation
Ac = (C0*(hc^2))+(C1*hc)+(C2*(hc^(1/2)))+(C3*(hc^(1/4)))+(C4*(hc^(1/8)))+(C5*(hc^(1/16))); %tip area function
H = (Pmax/Ac)*10^3; % Hardness in GPa
Er= (sqrt(pi)/2)*(S/(sqrt(Ac)))*10^3; %Reduced modulus (GPa)
SampleEwithvin = 1/((1/Er) - (1-(tippossionratio^2))/tipyoungmodulus);
E = (SampleEwithvin*(1-(samplepossionratio^2))); %Young's modulus of sample
valuesofHandEfordiffS(r,1)=Pminindex-Pmaxindex; %put length of the slope in array
valuesofHandEfordiffS(r,2)=S; %put stiffness into the array for different stiffness
valuesofHandEfordiffS(r,3)=H; %put hardness into the array for different stiffness
valuesofHandEfordiffS(r,4)=Er; %put the reduced modulus into the array for different stiffness
valuesofHandEfordiffS(r,5)=E; %puts the young modulus into the array for different stiffness

end

%This section finds the point at which the stiffness converges
tolerance=0.1;
indexS = find( abs(gradient(valuesofHandEfordiffS(:,2))) < tolerance ); % Find the index when the stiffness change is below the tolerance
convergedSindex=min(indexS); %find the index that is the minimum of the array the minimum slope length when the data is converged
convergedS=valuesofHandEfordiffS(convergedSindex,2); %extract stiffness at converged Stiffness
convergedH=valuesofHandEfordiffS(convergedSindex,3); %extract Hardness at converged stiffness
convergedEr=valuesofHandEfordiffS(convergedSindex,4); % extract reduced modulus at converged stiffness
convergedE=valuesofHandEfordiffS(convergedSindex,5); %extract young modlus at convered stiffness

%plotting the raw data
figure(1);
plot(h,P,"black")
ylabel("Load (uN)")
xlabel("displacment (nm)")
hold on
%defining the region for slope for S
datapointPmax = Pmaxindex;
Pmax = P(datapointPmax);
datapointPmin = convergedSindex-1+Pmaxindex; %minus 1 in order to correct for the plus one for the r indexing
Pmin = P(datapointPmin);
FindPmax = find(P == Pmax);
hmax=h(FindPmax);
FindPmin = find(P == Pmin);
hmin =h(FindPmin);
%Plotting the points that were defined
plot(hmin,Pmin,"x");
hold on
plot(hmax,Pmax,"x");
hold on
%finding the gradient
S=(Pmax-Pmin)/(hmax-hmin);
%plotting the gradient line
c=Pmax-(convergedS*hmax);
lineplot=(convergedS*h)+c;
plot(h,lineplot,"red :",LineWidth=1.2);
Pmaxrange= 12000;
ylim([0 Pmaxrange])
hold on

%plot the stiffness against the length of the slope
figure(2);
plot(valuesofHandEfordiffS(:,1),valuesofHandEfordiffS(:,2),"black");
xlabel('Length of slope (datapoints)');
ylabel('Stiffness(mN/nm)');
title("Converging Stiffness");
%xlim([30 600]); %extra line
hold on
%plot the point at which the stiffness is choosen to have converged
plot(valuesofHandEfordiffS(convergedSindex,1),valuesofHandEfordiffS(convergedSindex,2),"red x",MarkerSize=5);
%plot the hardness for different slope lengths
figure(3);
plot(valuesofHandEfordiffS(:,1),valuesofHandEfordiffS(:,3));
xlabel('Length of slope (datapoints)');
ylabel('Hardness(GPa)');
title("Converging Hardness");
hold on
%plot for different length of slope the reduced young's modulus
figure(4);
plot(valuesofHandEfordiffS(:,1),valuesofHandEfordiffS(:,4));
xlabel('Length of slope (datapoints)');
ylabel('Reduced Youngs modulus (GPa)');
title("Converging Reduced Youngs modulus");
hold on
%moved else where
% header = {'Lengthofgradientregion(datapoints)','Stiffness(mN/nm)','Hardness (GPa)','Reduced Young Modulus (GPa)'};
% valuesofHandEfordiffSoutput = [header; num2cell(valuesofHandEfordiffS)];
% writecell (valuesofHandEfordiffSoutput,'filename3') %change the file name

%putting values into array
values_of_H_and_E(j,2) = convergedH;
values_of_H_and_E(j,1) = i; %number of the indent
values_of_H_and_E(j,3)= convergedEr;
values_of_H_and_E(j,4)=convergedE;
header = {'No of indents','Hardness (GPa)','Reduced Young Modulus (GPa)' 'Young Modulus (GPa)'}; %headers for the array
valuesofHandEoutput = [header; num2cell(values_of_H_and_E)]; %make an array for outputting data

writecell (valuesofHandEoutput,'linearconverged') %output the array as a textfile and change the name here as wanted.
end


