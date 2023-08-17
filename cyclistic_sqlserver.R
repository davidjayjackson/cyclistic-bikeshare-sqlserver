## 2023-08-16

rm(list = ls())
### SQL Server Code

library(DBI)
library(odbc)
library(ggplot2)
library(scales)
library(tidyverse)
library(janitor)
library(writexl)

##


## https://db.rstudio.com/databases/microsoft-sql-server/
con <- DBI::dbConnect(odbc::odbc(), 
                      Driver = "SQL Server", 
                      Server = "localhost\\SQLEXPRESS", 
                      Database = "cyclistic", 
                      Trusted_Connection = "True")
## Part 1 Jan to March.

# Directory with CSV files
dir_path <- "data1"
files <- list.files(path = dir_path, pattern = "*.csv", full.names = TRUE)

# Read CSV files and combine into dataframe
# And drop a few uneeded columns
all_data <- lapply(files, read_csv)
df <- do.call(rbind, all_data)
df <- df %>% select(-c('start_station_id','end_station_id'))

df <- df %>% janitor::clean_names()
df <- df %>% janitor::remove_empty(which = c("rows","cols"))


dbWriteTable(con, "data1",df ,overwrite=TRUE)
dbListFields(con,"data1")

dbGetQuery(con,"select count(*) from data1")


# Part 2 Apr - June


# Directory with CSV files
dir_path <- "data2"
files <- list.files(path = dir_path, pattern = "*.csv", full.names = TRUE)


all_data <- lapply(files, read_csv)
df <- do.call(rbind, all_data)
df <- df %>% select(-c('start_station_id','end_station_id'))

df <- df %>% janitor::clean_names()
df <- df %>% janitor::remove_empty(which = c("rows","cols"))




dbWriteTable(con, "data2",df ,overwrite=TRUE)
dbListFields(con,"data2")

dbGetQuery(con,"select count(*) from data2")
# dbCommit(con)


# Part 3 Aug - Sept.


# Directory with CSV files
dir_path <- "data3"
files <- list.files(path = dir_path, pattern = "*.csv", full.names = TRUE)

# Read CSV files and combine into dataframe
# And drop a few uneeded columns
all_data <- lapply(files, read_csv)
df <- do.call(rbind, all_data)
df <- df %>% select(-c('start_station_id','end_station_id'))

df <- df %>% janitor::clean_names()
df <- df %>% janitor::remove_empty(which = c("rows","cols"))


# USA <- read.csv("../COVID-19-NYTimes-data//us.csv")
# USA$date <- as.Date(USA$date)

dbWriteTable(con, "data3",df ,overwrite=TRUE)
dbListFields(con,"data3")

dbGetQuery(con,"select count(*) from data3")

# Part 4 Oct - Dec.



# Directory with CSV files
dir_path <- "data4"
files <- list.files(path = dir_path, pattern = "*.csv", full.names = TRUE)

# Read CSV files and combine into dataframe
# And drop a few uneeded columns
all_data <- lapply(files, read_csv)
df <- do.call(rbind, all_data)
df <- df %>% select(-c('start_station_id','end_station_id'))

df <- df %>% janitor::clean_names()
df <- df %>% janitor::remove_empty(which = c("rows","cols"))




dbWriteTable(con, "data4",df ,overwrite=TRUE)
dbListFields(con,"data4")

dbGetQuery(con,"select count(*) from data4")

## Read Data back from SQL Sever DB

rides <-dbGetQuery(con,"select start_date,trip_duration,trip_distance from rides")
rides$start_date <- as.Date(rides$start_date)
summary(rides)

ggplot(rides) + geom_boxplot(aes(x=trip_duration))
ggplot(rides) + geom_histogram(aes(x=trip_duration)) +
  scale_x_log10()

ggplot(rides) + geom_boxplot(aes(x=trip_distance))
ggplot(rides) + geom_histogram(aes(x=trip_distance)) +
  scale_x_log10()

