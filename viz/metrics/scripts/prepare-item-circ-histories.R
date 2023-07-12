#!/usr/bin/env Rscript

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

###
### Configuration
###

## All these file paths should just work and don't require tweaking
metrics_data_d <-  paste0(Sys.getenv("DASHYUL_DATA"), "/metrics/")

book_circ_histories_f <- paste0(metrics_data_d, "book-circ-histories.csv")
book_circ_histories_rds <- paste0(metrics_data_d, "book-circ-histories.rds")

record_min_acq_year_f <- paste0(metrics_data_d, "record-min-acquisition-year.csv")
record_min_acq_year_rds <- paste0(metrics_data_d, "record-min-acquisition-year.rds")

symph_trans_data_d <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/transactions/")
alma_trans_data_d <- paste0(Sys.getenv("DASHYUL_DATA"), "/alma/transactions/")

alma_items_current_f <- paste0(Sys.getenv("DASHYUL_DATA"), "/alma/items/items-current.rds")
## alma_items_f cat_current_item_details_f <- paste0(symph_cat_data_d, "catalogue-current-item-details.rds")

###
### Libraries
###

suppressMessages(library(tidyverse))
suppressMessages(library(lubridate))
library(yulr)

###
### Checkouts
###
write("Reading Symphony checkouts (A1996–A2018) ...", stderr())
symphony_checkouts <- readRDS(paste0(symph_trans_data_d, "simple-checkouts-past.rds"))

write("Reading Alma transactions (A2018–) ...", stderr())
alma_transactions <- readRDS(paste0(alma_trans_data_d, "detailed-transactions-all.rds"))

###
### Get current catalogue information
###

write("Reading Alma catalogue data ...", stderr())
alma_items_current <- readRDS(alma_items_current_f)

## Filter to just the main libraries and books.  This could change.
## Ignore YORK-LAW, YORK-EDUC, SMIL, MAPS, NELLIE and some small oddities.

write("Filtering to books ...", stderr())
bibliographic_items <- alma_items_current |>
    filter(Local.Location %in% c("SCOTT", "FROST", "STEACIE", "BRONFMAN"),
           Item.Material.Type == "BOOK",
           Permanent.Physical.Location %in% c("SCOTT", "SC-OVERSZ", "SCOTT-JUV",
                                              "FROST", "FR-OVERSZ",
                                              "STEACIE",
                                              "BRONFMAN"),
           Policy %in% c("SCOTT-BOOK", "SCORE", "SC-CUR-RES", "SC-JUV-BK", "SMIL-BOOK",
                         "FROST-BOOK",
                         "STEAC-BOOK",
                         "BRONF-BOOK",
                         "BOOK")
           )

###
### Merge Symphony and Alma checkouts
###

write("Merging Symphony and Alma ...", stderr())
symphony_checkouts_renamed <- symphony_checkouts |>
    rename(Loan.Date = date, Barcode = item_barcode) |>
    select(circ_ayear, Loan.Date, Barcode)
alma_simple <- alma_transactions |>
    select(circ_ayear, Loan.Date, Barcode)
merged_checkouts_simple <- bind_rows(symphony_checkouts_renamed, alma_simple)

## Now combine that with the simple checkout information.

## Note: I don't know the acquisition date here, but I should get that.  For now, skip it.

write("Merging checkouts and item details ...", stderr())
items_and_checkouts <- bibliographic_items |>
    left_join(merged_checkouts_simple, by = "Barcode") |>
    select(Barcode,
           MMS.Record.ID,
           Shelf.Call.Number,
           ## Call.Number,
           ## Item.Call.Number,
           Local.Location,
           Permanent.Physical.Location,
           Policy,
           ## Item.Material.Type,
           circ_ayear
           )

###
### Circulation metrics calculations
###
write("Calculating histories ...", stderr())

## Glom together all items with their checkouts (if any). Makes it
## easy to do some quick sums, but it's not elegant.

book_circ_histories <- items_and_checkouts |>
    mutate(has_circed = ! is.na(circ_ayear)) |>
    count(Barcode,
          MMS.Record.ID,
          Shelf.Call.Number,
          ## Call.Number,
          ## Item.Call.Number,
          Local.Location,
          Permanent.Physical.Location,
          Policy,
          ## Item.Material.Type,
          circ_ayear,
          wt = has_circed
          ) |>
    rename(circs = n)

## Phew, finally, we can write it all out.
write("Writing book circ histories ...", stderr())

write_csv(book_circ_histories, book_circ_histories_f)
saveRDS(book_circ_histories, book_circ_histories_rds)
