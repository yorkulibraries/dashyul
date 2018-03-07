#!/usr/bin/env Rscript

library(tidyverse)
library(lubridate)
library(yulr)

etude_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/viz/etude/")

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

symph_checkouts_by_class_letter_file <- paste0(etude_data_dir,"symphony-checkouts-by-class-letter.csv")
symph_checkouts_by_class_letter <- all_checkouts %>% group_by(faculty, subject1, lc_letters) %>% summarise(checkouts = n())
write_csv(symph_checkouts_by_class_letter, symph_checkouts_by_class_letter_file)

symph_checkouts_by_checkout_date_file <- paste0(etude_data_dir,"symphony-checkouts-by-checkout-date.csv")
symph_checkouts_by_checkout_date <- all_checkouts %>% group_by(date, faculty, subject1) %>% summarise(checkouts = n())
write_csv(symph_checkouts_by_checkout_date, symph_checkouts_by_checkout_date_file)

symph_checkouts_by_item_type_file <- paste0(etude_data_dir, "symphony-checkouts-by-item_type.csv")
symph_checkouts_by_item_type <- all_checkouts %>% group_by(faculty, subject1, item_type) %>% summarise(checkouts = n())
write_csv(symph_checkouts_by_item_type, symph_checkouts_by_item_type_file)

symph_checkouts_by_acq_year_file <- paste0(etude_data_dir, "symphony-checkouts-by-acq-year.csv")
symph_checkouts_by_acq_year <- all_checkouts %>% select(item_barcode, user_barcode, faculty, subject1, acq_date) %>% mutate(acq_year = floor_date(as.Date(acq_date), "year")) %>% distinct %>% group_by(faculty, subject1, acq_year) %>% summarise(count = n())
write_csv(symph_checkouts_by_acq_year, symph_checkouts_by_acq_year_file)

symph_checkouts_by_student_year_file <- paste0(etude_data_dir,"symphony-checkouts-by-student-year.csv")
symph_checkouts_by_student_year <- all_checkouts %>% select(item_barcode, user_barcode, faculty, subject1, degree, year) %>% distinct %>% group_by(user_barcode, faculty, subject1, degree, year) %>% summarise(items = n()) %>% ungroup %>% select(faculty, subject1, items, degree, year)
write_csv(symph_checkouts_by_student_year, symph_checkouts_by_student_year_file)

## Symphony demographics
write("Calculating demographics ...", stderr())

symphony_demographics_file <- paste0(etude_data_dir, "symphony-demographics.csv")
symphony_demographics <- all_checkouts %>% select(user_barcode, faculty, subject1, degree, year) %>% distinct %>% group_by(faculty, subject1, degree, year) %>% summarise(symphony = n())
write_csv(symphony_demographics, symphony_demographics_file)

## Title metdata
write("Reading catalogue title metadata ...", stderr())

catalogue_title_metadata <- read_csv(catalogue_title_metadata_file, col_types = "ccc")

write("Calculating ...", stderr())

symphony_most_checkouted_file <- paste0(etude_data_dir,"symphony-most-checkedouted.csv")
symphony_most_checkouted <- all_checkouts %>% group_by(control_number, faculty, subject1) %>% summarise(checkouts = n()) %>% filter(checkouts >= 5) %>% left_join(catalogue_title_metadata, by = "control_number")
write_csv(symphony_most_checkouted, symphony_most_checkouted_file)
