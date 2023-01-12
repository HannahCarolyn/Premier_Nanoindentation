%function[histogramfigs]=histogramfunction(struct, Output_Type) %not sure about what to put in the_figure
% look at zoom 
Output_Type='Youngs_Modulus'; % remove this after test

hist_variable=[struct.(Output_Type)];

for letter=1:length(Output_Type) %rewrite for strings later 
    if Output_Type(letter)== '_'
        Output_Type(letter)= ' ';
    end

end
%% 
nbins=20; %set number of bins in histogram as before MATLAB wasn't doing many!!

histogram_plot=histogram(hist_variable, nbins);
hist_mean=mean(hist_variable, 'omitnan');
hist_std=std(hist_variable, 'omitnan');

annotation('textbox',...
    [0.1359 0.8175 0.1688 0.09827],... %these are random numbers I got from drawing one on my particle size distributions but might want to change to fit nanoindentation data better
    'String',{['Mean = ' num2str(hist_mean)] ['Standard Deviation = ' num2str(hist_std)]},...
    'FontSize',12,...
    'FitBoxToText','on'); %adds values of mean and standard deviation to top left of figure
set(gcf,'WindowState','fullscreen') %opens figure full screen so the annotation looks good

hold on
plot_mean= xline(hist_mean, 'Color', 'r', 'LineWidth', 2);
xlabel(Output_Type, 'FontSize', 12)
ylabel('Number of Indents', 'FontSize', 12)
legend(plot_mean, {'Mean'}, 'FontSize', 10)
title(strcat(Output_Type, ' Histogram'),'FontSize', 14) %not sure if Output_Type is string?

file_name=strcat(Output_Type, '_zoom.fig'); %not sure if Output_Type is string?
savefig(histogram_plot, file_name)

histogramfigs=openfig(file_name);

for letter=1:length(Output_Type) %I feel like we need to rewrite it back at the end of the code
    if Output_Type(letter)== ' '
        Output_Type(letter)= '_';
    end

end
%end 