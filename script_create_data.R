

# This script accesses QCEW data for this project
# See https://www.bls.gov/cew/downloadable-data-files.htm for data details
# Created by: Davin Cermak
# Created on: 28MAR2021

#############################################################
# Load required packages
# NOTE: This code will install the tidyverse package to the 
# user's machine if it is not already available.
#############################################################

if (!require('tidyverse')) install.packages('tidyverse')

#############################################################
# Download zip files to local machine
#############################################################
download.file('https://data.bls.gov/cew/data/files/2020/csv/2020_qtrly_singlefile.zip','./data/qcew2020.zip')
download.file('https://data.bls.gov/cew/data/files/2019/csv/2019_qtrly_singlefile.zip','./data/qcew2019.zip')


#############################################################
# Unzip and create data from of QCEW data
#############################################################

# Assigns value to access and save files in the project's 
# data directory

dataDir <- './data'

# Unzip downloaded files 
zipfiles <- list.files(path=dataDir, pattern='.zip', full.names=TRUE) 
for (file in zipfiles) {
   unzip(file, exdir=dataDir)
}

# Map csv files into a single data frame
csvfiles <- list.files(path=dataDir, pattern='.csv', full.names=TRUE)
data <- map_df(csvfiles, read_csv, col_names=TRUE)

# Create a separate data file for county-level QCEW data and some initial
# data cleanup
cntydata <- data %>%
   filter(size_code==0 
          & own_code==5 
          & agglvl_code %in% c(71,75,76) 
          & qtrly_estabs > 0 
          & substr(area_fips,1,2) <= 56) %>%
   mutate(empl = round(((month1_emplvl+month2_emplvl+month3_emplvl) / 3), digits=0),
          empl = na_if(empl,0),
          date = paste0(as.character(year),'-',qtr)) %>%
   rename(estabs = qtrly_estabs) %>%
   select(area_fips, industry_code, agglvl_code, date, estabs, empl)

# Global environment cleanup
rm(dataDir,file,zipfiles,csvfiles,data)

# Save county-level data for additional analyses
saveRDS(cntydata, file='./data/cntydata.rda')