 function[dodgy_indent_plot]=dodgy_indent_find(struct, dodgy_indents,output_file_directory)
% %I believe we need to change dodgy_indents to bad_indents_list and
% %but don't need NaN info just this list

X_Coordinate='X_Coordinate';
Y_Coordinate='Y_Coordinate';

X=[struct.(X_Coordinate)].'; 
Y=[struct.(Y_Coordinate)].';

X_spacing=X(2,1)-X(1,1);
column_number=1+(max(X)/X_spacing); %this calculates the number of indents in x 
Y_spacing=Y((1+column_number),1)-Y(1,1); %- might need to change as I'm p sure x and y come in columns in the code?
row_number=1+(max(Y)/Y_spacing); %this calculates the number of indents in y

  X_append=zeros(length(X),1); %for for loops below for speed
  Y_append=zeros(length(Y),1);
  order(:,1)=1:1:length(X);
  
  for i=1:length(X) % This for loop goes through each indent and normalises its coordinates (so order gives the position in the array)
      X_append(i,1)=1+(X(i,1)/X_spacing);
      order(:,2)=X_append; %
          for j=1:length(Y)
          Y_append(j,1)=1+(Y(j,1)/Y_spacing);
          order(:,3)=Y_append; 
          end 
  end

 dodgy=dodgy_indents.'; %had to transpose again
 coord_dodgy_x=zeros(length(dodgy),1);
  coord_dodgy_y=zeros(length(dodgy),1);

for i=1:length(dodgy)
    indent_number=dodgy(i,:);
    X_coord=order(indent_number,2);
    Y_coord=order(indent_number,3);
    coord_dodgy_x(i,1)=(X_coord-1)*X_spacing;
    coord_dodgy_y(i,1)=(Y_coord-1)*Y_spacing; 
end 

plot(coord_dodgy_x, coord_dodgy_y,'x', 'linestyle', 'none', 'MarkerSize',15)

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