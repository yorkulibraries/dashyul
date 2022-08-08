#!/usr/bin/env Rscript

## Combine all detailed (from all current years and this year to date)
## into one file.

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

suppressMessages(library(tidyverse))

alma_transactions_data_d <- paste0(Sys.getenv("DASHYUL_DATA"), "/alma/transactions/")

past_files <- fs::dir_ls(alma_transactions_data_d, regexp = "detailed-transactions-a[[:digit:]]{4}.rds")

past_detailed <- past_files |>
    map_dfr(readRDS)

current_detailed <- readRDS(paste0(alma_transactions_data_d, "detailed-transactions-current.rds"))

all_detailed <- bind_rows(past_detailed, current_detailed)

saveRDS(all_detailed, paste0(alma_transactions_data_d, "detailed-transactions-all.rds"))

write(paste("Finished: ", Sys.time()), stderr())
