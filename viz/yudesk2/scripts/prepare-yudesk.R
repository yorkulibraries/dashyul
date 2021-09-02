#!/usr/bin/env Rscript

suppressMessages(library(tidyverse))
suppressMessages(library(lubridate))
library(yulr)

libstats_all <- paste0(Sys.getenv("DASHYUL_DATA"), "/libstats/all.rds")
yudesk_summary <- paste0(Sys.getenv("DASHYUL_DATA"), "/viz/yudesk/yudesk-summary")

y <- readRDS(libstats_all) %>%
    ## Filter out this month's data (so there's nothing incomplete that looks strange), then summarize.
    filter(date < floor_date(Sys.Date(), "month")) %>%
    count(question.type, question.format, time_spent, library.name, location.name, month_name, ayear)

write_csv(y, paste0(yudesk_summary, ".csv"))
saveRDS(y, paste0(yudesk_summary, ".rds"))
