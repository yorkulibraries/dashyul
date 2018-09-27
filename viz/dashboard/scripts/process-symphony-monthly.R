#!/usr/bin/env Rscript

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

library(tidyverse)
library(lubridate)
library(yulr)

dashboard_data_d <-  paste0(Sys.getenv("DASHYUL_DATA"), "/viz/dashboard/")

symphony_trans_data_d <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/transactions/")
symphony_cat_data_d <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/catalogue/")
catalogue_title_metadata_f <- paste0(symphony_cat_data_d, "catalogue-current-title-metadata.csv")

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

all_holds <- all_trans_details %>% filter(transaction_command == "JZ")

## Title metdata
write("Reading catalogue title metadata ...", stderr())
catalogue_title_metadata <- read_csv(catalogue_title_metadata_f, col_types = "ccc")

write("Calculating ...", stderr())

## Most checkouted
most_checkouted_f <- paste0(dashboard_data_d,"symphony-most-checkouted.csv")
most_checkouted <- cleaned_checkouts %>%
    group_by(control_number, faculty, subject1) %>%
    summarise(checkouts = n()) %>%
    filter(checkouts >= 5) %>%
    left_join(catalogue_title_metadata, by = "control_number")
write_csv(most_checkouted, most_checkouted_f)

## Symphony borrows per day
borrows_per_day_f <- paste0(dashboard_data_d, "symphony-borrows-per-day.csv")
borrows_per_day <- cleaned_checkouts %>%
    group_by(date) %>%
    summarise(borrows = n())
write_csv(borrows_per_day, borrows_per_day_f)

## Symphony most borrowed
min_borrows <- 5
most_borrowed_titles_f <- paste0(dashboard_data_d, "symphony-most-borrowed-titles.csv")
most_borrowed_titles <- cleaned_checkouts %>%
    group_by(control_number) %>%
    summarise(borrows = n()) %>%
    filter(borrows >= min_borrows) %>%
    left_join(catalogue_title_metadata, by = "control_number") %>%
    mutate(record_link = link_to_vufind(control_number, readable_marc245(title_author))) %>%
    select(borrows, record_link)
write_csv(most_borrowed_titles, most_borrowed_titles_f)

## Symphony holds
most_holded_titles_f <- paste0(dashboard_data_d, "symphony-most-holded-titles.csv")
most_holded_titles <- all_holds %>%
    filter(! item_type %in% c("SCOTT-RESV", "STEAC-RESV", "BRONF-RESV")) %>%
    group_by(control_number, item_type) %>%
    summarise(holds = n()) %>%
    left_join(catalogue_title_metadata, by = "control_number") %>%
    mutate(record_link = link_to_vufind(control_number, readable_marc245(title_author))) %>%
    ungroup %>%
    select(item_type, holds, record_link)
write_csv(most_holded_titles, most_holded_titles_f)

## Total users
users_so_far_f <- paste0(dashboard_data_d, "symphony-users-so-far.txt")
users_so_far <- cleaned_checkouts %>%
    select(user_barcode) %>%
    distinct() %>%
    nrow()
write(users_so_far, file = users_so_far_f)

## Total items borrowed so far
items_so_far_f <- paste0(dashboard_data_d, "symphony-items-so-far.txt")
items_so_far <- cleaned_checkouts %>%
    select(item_barcode) %>%
    distinct() %>%
    nrow()
write(items_so_far, items_so_far_f)

write(paste("Finished: ", Sys.time()), stderr())
