function[heatmapfigs]=heatmaps2Dpopins(struct,output_file_directory,numberofexpectedpopin); %not sure about what to put in the_figure
clf

 %Output_Type='Youngs_Modulus'; % for testing
  X_Coordinate='X_Coordinate';
  Y_Coordinate='Y_Coordinate';

%These are transposed as the code was outputting these in rows and I'm not sure why.
X=[struct.(X_Coordinate)].'; 
Y=[struct.(Y_Coordinate)].';


% for letter=1:length(Output_Type) %for formatting purposes
%      if Output_Type(letter)== '_'
%          Output_Type(letter)= ' ';
%      end
%  
%  end


spacing=X(2,1)-X(1,1);
column_number=1+(max(X)/spacing); %this calculates the number of indents in x 
row_number=1+(max(Y)/spacing); %this calculates the number of indents in y
indent_number=column_number*row_number; %more of a sense check for me

Popin=[struct.PopinData].';
Popinshaping=reshape(Popin,[numberofexpectedpopin indent_number]); 
Popinfinal=Popinshaping';


  
X_append=1+(X./spacing);
Y_append=1+(Y./spacing);
variable_by_coord(:,1)=X_append;
variable_by_coord(:,2)=Y_append;
variable_by_coord(:,3)=Popinfinal(:,1);



x_coord=[min(X):spacing:max(X)]; %gives the X values needed for contourf
y_coord=[min(Y):spacing:max(Y)].'; %gives the Y values needed for contourf
 
heatmap_by_coord=zeros(row_number, column_number);
grid_x=zeros(length(X),1);
grid_y=zeros(length(Y),1);


for k=1:length(variable_by_coord(:,1)) %this for loop uses order (from above) to take the variable and put it into co-ordinate space
    grid_x(:,1)=variable_by_coord(k,1);
    grid_y(:,1)=variable_by_coord(k,2);
    heatmap_by_coord_2D(grid_y,grid_x)=variable_by_coord(k,3);
    heatmap_by_coord(grid_y, grid_x,1)=variable_by_coord(k,3);

end
% % 
% 
% %% 
% 

colour_count=100; %this can be changed to alter the number of levels in the colour map - CMM used 45
contourf(x_coord, y_coord ,heatmap_by_coord_2D, colour_count,'LineColor','None'); 
hold on
 %specifies the x and y coordinates for the values in the variable
 %(so each row/column is assigned a certain micron spacing, rather than just

 c=colorbar;
 c.Label.String = strcat('First Pop-In load', ' uN'); % units (GPa?)???
 clim([0 500])
 xlabel('X in microns')
 ylabel('Y in microns')
 % set(gca,'DataAspectRatio',[1 1 1])
 title(strcat('First Pop-In load', ' heat map'), 'FontSize', 14) 
 
 file_name_fig=strcat(output_file_directory,'\','popin_2d_heatmap.fig'); %save it
file_name_png=strcat(output_file_directory,'\','popin_2d_heatmap.png');

print(gcf,file_name_png,'-dpng','-r600');
savefig(gcf,file_name_fig);
%  savefig(file_name)
%  % 
heatmapfigs=openfig(file_name_fig); %the function should open it

%  
%  for letter=1:length(Output_Type) %rewrite so no spaces for future code/functions
%      if Output_Type(letter)== ' '
%          Output_Type(letter)= '_';
%      end
%  end
 
 end 
