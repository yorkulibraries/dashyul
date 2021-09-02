#!/usr/bin/env Rscript

## Aggregates all LibStats files (past years and the current one)
## into one big file.

suppressMessages(library(tidyverse))
library(fs)
library(yulr)
library(lubridate)

libstats_data_d <- paste0(Sys.getenv("DASHYUL_DATA"), "/libstats/")

write("Reading ...", stderr())

## Catch libstats-YYYY.csv and the current one, libstats-current.csv.
files <- fs::dir_ls(libstats_data_d, glob = "*libstats-*.csv")

l <- files %>%
    map_dfr(read_csv) %>%
    mutate(date = as.Date(timestamp, format="%m/%d/%Y %r"), month_name = month(date, label = TRUE)) %>%
    mutate(ayear = academic_year(date)) %>%
    select(date, month_name, ayear, question.type, question.format, time_spent, library.name, location.name, patron_type)

write("Writing ...", stderr())

write_csv(l, paste0(libstats_data_d, "all.csv"))
saveRDS(l, paste0(libstats_data_d,  "all.rds"))
