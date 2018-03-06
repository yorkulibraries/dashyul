#!/usr/bin/env Rscript

library(tidyverse)
library(lubridate)
library(yulr)

dashboard_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/viz/dashboard/")

symphony_transactions_data_dir <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/transactions/")
symphony_catalogue_data_dir <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/catalogue/")
catalogue_title_metadata_file <- paste0(symphony_catalogue_data_dir, "catalogue-current-title-metadata.csv")

symphony_source_lib_dir <- paste0(Sys.getenv("DASHYUL_HOME"), "/sources/symphony/lib/")

## Read in the current year's transactions
## Result is data frame: all_transaction_details
source(paste0(symphony_source_lib_dir, "get-current-year-transactions.R"))

## Pick checkouts out from all_transaction_details,
## dropping various types and sources of items we don't want to track.
## Result is data frame: all_checkouts
source(paste0(symphony_source_lib_dir, "get-current-year-checkouts.R"))

all_holds <- all_transaction_details %>% filter(transaction_command == "JZ")

## Title metdata
write("Reading catalogue title metadata ...", stderr())
catalogue_title_metadata <- read_csv(catalogue_title_metadata_file, col_types = "ccc")

write("Calculating ...", stderr())

## Most checkouted
most_checkouted_file <- paste0(dashboard_data_dir,"symphony-most-checkouted.csv")
most_checkouted <- all_checkouts %>% group_by(control_number, faculty, subject1) %>% summarise(checkouts = n()) %>% filter(checkouts >= 5) %>% left_join(catalogue_title_metadata, by = "control_number")
write_csv(most_checkouted, most_checkouted_file)

## Symphony borrows per day
borrows_per_day_file <- paste0(dashboard_data_dir, "symphony-borrows-per-day.csv")
borrows_per_day <- all_checkouts %>% group_by(date) %>% summarise(borrows = n())
write_csv(borrows_per_day, borrows_per_day_file)

## Symphony most borrowed
min_borrows <- 5
most_borrowed_titles_file <- paste0(dashboard_data_dir, "symphony-most-borrowed-titles.csv")
most_borrowed_titles <- all_checkouts %>% group_by(control_number) %>% summarise(borrows = n()) %>% filter(borrows >= min_borrows) %>% left_join(catalogue_title_metadata, by = "control_number") %>% mutate(record_link = link_to_vufind(control_number, readable_marc245(title_author))) %>% select(borrows, record_link)
write_csv(most_borrowed_titles, most_borrowed_titles_file)

## Symphony holds
most_holded_titles_file <- paste0(dashboard_data_dir, "symphony-most-holded-titles.csv")
most_holded_titles <- all_holds %>% filter(! item_type %in% c("SCOTT-RESV", "STEAC-RESV", "BRONF-RESV")) %>% group_by(control_number, item_type) %>% summarise(holds = n()) %>% left_join(catalogue_title_metadata, by = "control_number") %>% mutate(record_link = link_to_vufind(control_number, readable_marc245(title_author))) %>% ungroup %>% select(item_type, holds, record_link)
write_csv(most_holded_titles, most_holded_titles_file)

## Total users
users_so_far_file <- paste0(dashboard_data_dir, "symphony-users-so-far.txt")
users_so_far <- all_checkouts %>% select(user_barcode) %>% distinct %>% nrow
write(users_so_far, file = users_so_far_file)

## Total items borrowed so far
items_so_far_file <- paste0(dashboard_data_dir, "symphony-items-so-far.txt")
items_so_far <- all_checkouts %>% select(item_barcode) %>% distinct %>% nrow
write(items_so_far, items_so_far_file)
