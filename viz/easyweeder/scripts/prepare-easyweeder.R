#!/usr/bin/env Rscript

library(tidyverse)
library(lubridate)
library(yulr)

write("Reading in transactions ...", stderr())

ezweeder_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/viz/circyul/")
ezweeder_file <- paste0(ezweeder_data_dir, "ezweeder.csv")



circulated_item_details_file <- paste0(circyul_data_dir, "circulated_item_details.csv")
circulated_title_metadata_file <- paste0(circyul_data_dir, "circulated_title_metadata.csv")

transaction_data_dir <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/transactions/")
catalogue_data_dir   <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/catalogue/")

catalogue_current_item_details_file <- paste0(catalogue_data_dir, "catalogue-current-item-details.csv")
catalogue_current_title_metadata_file <- paste0(catalogue_data_dir, "catalogue-current-title-metadata.csv")

## Use Symphony lib for current year
## Make lib for all previous years




## First, grab the complete years.
## files <- list.files("../../symphony/data/transactions", pattern = "symphony-transactions-a(200[6789]|201[012345]).csv.gz$", full.names = TRUE)
files <- list.files("../../symphony/data/transactions", pattern = "symphony-transactions-a[[:digit:]]{4}.csv.gz$", full.names = TRUE)

checkouts <- do.call("rbind", lapply(files, read_csv, col_types = "Dcccc")) %>% filter(transaction_command == "CV") %>% mutate(circ_ayear = academic_year(date)) %>% select(item_barcode, library, circ_ayear)

## Now get the ones in this academic year so far.
current_academic_year <- academic_year(Sys.Date())
checkouts_so_far_this_ayear <- read_csv(paste0("../../symphony/data/transactions/symphony-transactions-so-far-a", current_academic_year, ".csv"), col_types = "Dcccc") %>% filter(transaction_command == "CV") %>% mutate(circ_ayear = academic_year(date)) %>% select(item_barcode, library, circ_ayear)

## Combine, and we've got them all.
checkouts <- bind_rows(checkouts, checkouts_so_far_this_ayear)

write("Reading in catalogue data ...", stderr())

ezweeder <- read_csv(catalogue_current_item_details_file, col_types = "")
ezweeder <- ezweeder %>% filter(home_location %in% c("SCOTT", "STEACIE", "FROST", "BRONFMAN", "LAW"))
ezweeder <- ezweeder %>% filter(item_type %in% c("SCOTT-BOOK", "STEAC-BOOK", "FROST-BOOK", "BRONF-BOOK", "LAW-BOOK")) %>% filter(class_scheme == "LC")
ezweeder$current_location[is.na(ezweeder$current_location)] <- "X"
ezweeder <- ezweeder %>% filter(current_location != "DISCARD")
ezweeder <- ezweeder %>% mutate(acq_ayear = academic_year(acq_date))
ezweeder <- ezweeder %>% select(item_barcode, control_number, lc_letters, lc_digits, home_location, item_type, acq_ayear)

ezweeder <- left_join(ezweeder, checkouts, by = "item_barcode")

write("Writing out combined data ...", stderr())

write_csv(ezweeder, ezweeder_file)
