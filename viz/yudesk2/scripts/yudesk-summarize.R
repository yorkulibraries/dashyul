#!/usr/bin/env Rscript

library(dplyr)
library(readr)
library(lubridate)
library(yulr)

libstats_data_file <- paste0(Sys.getenv("DASHYUL_HOME"), "/data/libstats/libstats.csv")
yudesk_summary_file <- paste0(Sys.getenv("DASHYUL_HOME"), "/viz/yudesk2/data/yudesk-summary.csv")

l <- read_csv(libstats_data_file) %>% mutate(date = as.Date(timestamp, format="%m/%d/%Y %r"), month_name = month(date, label = TRUE))
l$academic_year <- academic_year(l$date)
## l$library.name <- as.factor(l$library.name)

## Filter out this month's data (so there's nothing incomplete that looks strange), then summarize.
yudesk_summary <- l %>% filter(date < floor_date(Sys.Date(), "month")) %>% group_by(question.type, question.format, time.spent, library.name, location.name, month_name, academic_year) %>% summarise(count = n())

write_csv(yudesk_summary, yudesk_summary_file)
