#!/usr/bin/env Rscript

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

library(tidyverse)
library(lubridate)
library(yulr)

etude_data_d <-  paste0(Sys.getenv("DASHYUL_DATA"), "/viz/etude/")

symphony_trans_data_d <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/transactions/")
symphony_cat_data_d    <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/catalogue/")

cat_title_metadata_f <- paste0(symphony_cat_data_d, "catalogue-current-title-metadata.csv")

## Every transaction, with PII
all_trans_details <- readRDS(paste0(symphony_trans_data_d, "detailed-transactions-current-pii.rds"))

## Just checkouts, with chargers and laptops and things removed,
## along with various other items that just don't belong.
##
## TODO:  I bet this gets used somewhere else, so move it
## into one place.

cleaned_checkouts <- all_trans_details %>%
    filter(transaction_command == "CV") %>%
    filter(! item_type %in% c("LAPTOP", "PHONECHAR", "SMIL-ACSRY",
                              "ACCESSORY", "CABLEPC", "LAW-ACSRY",
                              "IPAD")
           ) %>%
    filter(! grepl("(HEAD|MACBOOK|IPAD)", call_number)) %>%
    filter(! control_number %in% c("a1506037", "a2529550", "a2215511",
                                   "a3103097", "a2275708", "a1983265",
                                   "a2309305", "a2877007", "a3103097",
                                   "a3195548", "a3195552", "a3197914",
                                   "a3326615", "a3355741", "a2999756",
                                   "a1952111")
           ) %>%
    ## Not sure how this can happen, but it did
    ## with a phone charger that seemed to be removed
    ## from the catalogue.
    filter(! is.na(call_number))

## all_holds <- all_transaction_details %>% filter(transaction_command == "JZ")

symph_checkouts_by_class_letter <- cleaned_checkouts %>%
    group_by(faculty, subject1, lc_letters) %>%
    summarise(checkouts = n())

write_csv(symph_checkouts_by_class_letter,
          paste0(etude_data_d, "symphony-checkouts-by-class-letter.csv"))

symph_checkouts_by_checkout_date <- cleaned_checkouts %>%
    group_by(date, faculty, subject1) %>%
    summarise(checkouts = n())

write_csv(symph_checkouts_by_checkout_date,
          paste0(etude_data_d, "symphony-checkouts-by-checkout-date.csv"))

symph_checkouts_by_item_type <- cleaned_checkouts %>%
    group_by(faculty, subject1, item_type) %>%
    summarise(checkouts = n())

write_csv(symph_checkouts_by_item_type,
          paste0(etude_data_d, "symphony-checkouts-by-item-type.csv"))

symph_checkouts_by_acq_year <- cleaned_checkouts %>%
    select(item_barcode, user_barcode, faculty, subject1, acq_date) %>%
    mutate(acq_year = floor_date(as.Date(acq_date), "year")) %>%
    distinct() %>%
    group_by(faculty, subject1, acq_year) %>%
    summarise(count = n())

write_csv(symph_checkouts_by_acq_year,
          paste0(etude_data_d, "symphony-checkouts-by-acq-year.csv"))

symph_checkouts_by_student_year <- cleaned_checkouts %>%
    select(item_barcode, user_barcode, faculty, subject1, degree, year) %>%
    distinct() %>%
    group_by(user_barcode, faculty, subject1, degree, year) %>%
    summarise(items = n()) %>%
    ungroup() %>%
    select(faculty, subject1, items, degree, year)

write_csv(symph_checkouts_by_student_year,
          paste0(etude_data_d, "symphony-checkouts-by-student-year.csv"))

## Symphony demographics
write("Calculating demographics ...", stderr())

symphony_demographics <- cleaned_checkouts %>%
    select(user_barcode, faculty, subject1, degree, year) %>%
    distinct() %>%
    group_by(faculty, subject1, degree, year) %>%
    summarise(symphony = n())

write_csv(symphony_demographics,
          paste0(etude_data_d, "symphony-demographics.csv"))

## Title metdata
write("Reading catalogue title metadata ...", stderr())

cat_title_metadata <- read_csv(cat_title_metadata_f, col_types = "ccc")

write("Calculating most checkouted ...", stderr())

symphony_checkouts_most_checkouted <- cleaned_checkouts %>%
    group_by(control_number, faculty, subject1) %>%
    summarise(checkouts = n()) %>%
    filter(checkouts >= 5) %>%
    left_join(cat_title_metadata, by = "control_number")

write_csv(symphony_checkouts_most_checkouted,
          paste0(etude_data_d, "symphony-checkouts-most-checkouted.csv"))

write(paste("Finished: ", Sys.time()), stderr())
