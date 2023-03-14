function[histogramfigs]=histogramfunction(struct, Output_Type, output_file_directory) %not sure about what to put in the_figure
 clf
%Output_Type='Youngs_Modulus'; % remove this after test

hist_variable=[struct.(Output_Type)];

units_reference=["Hardness", "GPa"; "Modulus", "GPa"; "Reduced Modulus", "GPa"; "Stiffness", "μN/nm"; "Maximum Load", "μN"; "Maximum Displacement", "nm"; "Hardness Divided By Modulus", " "; "Stiffness Squared Divided By Load", "GPa"];


output_type_seperate=strsplit(Output_Type,"_");
output_type_space=strjoin(output_type_seperate," ");

row_for_unit=find(output_type_space==units_reference);
unit=units_reference(row_for_unit,2);

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
%set(gcf,'WindowState','fullscreen') %opens figure full screen so the annotation looks good

hold on
plot_mean= xline(hist_mean, 'Color', 'r', 'LineWidth', 2);
xlabel(strcat(output_type_space, ', ', unit), 'FontSize', 12)
ylabel('Number of Indents', 'FontSize', 12)
legend(plot_mean, {'Mean'}, 'FontSize', 10)
title(strcat(output_type_space, ' Histogram'),'FontSize', 14) 

file_name_fig=strcat(output_file_directory,'\', Output_Type, '_histogram.fig'); %save it
file_name_png=strcat(output_file_directory,'\',Output_Type,'_histogram.png');

print(gcf,file_name_png,'-dpng','-r600');
savefig(gcf,file_name_fig);



histogramfigs=openfig(file_name_fig);

end 
