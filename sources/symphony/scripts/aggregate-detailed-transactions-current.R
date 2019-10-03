#!/usr/bin/env Rscript

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

suppressMessages(library(tidyverse))
suppressMessages(library(lubridate))
library(yulr)

symphony_trans_data_d <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/transactions/")

## Set up a data frame with the proper columns, because
## we need to rely on it working even if it ends up being
## empty because it's September.
all_trans_details <- tibble(date = as.Date(character()),
                            transaction_command = character(),
                            library = character(),
                            item_barcode = character(),
                            user_barcode = character(),
                            control_number = character(),
                            call_number = character(),
                            lc_letters = character(),
                            lc_digits = character(),
                            home_location = character(),
                            item_type = character(),
                            acq_date = as.Date(character()),
                            class_scheme = character(),
                            faculty = character(),
                            degree = character(),
                            progtype = character(),
                            year = character(),
                            subject1 = character(),
                            subject2 = character()
                            )

if (format(Sys.Date(), "%m") != "09") {
    ## If the current month is September, then there is nothing
    ## to read.  If it's October, this will read from September--September,
    ## which is just September, so it works.
    months_to_read <- format(seq(from = start_of_academic_year(academic_year(Sys.Date())),
                                 to = floor_date(Sys.Date(), "month") - months(1),
                                 by = "month"),
                             "%Y%m")

    write("Reading this year's monthly transactions ...", stderr())

    for (month in months_to_read) {
        write(month, stderr())

        monthly_trans <- read_csv(paste0(symphony_trans_data_d, month, "-transactions.csv"), col_types = "Dcccc")
        items <- read_csv(paste0(symphony_trans_data_d, month, "-items.csv"), col_types = "cccccccccc")
        users <- read_csv(paste0(symphony_trans_data_d, month, "-users.csv"), col_types = "cccccccccc")

        monthly_trans_details <- left_join(monthly_trans, items, by = c("library", "item_barcode")) %>%
            left_join(users, by = "user_barcode") %>%
            filter(! is.na(faculty))

        all_trans_details <- rbind(all_trans_details, monthly_trans_details)
    }

}

all_trans_details <- all_trans_details %>%
    mutate(circ_ayear = academic_year(date)) ## Always the current academic year.

write("Writing out ...", stderr())
saveRDS(all_trans_details, paste0(symphony_trans_data_d, "detailed-transactions-current-pii.rds"))

write(paste("Finished: ", Sys.time()), stderr())
