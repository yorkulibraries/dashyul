#!/usr/bin/env Rscript

library(dplyr)
library(lubridate)
library(readr)
library(yulr)

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

libstats_data_file  <- paste0(Sys.getenv("DASHYUL_DATA"), "/libstats/libstats.csv")

libstats_daily_summary_file <- paste0(Sys.getenv("DASHYUL_DATA"), "/viz/dashboard/libstats-daily-summary.csv")

## Summary stats shown numbers for the current academic year.
## Could get a little funny on 01 September, but so be it.
current_academic_year <- academic_year(Sys.Date())

l <- read_csv(libstats_data_file) %>%
    mutate(date = as.Date(timestamp, format = "%m/%d/%Y %r"),
           month_name = month(date, label = TRUE))
l$academic_year <- academic_year(l$date)
l$library.name <- as.factor(l$library.name)

summary <- l %>%
    filter(academic_year == current_academic_year) %>%
    filter(question.type != "LCO") %>%
    group_by(library.name, question.type) %>%
    summarise(count = n())

write_csv(summary, libstats_daily_summary_file)

write(paste("Finished: ", Sys.time()), stderr())
