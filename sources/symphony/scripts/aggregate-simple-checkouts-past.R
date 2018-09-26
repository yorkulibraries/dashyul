#!/usr/bin/env Rscript

## Aggregate all checkouts, from 1996 up to the previous
## academic year, into one file, in a simple format
## with just item_barcode, library, and circ_ayear.

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

library(tidyverse)
library(yulr)

symphony_transactions_data_dir <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/transactions/")

## Read in all past Symphony transactions, from 1996 up to the
## previous academic year.

write("Reading annual transactions ...", stderr())

## First, grab the complete years.
files <- list.files(symphony_transactions_data_dir,
                    pattern = "symphony-transactions-a[[:digit:]]{4}.csv.gz$",
                    full.names = TRUE)

past_simple_checkouts <- do.call("rbind",
                                 lapply(files, function(x) {
                                     write(x, stderr())
                                     read_csv(x, col_types = "Dcccc")
                                 })) %>%
    filter(transaction_command == "CV") %>%
    mutate(circ_ayear = academic_year(date)) %>%
    select(circ_ayear, date, library, item_barcode)

## If you don't want to note the files it's reading:
## past_simple_checkouts <- do.call("rbind", lapply(files, read_csv, col_types = "Dcccc"))

write("Writing out ...", stderr())
saveRDS(past_simple_checkouts, paste0(symphony_transactions_data_dir, "simple-checkouts-past.rds"))

write(paste("Finished: ", Sys.time()), stderr())
