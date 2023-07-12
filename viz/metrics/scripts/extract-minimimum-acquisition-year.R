#!/usr/bin/env Rscript

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

###
### Configuration
###

## All these file paths should just work and don't require tweaking
metrics_data_d <-  paste0(Sys.getenv("DASHYUL_DATA"), "/metrics/")

alma_items_current_f <- paste0(Sys.getenv("DASHYUL_DATA"), "/alma/items/items-current.rds")

###
### Libraries
###

suppressMessages(library(tidyverse))
suppressMessages(library(lubridate))
library(yulr)

write("Reading Alma catalogue data ...", stderr())
alma_items_current <- readRDS(alma_items_current_f)

## Now we need to know the minimum acquisition date for records
## (because one record might represent two copies of the same book
## that were bought at different times)
write("Writing minimum acquisition year for records ...", stderr())
record_min_acq_year <- alma_items_current |>
    select(MMS.Record.ID, Received.Date) |>
    group_by(MMS.Record.ID) |>
    slice_min(Received.Date) |>
    distinct() |>
    mutate(min_acq_ayear = academic_year(Received.Date)) |>
    select(MMS.Record.ID, min_acq_ayear)

write_csv(record_min_acq_year, record_min_acq_year_f)
saveRDS(record_min_acq_year, record_min_acq_year_rds)

write(paste("Finished: ", Sys.time()), stderr())
