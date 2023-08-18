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
library(arrow)

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

rides <-dbGetQuery(con,"SELECT * FROM rides WHERE IsOutlier = 0")
rides$start_date <- as.Date(rides$start_date)
rides$end_date <- as.Date(rides$end_date)
summary(rides)

ggplot(rides) + geom_boxplot(aes(x=trip_duration))
ggplot(rides) + geom_histogram(aes(x=trip_duration)) +
  scale_x_log10()

ggplot(rides) + geom_boxplot(aes(x=trip_distance))
ggplot(rides) + geom_histogram(aes(x=trip_distance)) +
    scale_x_log10()

rides |> filter(IsOutlier==0) |> 
  count(member_casual,day_of_week)|> 
  ggplot() + geom_col(aes(x=day_of_week,y=n)) + facet_wrap(~member_casual)

rides |> filter(IsOutlier==0) |> group_by(member_casual,start_date) |>
  summarise() |> ggplot() + g|> count(member_casual,start_date) |> ggplot() + 
  geom_line(aes(x=start_date,y=n)) + facet_wrap(~member_casual)

## Ride to write_parquet
library(arrow)
# create a sample dataframe
sixmonths <- rides %>% filter(end_date >='2021-10-01')
# write the dataframe to a parquet file
write_parquet(rides, "rideclean.parquet")
write_parquet(sixmonths, "sixmonths.parquet")
