#!/usr/bin/env Rscript

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

###
### Configuration
###

## Window for considering circ metrics, like circs per year.
## 5 should mean "in the last five years before this year", e.g.
## during a2017 that means a2012, a2013, a2014, a2015, a2016 and a2017
## to date.
circ_window_years <- 5

## All these file paths should just work and don't require tweaking
metrics_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/metrics/")
circ_metrics_file <- paste0(metrics_data_dir, "circ-metrics.csv")
circ_metrics_rds <- paste0(metrics_data_dir, "circ-metrics.rds")

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
## source(paste0(symphony_source_lib_dir, "get-current-year-simple-checkouts.R"))

## Get all checkouts from past yearss.
## Result is data frame: past_simple_checkouts
## source(paste0(symphony_source_lib_dir, "get-past-simple-checkouts.R"))

## Combine, and we've got them all.
## checkouts <- bind_rows(past_simple_checkouts, current_simple_checkouts)
checkouts <- readRDS(paste0(symphony_transactions_data_dir, "simple-checkouts-all.rds"))
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
write("3.  Calculating metrics ...", stderr())

## The starting year of the circulation window.  Used below for filtering.
circ_window_ayear <- academic_year(Sys.Date()) - circ_window_years

## Glom together all items with all their checkouts. Makes it easy to
## do some quick sums, but it's not elegant.
items_and_checkouts <- left_join(items, checkouts, by = "item_barcode")

## Circ details for each item, grouped by year. One row for each item
## each year it circed (and one row if it didn't).
write("Calculating item circ history ...", stderr())

item_circ_history <- items_and_checkouts %>%
    mutate(has_circed = ! is.na(circ_ayear)) %>%
    group_by(item_barcode, control_number, lc_letters, lc_digits, call_number, home_location, item_type, circ_ayear) %>%
    summarise(circs = sum(has_circed))

## Circ details for each item at a higher level: total circs and year
## last circed. One row for each item. Grouping in item_circ_history
## makes the mutation work.
write("Calculating item circ summary ...", stderr())
item_circ_summary <- item_circ_history %>%
    mutate(item_last_circed_ayear = max(circ_ayear)) %>%
    group_by(item_barcode, control_number, lc_letters, lc_digits, call_number, home_location, item_last_circed_ayear) %>%
    summarise(total_circs = sum(circs))
item_circ_summary$item_last_circed_ayear[is.na(item_circ_summary$item_last_circed_ayear)] <- "0"

## Create the circ metrics data frame, which we'll add to. Here, for
## each control number, in each location, show the number of copies,
## total circs, and year of last circ.
write("Setting up circ metrics ...", stderr())
circ_metrics <- item_circ_summary %>%
    group_by(control_number, lc_letters, lc_digits, call_number, home_location) %>%
    summarise(copies = n(),
              total_circs = sum(total_circs),
              last_circed_ayear = max(item_last_circed_ayear))

## Now, count total number of circs (in the circ window) for all items
## with the same control number and call number This lets us
## distinguish multiple volumes in a set (which each have different
## call numbers, ending e.g. in v1, v2, v3) from multiple copies of
## the same edition (which all have the same call number)
call_number_circs_in_window <- item_circ_history %>%
    filter(circ_ayear >= circ_window_ayear) %>%
    group_by(control_number, call_number, home_location) %>%
    summarise(circs_in_window = sum(circs))

## Join the circ_metrics data frame we began with this information
## about circs in the year window.
circ_metrics <- left_join(circ_metrics, call_number_circs_in_window,
                         by = c("control_number", "call_number", "home_location"))

## Minor fixes so the arithmetic works.
circ_metrics$circs_in_window[is.na(circ_metrics$circs_in_window)] <- "0"
circ_metrics$circs_in_window <- as.integer(circ_metrics$circs_in_window)

## Calculate busy factor
write("Calculating busy factor ...", stderr())
circ_metrics <- circ_metrics %>%
    mutate(raw_circs_per_copy = circs_in_window / copies,
           circs_per_copy = round(raw_circs_per_copy, 1),
           busy = round(raw_circs_per_copy / circ_window_years, 1)) %>%
    select(-raw_circs_per_copy)

## Phew, finally, we can write it all out.
write("Writing circ metrics ...", stderr())
write_csv(circ_metrics, circ_metrics_file)
saveRDS(circ_metrics, circ_metrics_rds)

write(paste("Finished: ", Sys.time()), stderr())
