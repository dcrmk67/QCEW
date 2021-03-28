
# Data script
# Created by: Davin Cermak
# Created on: 28MAR2021


##############################################################
# Load libraries and set options
##############################################################
if (!require('tidyverse')) install.packages('tidyverse')
if (!require('lubridate')) install.packages('lubridate')


##############################################################
# Load data if it is not already available in global environment
##############################################################

if (!exists('cntydata')) load('./data/cntydata.rda') else 'Data already in global environment.'

##############################################################
# Import descriptors for area_fips and industry_code
##############################################################

areas <- read_csv('https://www.bls.gov/cew/classifications/areas/area-titles-csv.csv', col_names=T) %>%
   mutate(area_fips = ifelse(str_length(area_fips)==4,paste0('0',area_fips), area_fips))

industries <- read_csv('https://www.bls.gov/cew/classifications/industry/industry-titles-csv.csv', col_names=T)

data <- cntydata %>%
   left_join(areas, by='area_fips') %>%
   left_join(industries, by='industry_code')

rm(cntydata,areas,industries)

##############################################################
# Data frame summaries
##############################################################

str(data)