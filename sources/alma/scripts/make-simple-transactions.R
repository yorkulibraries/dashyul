#!/usr/bin/env Rscript

suppressMessages(library(tidyverse))
library(yulr)

alma_trans_data_d <- paste0(Sys.getenv("DASHYUL_DATA"), "/alma/transactions/")

detailed <- readRDS(paste0(alma_trans_data_d, "detailed-transactions-all.rds"))

simple <- detailed |> mutate(circ_ayear = academic_year(Loan.Date)) |>
    select(circ_ayear, Loan.Date, Permanent.Physical.Location, Barcode, MMS.Record.ID)

write_csv(simple |> head(10), paste0(alma_trans_data_d, "simple-checkouts-all.csv"))
saveRDS(simple, paste0(alma_trans_data_d, "simple-checkouts-all.rds"))
