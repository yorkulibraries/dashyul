#!/usr/bin/env Rscript

library(tidyverse)
library(lubridate)
library(yulr)

dashboard_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/viz/dashboard/")

symphony_transactions_data_dir <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/transactions/")
symphony_catalogue_data_dir <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/catalogue/")

catalogue_title_metadata_file <- paste0(symphony_catalogue_data_dir, "catalogue-current-title-metadata.csv")

####
#### Symphony data
####

## Transactions

## In e.g. December we want September--November, so floor the month, subtract a month, and that gives
## the previous month.
## TODO Update this so it rolls over nicely in October without human intervention.  Or solve the September problem somehow.
months_to_read <- format(seq(from = as.Date("2017-09-01"), to = floor_date(Sys.Date(), "month") - months(1), by = "month"), "%Y%m")

write("Reading monthly transactions ...", stderr())

all_transaction_details <- data.frame()
for (month in months_to_read) {
  write(month, stderr())
  monthly_transactions <- read_csv(paste0(symphony_transactions_data_dir, month, "-transactions.csv"), col_types = "Dcccc")
  items <- read_csv(paste0(symphony_transactions_data_dir, month, "-items.csv"), col_types = "cccccccccc")
  users <- read_csv(paste0(symphony_transactions_data_dir, month, "-users.csv"), col_types = "cccccccccc")
  monthly_transaction_details <- left_join(monthly_transactions, items, by = "item_barcode") %>% left_join(users, by = "user_barcode") %>% filter(! is.na(faculty))
  all_transaction_details <- rbind(all_transaction_details, monthly_transaction_details)
}

write("Calculating ...", stderr())

## We want checkouts of everything that isn't an accessory, laptop, headphone, etc.
## These item types should be normalised---looks like people sometimes make up new ones.
all_checkouts <- all_transaction_details %>% filter(transaction_command == "CV")
all_checkouts <- all_checkouts %>% filter(! item_type %in% c("LAPTOP", "PHONECHAR", "SMIL-ACSRY", "ACCESSORY", "CABLEPC", "LAW-ACSRY", "IPAD"))
all_checkouts <- all_checkouts %>% filter(! grepl("(HEAD|MACBOOK|IPAD)", call_number))
all_checkouts <- all_checkouts %>% filter(! control_number %in% c("a1506037", "a2529550", "a2215511", "a3103097", "a2275708", "a1983265", "a2309305", "a2877007", "a3103097", "a3195548", "a3195552", "a3197914", "a3326615", "a3355741", "a2999756", "a1952111"))

## Not sure how this can happen, but it did with a phone charger that seemed to be removed from the catalogue.
all_checkouts <- all_checkouts %>% filter(! is.na(call_number))

## Rewrite the ED students's subject1 so that instead of being grouped by teachable
## (BIOL, EN, HIST, VISA) they are all grouped into EDUC.
all_checkouts$subject1[all_checkouts$faculty == "ED"] <- "EDUC"

all_holds <- all_transaction_details %>% filter(transaction_command == "JZ")

symph_checkouts_by_class_letter_file <- paste0(dashboard_data_dir,"symph-checkouts-by-class-letter.csv")
symph_checkouts_by_class_letter <- all_checkouts %>% group_by(faculty, subject1, lc_letters) %>% summarise(checkouts = n())
write_csv(symph_checkouts_by_class_letter, symph_checkouts_by_class_letter_file)

symph_checkouts_by_checkout_date_file <- paste0(dashboard_data_dir,"symph-checkouts-by-checkout-date.csv")
symph_checkouts_by_checkout_date <- all_checkouts %>% group_by(date, faculty, subject1) %>% summarise(checkouts = n())
write_csv(symph_checkouts_by_checkout_date, symph_checkouts_by_checkout_date_file)

symph_checkouts_by_item_type_file <- paste0(dashboard_data_dir, "symph-checkouts-by-item_type.csv")
symph_checkouts_by_item_type <- all_checkouts %>% group_by(faculty, subject1, item_type) %>% summarise(checkouts = n())
write_csv(symph_checkouts_by_item_type, symph_checkouts_by_item_type_file)

