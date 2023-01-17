clear
close all
clc

%load the text files for each of the types of fit that is saved at the end
%of each run of the code. Also open the premier data.
%Note if you change the fit by changing the base codes it will over write
%the txt file and by running this code again can see the difference it has
%made.
convergedfit= readtable('linearconverged.txt');
powerlawfit= readtable('powerlawfit.txt');
premierfit=readtable('301122allunloadtry7.txt');
fourierfit=readtable('fourierfit.txt');
linearleastsqyareofpowerlaw=readtable('powerlawfitlim.txt');

%open the indent number and the H and Er for each data set
indent_no=table2array(convergedfit(:,1));
convergedH=table2array(convergedfit(:,2));
converegdEr=table2array(convergedfit(:,3));
powerlawH=table2array(powerlawfit(:,2));
powerlawEr=table2array(powerlawfit(:,3));
fourierH=table2array(fourierfit(:,2));
fourierEr=table2array(fourierfit(:,3));
linearleastsquareH=table2array(linearleastsqyareofpowerlaw(:,2));
linearleastsquareEr=table2array(linearleastsqyareofpowerlaw(:,3));
premierH=table2array(premierfit(:,9));
premierEr=table2array(premierfit(:,8));

%plot the hardness for each of the data sets
figure(1)
plot(indent_no,convergedH,"red")
hold on
plot(indent_no,powerlawH,"blue");
hold on
plot(indent_no,premierH,"black");
hold on
plot(indent_no,fourierH,"green");
hold on
plot(indent_no,linearleastsquareH,"cyan");
hold on
legend 'Linearfit Converged' 'Powerlawfit Maxpoint' 'Premier Analysis' 'Fourier fit' 'Powerlawlim'
xlabel 'Indent number'
ylabel 'Hardness(GPa)'
title 'Hardness data extracted using different fits'

%plot the reduced modulus for the data sets
figure(2)
plot(indent_no,converegdEr,"red");
hold on
plot(indent_no,powerlawEr,"blue");
hold on
plot(indent_no,premierEr,"black");
hold on
plot(indent_no,fourierEr,"green");
hold on
plot(indent_no,linearleastsquareEr,"cyan");
hold on
hold off
legend 'Linearfit Converged' 'Powerlawfit Maxpoint' 'Premier Analysis' 'Fourier fit' 'Powerlawlim'
xlabel 'Indent number'
ylabel 'Reduced Youngs Modulus (GPa)'
title 'Reduced modulus data extracted using different fits'