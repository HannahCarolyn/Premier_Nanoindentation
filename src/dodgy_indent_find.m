function[dodgy_indent_plot]=dodgy_indent_find(struct, amber_indents_list,red_indents_list, output_file_directory) %this function plots the location of the dodgy indents
clf

X_Coordinate='X_Coordinate';
Y_Coordinate='Y_Coordinate';

X=[struct.(X_Coordinate)].'; %x coordinates of indents
Y=[struct.(Y_Coordinate)].'; %y coordinates of indents

spacing=X(2,1)-X(1,1); %spacing must be the same in x and y

X_append=1+(X./spacing); %assigns x coordinates to array position (row)
Y_append=1+(Y./spacing); %assigns y coordinates to array position (column)
grid_coord(:,1)=1:1:length(X); %to give indent number, row and column number
grid_coord(:,2)=X_append;
grid_coord(:,3)=Y_append;

%first red indents
red=(red_indents_list.')+1; %had to transpose to work %RT edit
 coord_red_x=zeros(length(red),1);
 coord_red_y=zeros(length(red),1);

 for i=1:length(red) %this for loop takes the indent number of the dodgy indents to find the corresponding array position. This is translated back to a coordinate.
    indent_number=red(i,:);
    X_coord=grid_coord(indent_number,2);
    Y_coord=grid_coord(indent_number,3);
    coord_red_x(i,1)=(X_coord-1)*spacing;
    coord_red_y(i,1)=(Y_coord-1)*spacing; 
end 

 %then amber
 amber=(amber_indents_list.')+1; %had to transpose to work %RT
 coord_amber_x=zeros(length(amber),1);
 coord_amber_y=zeros(length(amber),1);

for i=1:length(amber) %this for loop takes the indent number of the dodgy indents to find the corresponding array position. This is translated back to a coordinate.
    indent_number=amber(i,:);
    X_coord=grid_coord(indent_number,2);
    Y_coord=grid_coord(indent_number,3);
    coord_amber_x(i,1)=(X_coord-1)*spacing;
    coord_amber_y(i,1)=(Y_coord-1)*spacing; 
end 

plot(coord_red_x, coord_red_y,'v', 'linestyle', 'none', 'MarkerSize',10, 'LineWidth', 2, 'Color', 'red', 'MarkerFaceColor', 'red');
hold on
plot(coord_amber_x, coord_amber_y,'v', 'linestyle', 'none', 'MarkerSize',10, 'LineWidth', 2, 'Color', '#ffcc00', 'MarkerFaceColor', '#ffcc00');


xlabel('X in microns', 'FontSize', 12)
ylabel('Y in microns', 'FontSize', 12)
title('Dodgy Indents Mapped in 2D space', 'FontSize', 14)
legend('Red Indents', 'Amber Indents', 'Location', 'northeastoutside')

axis equal
xlim([0 max(X)])
ylim([0 max(Y)])

 file_name_fig=strcat(output_file_directory,'\','dodgy_indents.fig'); %save it
file_name_png=strcat(output_file_directory,'\','dodgy_indents.png');

print(gcf,file_name_png,'-dpng','-r600');
savefig(gcf,file_name_fig);
    
 dodgy_indent_plot=openfig(file_name_fig);

end
