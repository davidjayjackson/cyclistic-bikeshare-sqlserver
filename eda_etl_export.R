## Export Analytics Table

rm(list = ls())
### SQL Server Code

library(DBI)
library(odbc)
library(ggplot2)
library(scales)
library(tidyverse)
library(janitor)
library(writexl)
library(arrow)

##


## https://db.rstudio.com/databases/microsoft-sql-server/
con <- DBI::dbConnect(odbc::odbc(), 
                      Driver = "SQL Server", 
                      Server = "localhost\\SQLEXPRESS", 
                      Database = "cyclistic", 
                      Trusted_Connection = "True")

## CREATE DATAFRAME FOR ANALYTICS TABLE

analytics <-dbGetQuery(con,"SELECT * FROM analytics WHERE IsOutlier = 0")
analytics$start_date <- as.Date(analytics$start_date)
analytics$end_date <- as.Date(analytics$end_date)

## Data Exports

write_parquet(analytics, "analytics.parquet")
write_csv(analytics,'analytics.csv')
# write_xlsx(analytics,'analytics.xlsx')
