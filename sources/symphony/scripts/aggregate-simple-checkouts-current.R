#!/usr/bin/env Rscript

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

library(tidyverse)
library(lubridate)
library(yulr)

symphony_transactions_data_dir <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/transactions/")

## The September problem:  in September we don't yet have any
## date for the current academic year, so use use last year's
## data.  That is, in Septepmber 2018, start from 2017-09-01.
start_date <- start_of_academic_year(academic_year(Sys.Date()))
if (format(Sys.Date(), "%m") == "09") {
    start_date <- start_of_academic_year(academic_year(Sys.Date()) - 1)
}

## But in later months, e.g. December, we want September--November, so
## floor the month, subtract a month, and that gives the previous
## month.
months_to_read <- format(seq(from = start_date,
                             to = floor_date(Sys.Date(), "month") - months(1),
                             by = "month"),
                         "%Y%m")

write("Reading monthly transactions ...", stderr())

current_simple_transactions <- data.frame()
for (month in months_to_read) {
    write(month, stderr())
    monthly_transactions <- read_csv(paste0(symphony_transactions_data_dir, month, "-transactions.csv"),
                                     col_types = "Dcccc")
    current_simple_transactions <- rbind(current_simple_transactions, monthly_transactions)
}

current_simple_checkouts <- current_simple_transactions %>%
    filter(transaction_command == "CV") %>%
    mutate(circ_ayear = academic_year(date)) %>% ## Always the current academic year.
    select(circ_ayear, date, library, item_barcode)

write("Writing out ...", stderr())
saveRDS(current_simple_checkouts, paste0(symphony_transactions_data_dir, "simple-checkouts-current.rds"))

write(paste("Finished: ", Sys.time()), stderr())
