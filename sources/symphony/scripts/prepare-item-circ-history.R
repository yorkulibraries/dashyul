#!/usr/bin/env Rscript

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

###
### Configuration
###

## All these file paths should just work and don't require tweaking
metrics_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/metrics/")
item_circ_history_file <- paste0(metrics_data_dir, "item-circ-history.csv")
record_min_acq_year_file <- paste0(metrics_data_dir, "record-min-acquisition-year.csv")

symphony_transactions_data_dir <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/transactions/")

symphony_catalogue_data_dir <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/catalogue/")
catalogue_current_item_details_file <- paste0(symphony_catalogue_data_dir, "catalogue-current-item-details.csv")
catalogue_current_title_metadata_file <- paste0(symphony_catalogue_data_dir, "catalogue-current-title-metadata.csv")

symphony_source_lib_dir <- paste0(Sys.getenv("DASHYUL_HOME"), "/sources/symphony/lib/")

###
### Libraries
###

library(tidyverse)
library(lubridate)
library(yulr)

###
### Checkouts
###
write("1.  Reading checkouts ...", stderr())

## Get simple data on checkouts from this current year.
## Result is data frame: current_simple_checkouts
source(paste0(symphony_source_lib_dir, "get-current-year-simple-checkouts.R"))

## Get all checkouts from past yearss.
## Result is data frame: past_simple_checkouts
source(paste0(symphony_source_lib_dir, "get-past-simple-checkouts.R"))

## Combine, and we've got them all.
checkouts <- bind_rows(past_simple_checkouts, current_simple_checkouts)

###
### Catalogue data
###
write("2.  Reading catalogue item data ...", stderr())

catalogue_current_item_details <- read_csv(catalogue_current_item_details_file, col_types = "")

## First, pick out just items that are in LC and have the item type
## we're interested in.  Ignore copies that are lost or missing.
items <- catalogue_current_item_details %>%
    filter(class_scheme == "LC",
           home_location %in% c("BRONFMAN",
                                "FROST", "FR-OVERSZ",
                                "LAW", "LAW-CD", "LAW-CORE", "LAW-FICT", "LAW-GRNDFL",
                                "LAW-MICRO", "LAW-OVSZ", "LAW-REF", "LAW-REFDESK", "LAW-SC-REF", "LAW-STOR",
                                "SCOTT", "SC-OVERSZ",
                                "STEACIE"),
           ! current_location %in% c("LOST", "MISSING", "DISCARD"),
           item_type %in% c("BRONF-BOOK",
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
items <- items %>% select(item_barcode, control_number, lc_letters, lc_digits, call_number, home_location, item_type, acq_ayear)

###
### Circulation metrics calculations
###
write("3.  Calculating history ...", stderr())

## Glom together all items with all their checkouts. Makes it easy to
## do some quick sums, but it's not elegant.
items_and_checkouts <- left_join(items, checkouts, by = "item_barcode")

item_circ_history <- items_and_checkouts %>%
    mutate(has_circed = ! is.na(circ_ayear)) %>%
    group_by(item_barcode, control_number, lc_letters, lc_digits, call_number, home_location, item_type, circ_ayear) %>%
    summarise(circs = sum(has_circed))

## Phew, finally, we can write it all out.
write("Writing item circ history ...", stderr())
write_csv(item_circ_history, item_circ_history_file)

## And now write out the minimum acquisition year among all
## the items belonging to a record
write("Writing mininum acquistion year for records ...", stderr())
record_min_acq_year <- items %>%
    group_by(control_number) %>%
    mutate(min_acq_ayear = min(acq_ayear)) %>%
    distinct(control_number, min_acq_ayear)
write_csv(record_min_acq_year, record_min_acq_year_file)

write(paste("Finished: ", Sys.time()), stderr())
