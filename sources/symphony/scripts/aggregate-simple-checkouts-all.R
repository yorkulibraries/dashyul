#!/usr/bin/env Rscript

## Combine all simple checkouts (from all current years and this year
## to date) into one file.

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

library(dplyr)

symphony_transactions_data_dir <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/transactions/")

write("Reading current ...", stderr())
current_simple_checkouts <- readRDS(paste0(symphony_transactions_data_dir, "simple-checkouts-current.rds"))

write("Reading past ...", stderr())
past_simple_checkouts <- readRDS(paste0(symphony_transactions_data_dir, "simple-checkouts-past.rds"))

all_simple_checkouts <- bind_rows(past_simple_checkouts, current_simple_checkouts)

write("Writing out ...", stderr())
saveRDS(all_simple_checkouts, paste0(symphony_transactions_data_dir, "simple-checkouts-all.rds"))

write(paste("Finished: ", Sys.time()), stderr())
