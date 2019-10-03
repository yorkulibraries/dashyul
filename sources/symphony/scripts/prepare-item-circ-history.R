#!/usr/bin/env Rscript

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

###
### Configuration
###

## All these file paths should just work and don't require tweaking
metrics_data_d <-  paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/metrics/")

item_circ_history_f <- paste0(metrics_data_d, "item-circ-history.csv")
item_circ_history_rds <- paste0(metrics_data_d, "item-circ-history.rds")

record_min_acq_year_f <- paste0(metrics_data_d, "record-min-acquisition-year.csv")
record_min_acq_year_rds <- paste0(metrics_data_d, "record-min-acquisition-year.rds")

symph_trans_data_d <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/transactions/")

symph_cat_data_d <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/catalogue/")
cat_current_item_details_f <- paste0(symph_cat_data_d, "catalogue-current-item-details.rds")

###
### Libraries
###

suppressMessages(library(tidyverse))
suppressMessages(library(lubridate))
library(yulr)

###
### Checkouts
###
write("Reading checkouts ...", stderr())
checkouts <- readRDS(paste0(symph_trans_data_d, "simple-checkouts-all.rds"))

###
### Catalogue data
###
write("Reading catalogue item data ...", stderr())
cat_current_item_details <- readRDS(cat_current_item_details_f)

## First, pick out just items that are in LC and have the item type
## we're interested in.  Ignore copies that are lost or missing.
items <- cat_current_item_details %>%
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

items$home_location[items$home_location == "FR-OVERSZ"] <- "FROST"
items$home_location[items$home_location == "SC-OVERSZ"] <- "SCOTT"

items$home_location[items$home_location == "LAW-CD"]      <- "LAW"
items$home_location[items$home_location == "LAW-CORE"]    <- "LAW"
items$home_location[items$home_location == "LAW-FICT"]    <- "LAW"
items$home_location[items$home_location == "LAW-GRNDFL"]  <- "LAW"
items$home_location[items$home_location == "LAW-MICRO"]   <- "LAW"
items$home_location[items$home_location == "LAW-OVSZ"]    <- "LAW"
items$home_location[items$home_location == "LAW-REF"]     <- "LAW"
items$home_location[items$home_location == "LAW-REFDESK"] <- "LAW"
items$home_location[items$home_location == "LAW-SC-REF"]  <- "LAW"
items$home_location[items$home_location == "LAW-STOR"]    <- "LAW"

## If no location is known, mark it X, don't leave it as NA.
items$current_location[is.na(items$current_location)] <- "X"

## Set the academic year for the acquisition.
items <- items %>% mutate(acq_ayear = academic_year(acq_date))

## And pick out the few fields we care about.
items <- items %>% select(item_barcode,
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
write("Calculating history ...", stderr())

## Glom together all items with all their checkouts. Makes it easy to
## do some quick sums, but it's not elegant.
items_and_checkouts <- left_join(items, checkouts, by = "item_barcode")

item_circ_history <- items_and_checkouts %>%
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

## Phew, finally, we can write it all out.
write("Writing item circ history ...", stderr())

write_csv(item_circ_history, item_circ_history_f)
saveRDS(item_circ_history %>% ungroup(), item_circ_history_rds)

## And now write out the minimum acquisition year among all
## the items belonging to a record
write("Writing mininum acquistion year for records ...", stderr())

record_min_acq_year <- items %>%
    group_by(control_number) %>%
    mutate(min_acq_ayear = min(acq_ayear)) %>%
    distinct(control_number, min_acq_ayear)

write_csv(record_min_acq_year, record_min_acq_year_f)
saveRDS(record_min_acq_year, record_min_acq_year_rds)

write(paste("Finished: ", Sys.time()), stderr())
