#!/usr/bin/env Rscript

library(tidyverse)
library(lubridate)
library(yulr)

libstats_data_file  <- paste0(Sys.getenv("DASHYUL_DATA"), "/libstats/libstats.csv")
yudesk_summary_file <- paste0(Sys.getenv("DASHYUL_DATA"), "/viz/yudesk/yudesk-summary.csv")

l <- read_csv(libstats_data_file) %>% mutate(date = as.Date(timestamp, format="%m/%d/%Y %r"), month_name = month(date, label = TRUE))
l$ayear <- academic_year(l$date)

## Filter out this month's data (so there's nothing incomplete that looks strange), then summarize.
yudesk_summary <- l %>%
    filter(date < floor_date(Sys.Date(), "month")) %>%
    group_by(question.type, question.format, time.spent, library.name, location.name, month_name, ayear) %>%
    summarise(count = n())

write_csv(yudesk_summary, yudesk_summary_file)
