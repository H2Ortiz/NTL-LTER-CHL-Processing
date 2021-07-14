NTL-LTER ChlProcessing

====================================================================================================
Created by David A. Ortiz
dortiz4@wisc.edu
Updated 07/14/2021
====================================================================================================

=================================¡¡¡¡¡¡¡¡¡¡IMPORTANT!!!!!!!!!!!=====================================
===================================~~~~PLEASE READ~~~~~~============================================
Script excpets to only have the csvs output in one folder location,
needs to have filtered volume and some ID number (that matches the csv output) in its own file
script has print outs throughout to provide updates and helps pinpoint troubleshooting location


FIRST TIME THAT THIS SCRIPT IS RAN ON YOUR PC, 
YOU NEED TO CREATE AN EMPTY CSV FILE WITH THE COLUMN HEADERS: 
"Chl_ugL", "Phaeo_ugL",LakeName", "Date", "ID"
IN THE LOCATION THAT YOU WANT THE CONTINOUSLY UPDATED CSV TO BE LOCATED

LOCATION OF THE INDIVUAL AND CONTINOUS DATA FILE LOCATION NEEDS TO BE UPDATED ON LINES 177, 183, 188
IMPORTANT TO MAKE SURE TAHT THE CONTINOUS DATA FILE NAME MATCHES ON LINE 164 AND FILE LOCATION

WARNING: IF YOU RUN THIS SCRIPT MULTIPLE TIMES WITHOUT CHANING THE Chldir (LINE 44)
DATA WILL BE REGENERATED AND PASTED ON THE END OF THE CONTINOUS DATAFILE

LINE 149 NEEDS TO BE UPDATED TO REFLECT HOW YOU ARE FORMATTNG 
VOLUME FILTERED DATA AND THE UNIQUE ID USE TO MATCH THEM TO THE SPECTRUM SCAN DATA