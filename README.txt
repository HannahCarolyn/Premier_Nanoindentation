
                                - Details of file structure -

* Need to add note about check of column headers in these files

Within your base directory, have five folders named: Area_Function, Continuous_Data, Coordinate_Data or Dynamic_Data, Indent_Data,
Load_Function, Premier_Calculated_Data. This all needs rewriting

Inside the Area_Function folder you should have a single file created from the tip calibration
on the Hysitron Triboscan software. Change the file extension of this file from .ara to .txt in
windows file explorer. This file can have any name.

If using mapping data, within the Indent_Data folder you should have the output text files from 
the XPM analysis sub-tab in the Hysitron Triboscan software (file --> export curves to text). 
These files have the depth and load data for each indent. Make sure these are the only files in 
this folder. These files can have any name, but make sure alphabetical order corresponds to the 
indent order.

If using basic automated grid array data, within the Indent_Data folder you should have the output
text files after multiple curve fitting in the quasi analysis sub-tab in the Hysitron Triboscan 
software (file --> export multiple text files). These files have the raw depth and load data for 
each indent. Make sure these are the only files in this folder. These files can have any name, but 
make sure alphabetical order corresponds to the indent order.

If using mapping data, the Coordinate_Data file should contain the .txt files that are auto-
generated (with the same name as the raw bundle data files) when loading the multiple data files
in the XPM analysis sub-tab in the Hysitron Triboscan software. You may rename these if you wish, 
but ensure the alphabetical order of the files remains the same. These files contain the express 
mapping coordinates.

If using basic automated grid array data, the Dynamic_Data file should contain the .txt file
that is auto-saved (user is asked where it is saved) when loading multiple curve analysis in the
quasi analysis sub-tab in the Hysitron Triboscan software. These files can have any name, but 
make sure alphabetical order corresponds to the indent order.

Within the Load_Function folder you should copy across the load function file that was created
when setting up the XPM indents. Change the file extension from .ldf to .txt. Again the file
can have any name. Though this is not currently used in the input deck, it may be used at a
later date.

If using Premier_Nanoindenter_Main_Random, use the same data file structure as above.