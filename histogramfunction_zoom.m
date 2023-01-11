function[histogram_figs_zoom]=histogramfunction_zoom(struct, Output_Type) %not sure about what to put in the_figure

histogram_plot=histogram(struct.Output_Type);
hist_mean=mean(struct.Output_Type,'omitnan');
hist_std=std(struct.Output_Type, 'omitnan');

annotation('textbox',...
    [0.1359 0.8175 0.1688 0.09827],... %these are random numbers I got from drawing one on my particle size distributions but might want to change to fit nanoindentation data better
    'String',{['Mean =' num2str(hist_mean)] ['Standard Deviation =' num2str(hist_std)]},...
    'FontSize',12,...
    'FitBoxToText','on'); %adds values of mean and standard deviation to top left of figure
set(gcf,'WindowState','fullscreen') %opens figure full screen so the annotation looks good

hold on
plot_mean= xline(hist_mean, 'Color', 'r', 'LineWidth', 2);
xlabel(Output_Type, 'FontSize', 12)
ylabel('Number of Indents', 'FontSize', 12)
legend(plot_mean, {'Mean'}, 'FontSize', 10)
lower_xlim=hist_mean-2*hist_std;
upper_xlim=hist_mean+2*hist_std;

title(['Histogram of' Output_Type '2 standard deviations away from the mean'], 'FontSize', 14) %not sure if Output_Type is string?

file_name=[Output_Type '_zoom']; %not sure if Output_Type is string?
savefig(histogram_plot, file_name.fig)

histogram_figs_zoom=openfig('file_name.fig');
end 
