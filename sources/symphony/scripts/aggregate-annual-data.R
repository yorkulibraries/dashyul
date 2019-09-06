#!/usr/bin/env Rscript

## Aggregates all of the four types of monthly Symphony transaction
## log files (e.g. YYYYMM-transactions.csv) from a given year, thus
## combining all of the monthly data into nice annual files.
## It is meant to be used in September.

library(docopt)

"usage: aggregate-annual-data.R --ayear <ayear>

options:
 --ayear <ayear>     Academic year to aggregate
" -> doc

opts <- docopt(doc)
ayear <- as.integer(opts["ayear"])

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

suppressPackageStartupMessages(library(tidyverse))
library(yulr)
library(lubridate)

symphony_trans_d <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/transactions/")

months_to_read <- format(seq(from = start_of_academic_year(ayear),
                             to = (start_of_academic_year(ayear + 1) - months(1)),
                             by = "month"),
                         "%Y%m")

## Every month we make four files. Now we want to aggregate each type
## into one big annual file.

yearly_items <- data.frame()
yearly_records <- data.frame()
yearly_transactions <- data.frame()
yearly_users <- data.frame()

transactions_depii <- data.frame()

for (month in months_to_read) {
    write(month, stderr())

    monthly_items <- read_csv(paste0(symphony_trans_d, month, "-items.csv"), col_types = "ccccccccDc")
    yearly_items <- rbind(yearly_items, monthly_items)

    monthly_records <- read_csv(paste0(symphony_trans_d, month, "-records.csv"), col_types = "ccc")
    yearly_records <- rbind(yearly_records, monthly_records)

    monthly_transactions <- read_csv(paste0(symphony_trans_d, month, "-transactions.csv"), col_types = "Dcccc")
    yearly_transactions <- rbind(yearly_transactions, monthly_transactions)

    monthly_users <- read_csv(paste0(symphony_trans_d, month, "-users.csv"), col_types = "cccccccccc")
    yearly_users <- rbind(yearly_users, monthly_users)

    monthly_transactions_depii <- monthly_transactions %>%
        left_join(monthly_users, by = "user_barcode") %>%
        select(-user_barcode, -cyin)
    transactions_depii <- rbind(transactions_depii, monthly_transactions_depii)
}

write("Deduping ...", stderr())

yearly_items   <- yearly_items   %>% arrange(desc(item_barcode))   %>% distinct()
yearly_records <- yearly_records %>% arrange(desc(control_number)) %>% distinct()
yearly_users   <- yearly_users   %>% arrange(desc(user_barcode))   %>% distinct()

write("Writing out ...", stderr())

write_csv(yearly_items, paste0(symphony_trans_d, "symphony-items-a", ayear, ".csv"))
write_csv(yearly_records, paste0(symphony_trans_d, "symphony-records-a", ayear, ".csv"))

write_csv(yearly_transactions, paste0(symphony_trans_d, "symphony-transactions-a", ayear, ".csv"))
saveRDS(yearly_transactions, paste0(symphony_trans_d, "symphony-transactions-a", ayear, ".rds"))

write_csv(transactions_depii, paste0(symphony_trans_d, "symphony-transactions-a", ayear, "-depii.csv"))
saveRDS(transactions_depii, paste0(symphony_trans_d, "symphony-transactions-a", ayear, "-depii.rds"))

write(paste("Finished: ", Sys.time()), stderr())
