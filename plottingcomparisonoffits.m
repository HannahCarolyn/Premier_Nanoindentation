clear
close all
clc

%load the text files for each of the types of fit that is saved at the end
%of each run of the code. Also open the premier data.
%Note if you change the fit by changing the base codes it will over write
%the txt file and by running this code again can see the difference it has
%made.
% convergedfit= readtable('linearconverged.txt');
% powerlawfit= readtable('powerlawfit.txt');
% premierfit=readtable('sample1CMX1601.txt');
% fourierfit=readtable('fourierfit.txt');
powerlawlimfit=readtable('powerlawfitlim.txt');

%open the indent number and the H and Er for each data set
indent_no=table2array(powerlawlimfit(:,1));
% convergedH=table2array(convergedfit(:,2));
% converegdEr=table2array(convergedfit(:,3));
% powerlawH=table2array(powerlawfit(:,2));
% powerlawEr=table2array(powerlawfit(:,3));
% fourierH=table2array(fourierfit(:,2));
% fourierEr=table2array(fourierfit(:,3));
powerlawlimH=table2array(powerlawlimfit(:,2));
powerlawlimEr=table2array(powerlawlimfit(:,3));
powerlawlimE=table2array(powerlawlimfit(:,4));
% premierH=table2array(premierfit(:,9));
% premierEr=table2array(premierfit(:,8));

%plot the hardness for each of the data sets
figure(1)
% plot(indent_no,convergedH,"red")
% hold on
% plot(indent_no,powerlawH,"blue");
% hold on
% plot(indent_no,premierH,"black");
% hold on
% plot(indent_no,fourierH,"green");
hold on
plot(indent_no,powerlawlimH,"cyan x");

hold on
legend 'Linearfit Converged' 'Powerlawfit Maxpoint' 'Premier Analysis' 'Fourier fit' 'Powerlawlim'
xlabel 'Indent number'
ylabel 'Hardness(GPa)'
title 'Hardness data extracted using different fits'

%plot the reduced modulus for the data sets
figure(2)
% plot(indent_no,converegdEr,"red");
% hold on
% plot(indent_no,powerlawEr,"blue");
% hold on
% plot(indent_no,premierEr,"black");
% hold on
% plot(indent_no,fourierEr,"green");
% hold on
plot(indent_no,powerlawlimEr,"cyan x");
hold on
hold off
legend 'Linearfit Converged' 'Powerlawfit Maxpoint' 'Premier Analysis' 'Fourier fit' 'Powerlawlim'
xlabel 'Indent number'
ylabel 'Reduced Youngs Modulus (GPa)'
title 'Reduced modulus data extracted using different fits'



figure(3)
plot(powerlawlimH,powerlawlimEr,"x")

figure(4)
histogram(powerlawlimH,20);

figure(5)
histogram(powerlawlimEr,20);