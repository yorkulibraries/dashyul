#!/usr/bin/env Rscript

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

suppressMessages(library(tidyverse))
suppressMessages(library(lubridate))
library(yulr)

symphony_transactions_data_dir <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/transactions/")

## Set up a data frame with the proper columns, because
## we need to rely on it working even if it ends up being
## empty because it's September.
current_transactions <- tibble(date = as.Date(character()),
                               command = character(),
                               library = character(),
                               item_barcode = character(),
                               user_barcode = character())

start_date <- start_of_academic_year(academic_year(Sys.Date()))

write("Reading this year's monthly transactions ...", stderr())

if (format(Sys.Date(), "%m") != "09") {
    ## If the current month is September, then there is nothing
    ## to read.  If it's October, this will read from September--September,
    ## which is just September, so it works.
    months_to_read <- format(seq(from = start_date,
                                 to = floor_date(Sys.Date(), "month") - months(1),
                                 by = "month"),
                             "%Y%m")

    for (month in months_to_read) {
        write(month, stderr())
        monthly_transactions <- read_csv(paste0(symphony_transactions_data_dir, month, "-transactions.csv"),
                                         col_types = "Dcccc")
        current_transactions <- rbind(current_transactions, monthly_transactions)
    }
}

current_simple_checkouts <- current_transactions %>%
    filter(transaction_command == "CV") %>%
    mutate(circ_ayear = academic_year(date)) %>% ## Always the current academic year.
    select(circ_ayear, date, library, item_barcode)

write("Writing out ...", stderr())
saveRDS(current_simple_checkouts, paste0(symphony_transactions_data_dir, "simple-checkouts-current.rds"))

write(paste("Finished: ", Sys.time()), stderr())
