#!/usr/bin/env Rscript

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

###
### Configuration
###

## All these file paths should just work and don't require tweaking

## Symphony

symph_trans_data_d <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/transactions/")
symph_cat_data_d <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/catalogue/")
symphony_item_details_f <- paste0(symph_cat_data_d, "catalogue-current-item-details.rds")

## Alma

metrics_data_d <-  paste0(Sys.getenv("DASHYUL_DATA"), "/alma/metrics/")

item_circ_histories_f <- paste0(metrics_data_d, "item-circ-histories.csv")
item_circ_histories_rds <- paste0(metrics_data_d, "item-circ-histories.rds")

record_min_acq_year_f <- paste0(metrics_data_d, "record-min-acquisition-year.csv")
record_min_acq_year_rds <- paste0(metrics_data_d, "record-min-acquisition-year.rds")

alma_trans_data_d <- paste0(Sys.getenv("DASHYUL_DATA"), "/alma/transactions/")

detailed_transactions_rds <- paste0(alma_trans_data_d, "detailed-transactions-all.rds")

alma_items_rds <- paste0(Sys.getenv("DASHYUL_DATA"), "/alma/items/items-current.rds")

###
### Libraries
###

suppressMessages(library(tidyverse))
suppressMessages(library(lubridate))
library(yulr)

###
### Transactions: Symphony
###

write("Symphony ...", stderr())

## Checkouts

write("Reading checkouts ...", stderr())
checkouts <- readRDS(paste0(symph_trans_data_d, "simple-checkouts-all.rds"))

## Catalogue data

write("Reading old catalogue item data ...", stderr())
symphony_item_details <- readRDS(symphony_item_details_f)

## First, pick out just items that are in LC and have the item type
## we're interested in.  Ignore copies that are lost or missing.
symphony_items <- symphony_item_details %>%
    filter(class_scheme == "LC",
           home_location %in% c("BRONFMAN",
                                "E-ASIAN-RM",
                                "FROST", "FR-OVERSZ",
                                "LAW", "LAW-CD", "LAW-CORE", "LAW-FICT", "LAW-GRNDFL",
                                "LAW-MICRO", "LAW-OVSZ", "LAW-REF", "LAW-REFDESK", "LAW-SC-REF", "LAW-STOR",
                                "SCOTT", "SC-OVERSZ",
                                "STEACIE"),
           ! current_location %in% c("LOST", "MISSING", "DISCARD"),
           item_type %in% c("BRONF-BOOK",
                            "E-ASIAN-BK",
                            "FROST-BOOK",
                            "LAW-BOOK", "LAW-CORE", "BOOK",
                            "SCOTT-BOOK",
                            "STEAC-BOOK")
           )

symphony_items$home_location[symphony_items$home_location == "FR-OVERSZ"] <- "FROST"
symphony_items$home_location[symphony_items$home_location == "SC-OVERSZ"] <- "SCOTT"

symphony_items$home_location[symphony_items$home_location == "LAW-CD"]      <- "LAW"
symphony_items$home_location[symphony_items$home_location == "LAW-CORE"]    <- "LAW"
symphony_items$home_location[symphony_items$home_location == "LAW-FICT"]    <- "LAW"
symphony_items$home_location[symphony_items$home_location == "LAW-GRNDFL"]  <- "LAW"
symphony_items$home_location[symphony_items$home_location == "LAW-MICRO"]   <- "LAW"
symphony_items$home_location[symphony_items$home_location == "LAW-OVSZ"]    <- "LAW"
symphony_items$home_location[symphony_items$home_location == "LAW-REF"]     <- "LAW"
symphony_items$home_location[symphony_items$home_location == "LAW-REFDESK"] <- "LAW"
symphony_items$home_location[symphony_items$home_location == "LAW-SC-REF"]  <- "LAW"
symphony_items$home_location[symphony_items$home_location == "LAW-STOR"]    <- "LAW"

## If no location is known, mark it X, don't leave it as NA.
symphony_items$current_location[is.na(symphony_items$current_location)] <- "X"

## Set the academic year for the acquisition.
symphony_items <- symphony_items %>% mutate(acq_ayear = academic_year(acq_date))

