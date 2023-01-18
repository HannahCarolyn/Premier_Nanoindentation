function[dodgy_indent_plot]=dodgy_indent_find(struct, dodgy_indents,output_file_directory)
% %I believe we need to change dodgy_indents to bad_indents_list and
% %but don't need NaN info just this list

X_Coordinate='X_Coordinate';
Y_Coordinate='Y_Coordinate';

X=[struct.(X_Coordinate)].'; 
Y=[struct.(Y_Coordinate)].';

spacing=X(2,1)-X(1,1);
column_number=1+(max(X)/spacing); %this calculates the number of indents in x 
row_number=1+(max(Y)/spacing); %this calculates the number of indents in y
indent_number=column_number*row_number; %more of a sense check for me

x_coord=[min(X):spacing:max(X)]; %gives the X values needed for contourf
y_coord=[min(Y):spacing:max(Y)].'; %gives the Y values needed for contourf

X_append=1+(X./spacing); %assigns coordinates to array (row/column) position
Y_append=1+(Y./spacing);
grid_coord(:,1)=1:1:length(X); %to give indent number
grid_coord(:,2)=X_append;
grid_coord(:,3)=Y_append;

 dodgy=dodgy_indents.'; %had to transpose again
 coord_dodgy_x=zeros(length(dodgy),1);
 coord_dodgy_y=zeros(length(dodgy),1);

for i=1:length(dodgy)
    indent_number=dodgy(i,:);
    X_coord=grid_coord(indent_number,2);
    Y_coord=grid_coord(indent_number,3);
    coord_dodgy_x(i,1)=(X_coord-1)*spacing;
    coord_dodgy_y(i,1)=(Y_coord-1)*spacing; 
end 

plot(coord_dodgy_x, coord_dodgy_y,'v', 'linestyle', 'none', 'MarkerSize',10, 'LineWidth', 2, 'Color', 'black', 'MarkerFaceColor', 'black')


xlabel('X in microns', 'FontSize', 12)
ylabel('Y in microns', 'FontSize', 12)
title('Dodgy Indents Mapped in 2D space', 'FontSize', 14)

axis equal
xlim([0 max(X)])
ylim([0 max(Y)])

file_name=strcat(output_file_directory,'dodgy_indents.fig'); %save it
savefig(file_name)
    
 dodgy_indent_plot=openfig(file_name);

 end
