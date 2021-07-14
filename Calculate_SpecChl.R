#Script is for calculating CHL values from NTL LTER Protcol 

#====================================================================================================
#Created by David A. Ortiz
#dortiz4@wisc.edu
#Updated 07/14/2021
#====================================================================================================

#=================================　　　　　IMPORTANT!!!!!!!!!!!=====================================
#===================================~~~~PLEASE READ~~~~~~============================================
#Script excpets to only have the csvs output in one folder location,
#needs to have filtered volume and some ID number (that matches the csv output) in its own file
#script has print outs throughout to provide updates and helps pinpoint troubleshooting location


#FIRST TIME THAT THIS SCRIPT IS RAN ON YOUR PC, 
#YOU NEED TO CREATE AN EMPTY CSV FILE WITH THE COLUMN HEADERS: 
# "Chl_ugL", "Phaeo_ugL",LakeName", "Date", "ID"
#IN THE LOCATION THAT YOU WANT THE CONTINOUSLY UPDATED CSV TO BE LOCATED

#LOCATION OF THE INDIVUAL AND CONTINOUS DATA FILE LOCATION NEEDS TO BE UPDATED ON LINES 177, 183, 188
#IMPORTANT TO MAKE SURE TAHT THE CONTINOUS DATA FILE NAME MATCHES ON LINE 164 AND FILE LOCATION

#WARNING: IF YOU RUN THIS SCRIPT MULTIPLE TIMES WITHOUT CHANING THE Chldir (LINE 44)
#DATA WILL BE REGENERATED AND PASTED ON THE END OF THE CONTINOUS DATAFILE

#LINE 149 NEEDS TO BE UPDATED TO REFLECT HOW YOU ARE FORMATTNG 
#VOLUME FILTERED DATA AND THE UNIQUE ID USE TO MATCH THEM TO THE SPECTRUM SCAN DATA
#====================================================================================================

library(tidyverse)

#Edit for your computer directory & file structure---------------------------------------------------

#Where the output from this script will exist
#I reccomend that you create two folders wihtin "Processed" folder, 
#one named "individual_runs" and the other named "combined"
Dir <- "C:/Users/dortiz4/Dropbox/FLAMe_2021/FLAMe_chl/Processed"

#Name of the continous file name
ContFileName <- "FLAMe_Chl2021.csv"

#Where the chl specturm data exist
Chldir <- "C:/Users/dortiz4/Dropbox/FLAMe_2021/FLAMe_chl/2021-07-12"

#Where the volume filtered datae exist
VolumeData <- read.csv("C:/Users/dortiz4/Dropbox/FLAMe_2021/FLAMeFieldNotes/FLAMeFieldMeta.csv")
#----------------------------------------------------------------------------------------------------

#DO NOT EDIT BELOW HERE==============================================================================
#Extracts Date that Chl samples were run on from Chl data directory location
RunDate <- str_sub(Chldir, -10,-1)

#List of the Chl a & b csv files
Chlfiles <- list.files(Chldir)

#REMMEBER a = after acidification, b = before acidification
Chlfiles_a <- Chlfiles[seq(1,length(Chlfiles),2)]
Chlfiles_b <- Chlfiles[seq(2,length(Chlfiles),2)]

