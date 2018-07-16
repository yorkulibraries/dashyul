#!/usr/bin/env Rscript
library(dplyr)
library(readr)
library(lubridate)

circyul_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/viz/circyul/")
circyul_checkouts_file <- paste0(circyul_data_dir, "checkouts.csv")
circulated_item_details_file <- paste0(circyul_data_dir, "circulated_item_details.csv")
circulated_title_metadata_file <- paste0(circyul_data_dir, "circulated_title_metadata.csv")

transaction_data_dir <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/transactions/")
catalogue_data_dir   <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/catalogue/")

catalogue_current_item_details_file <- paste0(catalogue_data_dir, "catalogue-current-item-details.csv")
catalogue_current_title_metadata_file <- paste0(catalogue_data_dir, "catalogue-current-title-metadata.csv")

files <- list.files(transaction_data_dir, pattern = "symphony-transactions-a(200[123456789]|201[0123456]).csv.gz$", full.names = TRUE)

write("Reading transaction logs ...", stderr())

checkouts <- do.call("rbind", lapply(files, read.csv)) %>%
    tbl_df() %>%
    filter(transaction_command == "CV") %>%
    select(date, library, item_barcode)

write("Reading item details ...", stderr())

item_details <- read_csv(catalogue_current_item_details_file, col_types = "ccccc_______cc______cc_c") %>%
    filter(library == "YORK") %>%
    filter(class_scheme == "LC") %>%
    filter(home_location %in% c("SCOTT", "STEACIE", "FROST", "BRONFMAN", "SCOTT-MAPS")) %>%
    filter(item_type %in% c("SCOTT-BOOK", "STEAC-BOOK", "FROST-BOOK", "BRONF-BOOK", "SCOTT-RESV", "SCORE", "MAP", "STEAC-RESV", "SCMAP-BOOK"))

circulated_item_details <- item_details %>%
    filter(item_barcode %in% checkouts$item_barcode)

write("Reading title_metadata ...", stderr())

title_metadata <- read_csv(catalogue_current_title_metadata_file)

circulated_title_metadata <- title_metadata %>%
    filter(control_number %in% circulated_item_details$control_number)

write("Writing out ...", stderr())

write_csv(checkouts, circyul_checkouts_file)
write_csv(circulated_item_details, circulated_item_details_file)
write_csv(circulated_title_metadata, circulated_title_metadata_file)
