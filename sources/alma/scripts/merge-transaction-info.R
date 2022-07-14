#!/usr/bin/env Rscript

library(docopt)

"usage: merge-transaction-info --yyyymmdd <yyyymmdd>

options:
 --yyyymmdd <yyyymmdd>      (e.g. 20220711)
" -> doc

opts <- docopt(doc)

suppressMessages(library(tidyverse))
library(yulr)

yyyymmdd <- opts["yyyymmdd"]

alma_trans_d <- paste0(Sys.getenv("DASHYUL_DATA"), "/alma/transactions/")
alma_trans_rds <- paste0(alma_trans_d, "transactions-", yyyymmdd, ".rds")
trans <- readRDS(alma_trans_rds)

alma_items_d <- paste0(Sys.getenv("DASHYUL_DATA"), "/alma/items/")

items <- readRDS(paste0(alma_items_d, "items-12052900060005164.rds"))

detailed <- left_join(trans, items,
                      by = c("MMS.Record.ID", "Title", "Barcode", "Call.Number")) |>
    mutate(ayear = academic_year(Loan.Date))

## Now I need to merge in the user information.

write_csv(detailed, paste0(alma_trans_d, "detailed-transactions-", yyyymmdd, ".csv"))
saveRDS(detailed, paste0(alma_trans_d, "detailed-transactions-", yyyymmdd, ".rds"))
