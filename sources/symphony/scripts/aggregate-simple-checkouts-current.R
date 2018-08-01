#!/usr/bin/env Rscript

## In e.g. December we want September--November, so floor the month,
## subtract a month, and that gives the previous month.

## TODO Update this so it rolls over nicely in October without human
## intervention. Or solve the September problem somehow.

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

library(tidyverse)
library(lubridate)
library(yulr)

symphony_transactions_data_dir <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/transactions/")

months_to_read <- format(seq(from = as.Date("2017-09-01"),
                             to = floor_date(Sys.Date(), "month") - months(2),
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
