#!/usr/bin/env Rscript

library(dplyr)
library(lubridate)
library(readr)
library(yulr)

libstats_data_file  <- paste0(Sys.getenv("DASHYUL_DATA"), "/libstats/libstats.csv")

libstats_daily_dashboard_summary_file <- paste0(Sys.getenv("DASHYUL_DATA"), "/dashboard/dashboard-libstats-daily-summary.csv")

l <- read_csv(libstats_data_file) %>% mutate(date = as.Date(timestamp, format="%m/%d/%Y %r"), month_name = month(date, label = TRUE))
l$academic_year <- academic_year(l$date)
l$library.name <- as.factor(l$library.name)

## Filter out this month's data (so there's nothing incomplete that looks strange), then summarize.
## summary <- l %>% filter(academic_year == 2017) %>% filter(date < floor_date(Sys.Date(), "month")) %>% filter(question.type != "LCO") %>% group_by(library.name, question.type) %>% summarise(count = n())

summary <- l %>% filter(academic_year == 2017) %>% filter(question.type != "LCO") %>% group_by(library.name, question.type) %>% summarise(count = n())

write_csv(summary, libstats_daily_dashboard_summary_file)
