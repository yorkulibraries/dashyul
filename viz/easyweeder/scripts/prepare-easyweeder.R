#!/usr/bin/env Rscript

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

library(tidyverse)
library(lubridate)
library(yulr)

ezweeder_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/viz/easyweeder/")
ezweeder_checkout_file <- paste0(ezweeder_data_dir, "easyweeder-checkouts.csv")
ezweeder_items_file <- paste0(ezweeder_data_dir, "easyweeder-items.csv")
ezweeder_titles_file <- paste0(ezweeder_data_dir, "easyweeder-titles.csv")

symphony_transactions_data_dir <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/transactions/")
symphony_catalogue_data_dir   <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/catalogue/")

catalogue_current_item_details_file <- paste0(symphony_catalogue_data_dir, "catalogue-current-item-details.csv")
catalogue_current_title_metadata_file <- paste0(symphony_catalogue_data_dir, "catalogue-current-title-metadata.csv")

symphony_source_lib_dir <- paste0(Sys.getenv("DASHYUL_HOME"), "/sources/symphony/lib/")

## First, get checkout data.  This includes all checkouts, including many
## we don't care about (like laptop chargers), but we'll filter all that
## out later.

write("Reading checkouts ...", stderr())

## Get simple data on checkouts from this current year.
## Result is data frame: current_simple_checkouts
source(paste0(symphony_source_lib_dir, "get-current-year-simple-checkouts.R"))

## Get all checkouts from past yearss.
## Result is data frame: past_simple_checkouts
source(paste0(symphony_source_lib_dir, "get-past-simple-checkouts.R"))

## Combine, and we've got them all.
checkouts <- bind_rows(past_simple_checkouts, current_simple_checkouts)

write("Writing checkouts ...", stderr())
write_csv(checkouts, ezweeder_checkout_file)

## Next, prepare the catalogue data.

write("Reading catalogue item data ...", stderr())
catalogue_current_item_details <- read_csv(catalogue_current_item_details_file, col_types = "")

## Now construct the Easy Weeder data bit by bit.
## First, pick out just items from the libraries we're interested in.
items <- catalogue_current_item_details %>% filter(home_location %in% c("SCOTT", "STEACIE", "FROST", "BRONFMAN", "LAW"))
## Filter to just item types we're interested in (not microform, etc.).
items <- items %>% filter(item_type %in% c("SCOTT-BOOK", "STEAC-BOOK", "FROST-BOOK", "BRONF-BOOK", "LAW-BOOK")) %>% filter(class_scheme == "LC")
## If no location is known, mark it X, don't leave it as NA.
items$current_location[is.na(items$current_location)] <- "X"
## Ignore discards.
items <- items %>% filter(current_location != "DISCARD")
## Set the academic year for the acquisition.
items <- items %>% mutate(acq_ayear = academic_year(acq_date))
## And pick out the few fields we care about.
items <- items %>% select(item_barcode, control_number, lc_letters, lc_digits, home_location, item_type, acq_ayear)

write("Writing items ...", stderr())
write_csv(items, ezweeder_items_file)

## Finally, pull title metadata for everything in the items list.

write("Reading catalogue title metadata ...", stderr())
catalogue_current_title_metadata <- read_csv(catalogue_current_title_metadata_file, col_types = "ccc")
titles <- catalogue_current_title_metadata %>% filter(control_number %in% items$control_number)

write("Writing title details ...", stderr())
write_csv(titles, ezweeder_titles_file)

write(paste("Finished: ", Sys.time()), stderr())
