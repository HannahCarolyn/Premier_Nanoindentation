function[heatmapfigs]=heatmaps(struct, Output_Type, output_file_directory) %not sure about what to put in the_figure
% 
 %Output_Type='Youngs_Modulus'; % for testing
  X_Coordinate='X_Coordinate';
  Y_Coordinate='Y_Coordinate';

heatmap_variable=[struct.(Output_Type)].'; %These are transposed as the code was outputting these in rows and I'm not sure why.
X=[struct.(X_Coordinate)].'; 
Y=[struct.(Y_Coordinate)].';

spacing=X(2,1)-X(1,1);
column_number=1+(max(X)/spacing); %this calculates the number of indents in x 
row_number=1+(max(Y)/spacing); %this calculates the number of indents in y
indent_number=column_number*row_number; %more of a sense check for me
  
X_append=1+(X./spacing);
Y_append=1+(Y./spacing);
variable_by_coord(:,1)=X_append;
variable_by_coord(:,2)=Y_append;
variable_by_coord(:,3)=heatmap_variable;

x_coord=[min(X):spacing:max(X)]; %gives the X values needed for contourf
y_coord=[min(Y):spacing:max(Y)].'; %gives the Y values needed for contourf
 
heatmap_by_coord=zeros(row_number, column_number);
grid_x=zeros(length(X),1);
grid_y=zeros(length(Y),1);

for k=1:length(variable_by_coord) %this for loop uses order (from above) to take the variable and put it into co-ordinate space
    grid_x(:,1)=variable_by_coord(k,1);
    grid_y(:,1)=variable_by_coord(k,2);
    heatmap_by_coord(grid_y, grid_x)=variable_by_coord(k,3);
end
% % 
% 
% %% 
% 
for letter=1:length(Output_Type) %for formatting purposes
     if Output_Type(letter)== '_'
         Output_Type(letter)= ' ';
     end
 
 end
 
 colour_count=45; %this can be changed to alter the number of levels in the colour map - CMM used 45
 heat_map=contourf(x_coord, y_coord ,heatmap_by_coord, colour_count,'LineColor','None'); 
 %specifies the x and y coordinates for the values in the variable
 %(so each row/column is assigned a certain micron spacing, rather than just
 %1 unit)
 
 c=colorbar;
 c.Label.String = strcat(Output_Type, ' units'); % units (GPa?)???
 xlabel('X in microns')
 ylabel('Y in microns')
 set(gca,'DataAspectRatio',[1 1 1])
 title(strcat(Output_Type, ' heat map'), 'FontSize', 14) 
 
 
 file_name=strcat(output_file_directory, Output_Type, '_heatmap.fig'); %save it
 savefig(file_name)
 % 
 heatmapfigs=openfig(file_name); %the function should open it
 
 for letter=1:length(Output_Type) %rewrite so no spaces for future code/functions
     if Output_Type(letter)== ' '
         Output_Type(letter)= '_';
     end
 end
 
 end 