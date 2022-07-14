#!/usr/bin/env Rscript

## ADD NOTES

library(docopt)

"usage: extract-alma-transaction-details.R --id <id>

options:
 --id <id>     Report number (e.g. 202207110308)
" -> doc

opts <- docopt(doc)

suppressMessages(library(tidyverse))
library(yulr)

report_number <- opts["id"]
## report_number <- "202207110308"
yyyymmdd <- substr(report_number, 0, 8)

alma_trans_d <- paste0(Sys.getenv("DASHYUL_DATA"), "/alma/transactions/")
alma_trans_file <- paste0(alma_trans_d, "Transaction Report_", report_number, ".csv")

trans <- read_csv(alma_trans_file, name_repair = "universal", col_types = list(.default = col_character())) |>
    ## There are some bad rows in the CSV export that mess up the parsing,
    ## so skip any where the date doesn't start YYYY-MM-DD.  There are under 8,000 of these as of mid-2022.
    ## filter(grepl("^[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}", Creation.date)) |>
    rename(MMS.Record.ID = MMS.ID) |>
    mutate(Loan.Date = as.Date(Loan.Date),
           Return.Date = as.Date(Return.Date)) |>
    arrange(Loan.Date, desc(MMS.Record.ID))

write_csv(trans, paste0(alma_trans_d, "transactions-", yyyymmdd, ".csv"))
saveRDS(trans, paste0(alma_trans_d, "transactions-", yyyymmdd, ".rds"))