#Starts For Loop for Chl and Phaeo values
i = 1
for (i in 1:length(Chlfiles_a)) {
  
  chla <- Chlfiles_a[i]
  chlb <- Chlfiles_b[i]
  
  #These two sections of code download corresponding chl a & b pairs
  #search for where to trim data, extract import ID infomration, and rename abs #'s to ID values
  
  print(paste("Reading in Data for Run #",i,"...", sep = ""))
  
  data_chla <- read.csv(paste(Chldir,chla, sep = "/"))
  skip_number <- which(data_chla$X.1 == "Abs 2")
  ID_start <- which(data_chla$X == "Sample Name")
  data_chla_id <- data_chla[(ID_start+1):(skip_number-2), 1:6]
  colnames(data_chla_id) <- c("Count","Description", "Blank", "ID","LakeName","Date")
  IDnames <- data_chla_id$ID
  LakeName <- data_chla_id$LakeName[-1]
  Date <- data_chla_id$Date[-1]
  data_chla <- read.csv(paste(Chldir,chla, sep = "/"), skip = skip_number)
  colnames(data_chla) <- c("nm", IDnames)
  
  data_chlb <- read.csv(paste(Chldir,chla, sep = "/"))
  skip_number <- which(data_chlb$X.1 == "Abs 2")
  ID_start <- which(data_chlb$X == "Sample Name")
  data_chlb_id <- data_chlb[(ID_start+1):(skip_number-2), 1:6]
  colnames(data_chlb_id) <- c("Count","Description", "Blank", "ID","LakeName","Date")
  data_chlb <- read.csv(paste(Chldir,chlb, sep = "/"), skip = skip_number)
  colnames(data_chlb) <- c("nm", IDnames)
  
  print("...Data formatting complete...")
  
  #Checks the paired csvs if they have the same number of scans
  #If not for-loop ends (I think)
  if (length(data_chla_id$Count) == length(data_chlb_id$Count)){
    print("...Number of CHL a & b scans match...")
    } else {
    warning("...Number of CHL a & b scans do not match, re-check that they are correct paired files...")
    break
    }
  
  
  # These two for loops check for data normalality 
  # Peak absorbanc within 660-670nm
  # One loop checks a, the other checks b
  n=2
  for (n in 2:length(IDnames)){
  if (which.max(data_chla[,n]) >= 121 | which.max(data_chla[,n]) <= 141){
    print(paste("...Sample Chl a",IDnames[n],"Peak absorbance is within 660-670nm, data is within normal range...",sep = " "))}
    else{
 warning(paste("...Sample Chl a", IDnames[n],"Peak absorbance is outside 660-670nm, data is suspect...", sep = " "))
      break}}
  

  n=2
  for (n in 2:length(IDnames)){
    if (which.max(data_chlb[,n]) >= 121 | which.max(data_chlb[,n]) <= 141){
      print(paste("...Sample Chl b",IDnames[n],"Peak absorbance is within 660-670nm, data is within normal range...",sep = " "))}
    else{
      warning(paste("...Sample Chl b", IDnames[n],"Peak absorbance is outside 660-670nm, data is suspect...", sep = " "))
      break}}

  print("...Calculating Chl values...")
  
  #Create empty list to store Chl values
  CHL <- list()
  PHAEO <- list()
  IDnames_trimmed <- IDnames[-1]
  
  #For loop that actually calculates Chl values from a & b file
  
  #FORMULAS used---------------------------------------------------------------------------------------
  #Chl = (Pre665 - Pre750 - 665Post + 750Post) * Conv
      #Conv = (1.56/0.56)*(10/1)*(1000/75)*(1000/vol)
      #vol = filtered volume (mL)
  
  #Phaeo = (1.56 * (Pre665 - Pre750) - 665Post - 750Post)) * Conv
  #----------------------------------------------------------------------------------------------------
  
  q = 1
  for (q in 1:length(IDnames_trimmed)){
    pre665 <- data_chlb[131,q+2]
    post665 <- data_chla[131,q+2]
    
    pre750 <- data_chlb[301,q+2]
    post750 <- data_chla[301,q+2]
    
    #THIS may be edited to make sure that the volume data and ID values match
    vol <- as.numeric(VolumeData$ChlVol[VolumeData$LTER_Num == IDnames_trimmed[q]])
  
    Cov = (1.56/0.56)*(10/1)*(1000/75)*(1000/vol)
    
    Chl = (pre665 - pre750 - post665 + post750) * Cov
    Phaeo =  (1.56*(post665 - post750)- (pre665 - pre750)) * Cov
    
    CHL[[IDnames_trimmed[q]]] <- Chl
    PHAEO[[IDnames_trimmed[q]]] <- Phaeo
    }

  print("...Finished Calculating Chl Values, Making them look nice...")
  
  #Converting from list of data to dataframe
  CHL_dataframe = do.call(rbind,CHL)
  PHAEO_dataframe = do.call(rbind,PHAEO)

  #Attaching Phaeo LakeName, Sample Date, and ID Columns
  CombinedChl <- cbind(CHL_dataframe,PHAEO_dataframe)
  CombinedChl <- cbind(CombinedChl,LakeName)
  CombinedChl <- cbind(CombinedChl,Date)
  Chl_Final <- cbind(CombinedChl,IDnames_trimmed)
  row.names(Chl_Final) <- NULL
  colnames(Chl_Final) <- c("Chl_ugL", "Phaeo_ugL", "LakeName", "Date", "ID")
  
  #Exports data as a batch file
  print(paste("...Exporting Chl Run #",i, sep = ""))
  write.csv(Chl_Final, paste(Dir,"/individual_runs/",RunDate,"_Chl",i,".csv", sep = ""), row.names = F) 
  
  #Exports data to a running csv file
  #First time that this script is ran, you NEED to create an empty csv file with the column headers
  #"Chl_ugL", "Phaeo_ugL", "LakeName", "Date", "ID"
  
  if (file.exists(paste(Dir,"combined", ContFileName, sep = "/")) == FALSE){
    warning("DATA was not added to the continous Chl file, becasue the file does not exist in directiory!!! Please create a continous file with the same name from line 40 with the appropraite column names (see line 18)")
    break
  }else{
    print("Continous Chl file exists, awesome adding data to file")
    write.table(Chl_Final, file=paste(Dir,"combined", ContFileName, sep = "/"),append = T, quote = F, sep = ",", row.names=F, col.names=F )}
}  