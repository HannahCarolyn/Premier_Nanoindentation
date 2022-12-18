%code for importing the data for the displacement and load
%https://www.sciencedirect.com/topics/engineering/oliver-pharr-method
%link above for the method for oliver-parr method example
clear
close all
clc

for k=0:9 %This for loop opens the first 10 files (note first indent is called indent 0)
    filenames= sprintf('301122X65NG_0000%d.txt',k);%writes filename as string
    indentnostring= sprintf('indent_%04d',k); %wrtie field name
    indent_no= readtable(filenames, 'VariableNamingRule','preserve');%open file as table
    indent_k=table2array(indent_no);
    load_displacement_data.(indentnostring)=indent_k;%write into a structure
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
%defining variables
epsilon=0.75; %indenter geometry function e.g. 0.75 
%This opens the ara file (you have to convert it to a text file to get it
%work)
area_function_path= "D:\Hannah\Test Output\22-11-22Tip-Cal-Test.txt";
area_function=readlines(area_function_path);%takes each line of the text file and turns it into an array
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

%define figures and array to put data in
fig1 = figure;
fig2 = figure;
values_of_H_and_E=[];

for i=0:noofindents-1 % loop for each of the indents with zero corrections
    j=i+1; % correcting zero problem when putting data into the arrays
    indentsnostring= sprintf('indent_%04d',i); %string of the field name
    h=load_displacement_data.(indentsnostring)(:,1);%extracting displacement data from the array (nm)
    P=(load_displacement_data.(indentnostring)(:,2)); %extracting load data from the array (uN)

%plot the raw data
    figure(fig1);
    plot(h,P,"black")
    ylabel("Load (uN)")
    xlabel("displacment (nm)")
    hold on
% finding the unloading segment by finding when the gradient is below a
% tolerance and then taking the max value of this index

tolerance=1*10^-2; 
index = find( abs(gradient(P)) < tolerance );
Pmaxindex=max(index);
noofdatappoint=numel(P);

unloadingP=P(Pmaxindex:noofdatappoint); %extracting the unloading section of load
unloadingh=h(Pmaxindex:noofdatappoint); % extracting the unloading section of load
Pintercept = find(unloadingP < 0); %find the point where load is below zero
findinghf=unloadingh(Pintercept); %from the index of the points where load is less than zero
hf=max(findinghf); %find the maximum point of this array in order to extract the fitting parameter hf
unloadinghminushf=unloadingh-hf; %this is value needed for the power law fit

%fourier fit

[xData, yData] = prepareCurveData( unloadinghminushf, unloadingP );

% Set up fittype and options.
ft = fittype( 'fourier1' );
excludedPoints = yData < 0.15;
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0 0 0 0.016839672940635];
opts.Exclude = excludedPoints;

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
figure(fig2);
o = plot( fitresult, xData, yData, excludedPoints );
legend( o, 'unloadingP vs. unloadinghminushf', 'Excluded unloadingP vs. unloadinghminushf', 'untitled fit 1', 'Location', 'NorthEast', 'Interpreter', 'none' );
% Label axes
xlabel( 'unloadinghminushf', 'Interpreter', 'none' );
ylabel( 'unloadingP', 'Interpreter', 'none' );
grid on
hold on

%from the derviate of the power law fit and find the the result at the
%maximum pmax which will be the first value in the array
derivativeofpowerlaw=differentiate(fitresult,unloadinghminushf);
S=derivativeofpowerlaw(1);
% 
%find the maximum data point values of Pmax and Hmax
datapointPmax = Pmaxindex;
Pmax = P(datapointPmax);
FindPmax = find(P == Pmax);
hmax=h(FindPmax);
% FindPmin = find(P == Pmin);

 %plotting the gradient line
 c=Pmax-(S*hmax);
lineplot=(S*h)+c;
 figure(fig1)
 plot(h,lineplot,"red :",LineWidth=1.2);
 Pmaxrange= 12000;
 ylim([0 Pmaxrange])
hold on
%Oliver and Parr maths
hc = hmax-(epsilon*(Pmax/S)); %standard equation
Ac = (C0*(hc^2))+(C1*hc)+(C2*(hc^(1/2)))+(C3*(hc^(1/4)))+(C4*(hc^(1/8)))+(C5*(hc^(1/16))); %tip area function
H = (Pmax/Ac)*10^3; %Hardness in (GPa)
Er= (sqrt(pi)/2)*(S/(sqrt(Ac)))*10^3; %Reduced modulus in (GPa)
SampleEwithvin = 1/((1/Er) - (1-(tippossionratio^2))/tipyoungmodulus); 
E = (SampleEwithvin*(1-(samplepossionratio^2))); %Young's modulus in (GPa)
%putting values into array 
values_of_H_and_E(j,2) = H;
values_of_H_and_E(j) = i;
values_of_H_and_E(j,3)= Er;
values_of_H_and_E(j,4)=E;
header = {'No of indents','Hardness (GPa)','Reduced Young Modulus (GPa)' 'Young Modulus (GPa)'}; %headers for the array
valuesofHandEoutput = [header; num2cell(values_of_H_and_E)]; %make an array for outputting data;
writecell (valuesofHandEoutput,'fourierfit') %change the file name
end