symph_checkouts_by_acq_year_file <- paste0(dashboard_data_dir, "symph-checkouts-by-acq-year.csv")
symph_checkouts_by_acq_year <- all_checkouts %>% select(item_barcode, user_barcode, faculty, subject1, acq_date) %>% mutate(acq_year = floor_date(as.Date(acq_date), "year")) %>% distinct %>% group_by(faculty, subject1, acq_year) %>% summarise(count = n())
write_csv(symph_checkouts_by_acq_year, symph_checkouts_by_acq_year_file)

symph_checkouts_by_student_year_file <- paste0(dashboard_data_dir,"symph-checkouts-by-student-year.csv")
symph_checkouts_by_student_year <- all_checkouts %>% select(item_barcode, user_barcode, faculty, subject1, degree, year) %>% distinct %>% group_by(user_barcode, faculty, subject1, degree, year) %>% summarise(items = n()) %>% ungroup %>% select(faculty, subject1, items, degree, year)
write_csv(symph_checkouts_by_student_year, symph_checkouts_by_student_year_file)

write("Reading catalogue title metadata ...", stderr())

## Title metdata

catalogue_title_metadata <- read_csv(catalogue_title_metadata_file, col_types = "ccc")

write("Calculating ...", stderr())

symphony_most_checkouted_file <- paste0(dashboard_data_dir,"symphony-most-checkedouted.csv")
symphony_most_checkouted <- all_checkouts %>% group_by(control_number, faculty, subject1) %>% summarise(checkouts = n()) %>% filter(checkouts >= 5) %>% left_join(catalogue_title_metadata, by = "control_number")
write_csv(symphony_most_checkouted, symphony_most_checkouted_file)

####
#### Demographics
####

write("Calculating demographics ...", stderr())

symphony_demographics_file <- paste0(dashboard_data_dir, "symphony-demographics.csv")
symphony_demographics <- all_checkouts %>% select(user_barcode, faculty, subject1, degree, year) %>% distinct %>% group_by(faculty, subject1, degree, year) %>% summarise(symphony = n())
write_csv(symphony_demographics, symphony_demographics_file)

## #### Dashboard

## write("Dashboard ...", stderr())

## ## Symphony borrows per day
## dash_symph_borrows_per_day <- all_checkouts %>% group_by(date) %>% summarise(borrows = n())
## write_csv(dash_symph_borrows_per_day, "data/dashboard-symph-borrows-per-day.csv")

## ## Symphony most borrowed
## min_borrows <- 5
## dash_symph_most_borrowed_titles <- all_checkouts %>% group_by(control_number) %>% summarise(borrows = n()) %>% filter(borrows >= min_borrows) %>% left_join(catalogue_title_metadata, by = "control_number") %>% mutate(record_link = link_to_vufind(control_number, readable_marc245(title_author))) %>% select(borrows, record_link)
## write_csv(dash_symph_most_borrowed_titles, "data/dashboard-symph-most-borrowed-titles.csv")

## ## Symphony holds
## dash_symph_most_holded_titles <- all_holds %>% filter(! item_type %in% c("SCOTT-RESV", "STEAC-RESV", "BRONF-RESV")) %>% group_by(control_number, item_type) %>% summarise(holds = n()) %>% left_join(catalogue_title_metadata, by = "control_number") %>% mutate(record_link = link_to_vufind(control_number, readable_marc245(title_author))) %>% ungroup %>% select(item_type, holds, record_link)
## write_csv(dash_symph_most_holded_titles, "data/dashboard-symph-most-holded-titles.csv")

## ## Total users
## dash_symph_users_so_far <- all_checkouts %>% select(user_barcode) %>% distinct %>% nrow
## write(dash_symph_users_so_far, file = "data/dashboard-symph-users-so-far.txt")

## ## Total items borrowed so far
## dash_symph_items_so_far <- all_checkouts %>% select(item_barcode) %>% distinct %>% nrow
## write(dash_symph_items_so_far, file = "data/dashboard-symph-items-so-far.txt")
