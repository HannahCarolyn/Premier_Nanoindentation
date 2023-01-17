function[heatmapfigs]=heatmaps(struct, Output_Type, output_file_directory) %not sure about what to put in the_figure
% 
% Output_Type='Youngs_Modulus'; % for testing
%  X_Coordinate='X_Coordinate';
%  Y_Coordinate='Y_Coordinate';

heatmap_variable=[struct.(Output_Type)].'; %These are transposed as the code was outputting these in rows and I'm not sure why.
X=[struct.(X_Coordinate)].'; 
Y=[struct.(Y_Coordinate)].';

X_spacing=X(2,1)-X(1,1);
column_number=1+(max(X)/X_spacing); %this calculates the number of indents in x 
Y_spacing=Y((1+column_number),1)-Y(1,1); %- might need to change as I'm p sure x and y come in columns in the code?
row_number=1+(max(Y)/Y_spacing); %this calculates the number of indents in y
indent_number=column_number*row_number; %more of a sense check for me

x_coord=[min(X):X_spacing:max(X)]; %gives the X values needed for contourf
y_coord=[min(Y):Y_spacing:max(Y)]; %gives the Y values needed for contourf

 X_append=zeros(length(X),1); %for for loops below for speed
 Y_append=zeros(length(Y),1);

 
 for i=1:length(X) % This for loop goes through each indent and normalises its coordinates (so order gives the cell position to store the variable in)
     X_append(i,1)=1+(X(i,1)/X_spacing);
     order(:,1)=X_append; %
         for j=1:length(Y)
         Y_append(j,1)=1+(Y(j,1)/Y_spacing);
         order(:,2)=Y_append; 
         end 
 end
% 
 heatmap_by_coord=zeros(row_number, column_number); %pre-allocating for speed
 
 for k=1:length(heatmap_variable) %this for loop uses order (from above) to take the variable and put it into co-ordinate space
     heatmap_grid_x=order(k,1);
     heatmap_grid_y=order(k,2);
     heatmap_by_coord(heatmap_grid_x, heatmap_grid_y)=heatmap_variable(k,1);
 end


%% 

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