## And pick out the few fields we care about.
symphony_items <- symphony_items %>% select(item_barcode,
                                          control_number,
                                          lc_letters,
                                          lc_digits,
                                          call_number,
                                          home_location,
                                          item_type,
                                          acq_ayear
                                          )

###
### Circulation metrics calculations
###
write("Calculating Symphony history ...", stderr())

## Glom together all items with all their checkouts. Makes it easy to
## do some quick sums, but it's not elegant.
symphony_items_and_checkouts <- left_join(symphony_items, checkouts, by = "item_barcode")

symphony_history <- symphony_items_and_checkouts %>%
    mutate(has_circed = ! is.na(circ_ayear)) %>%
    mutate(lc_digits = as.numeric(lc_digits)) %>%
    count(item_barcode,
          control_number,
          lc_letters,
          lc_digits,
          call_number,
          home_location,
          item_type,
          circ_ayear,
          wt = has_circed
          ) %>%
    rename(circs = n)

## Now we have the Symphony data organized.

###
### Transactions: Alma
###
write("Reading Alma transactions ...", stderr())
alma_detailed <- readRDS(detailed_transactions_rds)

## First, pick out just items that are in LC and have the item type
## we're interested in.  Ignore copies that are lost or missing.
alma_trans <- alma_detailed %>%
    ## filter(Policy %in% c("BRONFMAN",
    ##                      "E-ASIAN-RM",
    ##                      "FROST", "FR-OVERSZ",
    ##                      "LAW", "LAW-CD", "LAW-CORE", "LAW-FICT", "LAW-GRNDFL",
    ##                      "LAW-MICRO", "LAW-OVSZ", "LAW-REF", "LAW-REFDESK", "LAW-SC-REF", "LAW-STOR",
    ##                   "SCOTT", "SC-OVERSZ",
    ##                   "STEACIE"),
    filter(Item.Material.Type == "BOOK") |>
    select(MMS.Record.ID,
           Barcode,
           Loan.Date,
           circ_ayear)

###
### Catalogue data
###
write("Reading catalogue item data ...", stderr())
alma_items <- readRDS(alma_items_rds) |>
    mutate(acq_ayear = academic_year(date)) |>
    ## And pick out the few fields we care about.
    select(MMS.Record.ID,
           Barcode,
           Call.Number,
           Local.Location,
           Policy,
           acq_ayear
           )

###
### Circulation metrics calculations
###
write("Calculating Alma history ...", stderr())

## Glom together all items with all their checkouts. Makes it easy to
## do some quick sums, but it's not elegant.
alma_items_and_trans <- left_join(alma_items, alma_trans, by = c("MMS.Record.ID", "Barcode"))

alma_history <- alma_items_and_trans |>
    mutate(has_circed = ! is.na(circ_ayear)) |>
    count(MMS.Record.ID,
          Barcode,
          Call.Number,
          Local.Location,
          Policy,
          circ_ayear,
          wt = has_circed) |>
    rename(circs = n) |>
    mutate(Symphony.ID = NA)

###
### THE GREAT MERGER
###

write("Merging histories ...", stderr())

symphony_history_almaish <- symphony_history |>
    rename(Barcode = item_barcode,
           Call.Number = call_number,
           Local.Location = home_location,
           Policy = item_type,
           Symphony.ID = control_number) |>
    mutate(MMS.Record.ID = NA) |>
    select(-lc_letters, -lc_digits)

item_circ_histories <- bind_rows(symphony_history_almaish, alma_history)

## Phew, finally, we can write it all out.
write("Writing histories ...", stderr())

write_csv(item_circ_histories, item_circ_histories_f)
saveRDS(item_circ_histories |> ungroup(), item_circ_histories_rds)

## And now write out the minimum acquisition year among all
## the items belonging to a record
write("Writing mininum acquistion year for records ...", stderr())

record_min_acq_year <- items %>%
               group_by(MMS.Record.ID) %>%
               mutate(min_acq_ayear = min(acq_ayear)) %>%
               distinct(MMS.Record.ID, min_acq_ayear)

write_csv(record_min_acq_year, record_min_acq_year_f)
saveRDS(record_min_acq_year, record_min_acq_year_rds)

write(paste("Finished: ", Sys.time()), stderr())
