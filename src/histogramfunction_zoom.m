function[histogram_figs_zoom]=histogramfunction_zoom(struct, Output_Type, output_file_directory) %not sure about what to put in the_figure
% Output_Type='Youngs_Modulus'; % for testing
clf
hist_variable=[struct.(Output_Type)];

output_type_seperate=strsplit(Output_Type,"_");
output_type_space=strjoin(output_type_seperate," ");

% for letter=1:length(output_type_seperate)
%     if Output_Type(letter)== '_'
%         Output_Type(letter)= ' ';
%     end
% end

nbins=10; %set number of bins in histogram as before MATLAB wasn't doing many!!
histogram_plot=histogram(hist_variable,nbins);
hist_mean=mean(hist_variable, 'omitnan');
hist_std=std(hist_variable, 'omitnan');

annotation('textbox',...
    [0.1359 0.8175 0.1688 0.09827],... %these are random numbers I got from drawing one on my particle size distributions but might want to change to fit nanoindentation data better
    'String',{['Mean = ' num2str(hist_mean)] ['Standard Deviation = ' num2str(hist_std)]},...
    'FontSize',12,...
    'FitBoxToText','on'); %adds values of mean and standard deviation to top left of figure
%set(gcf,'WindowState','fullscreen') %opens figure full screen so the annotation looks good

hold on
plot_mean= xline(hist_mean, 'Color', 'r', 'LineWidth', 2);
xlabel(output_type_space, 'FontSize', 12)
ylabel('Number of Indents', 'FontSize', 12)
legend(plot_mean, {'Mean'}, 'FontSize', 10)
lower_xlim=hist_mean-2*hist_std;
upper_xlim=hist_mean+2*hist_std;
xlim([lower_xlim upper_xlim]);



title(strcat(output_type_space, ' histogram two standard deviations away from the mean'), 'FontSize', 14)

file_name_fig=strcat(output_file_directory,'\', Output_Type, '_histogramzoom.fig'); %save it
file_name_png=strcat(output_file_directory,'\',Output_Type,'_histogramzoom.png');

print(gcf,file_name_png,'-dpng','-r600');
savefig(gcf,file_name_fig);

histogram_figs_zoom=openfig(file_name_fig);

% for letter=1:length(Output_Type) %I feel like we need to rewrite it back at the end of the code
%     if Output_Type(letter)== ' '
%         Output_Type(letter)= '_';
%     end
% end

end 
