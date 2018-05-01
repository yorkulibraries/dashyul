#!/usr/bin/env Rscript

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

library(lubridate)
library(tidyverse)
library(yulr)

## Default to the current academic year unless one is specified
args <- commandArgs(trailingOnly = TRUE)
current_ayear <- args[1]
if (length(args) == 0) {
    current_ayear <- academic_year(Sys.Date())
    write(paste("Using year:", current_ayear), stderr())
}

###
### Files and directories
###

prism_data_dir <- paste0(Sys.getenv("DASHYUL_DATA"), "/prism/")
prism_data_file <- paste0(prism_data_dir, "prism-data-a", current_ayear, ".csv")

estutte_data_dir <- paste0(Sys.getenv("DASHYUL_DATA"), "/viz/estutte/")

symphony_source_lib_dir <- paste0(Sys.getenv("DASHYUL_HOME"), "/sources/symphony/lib/")

symphony_transactions_data_dir <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/transactions/")

symphony_catalogue_data_dir <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/catalogue/")
catalogue_current_item_details_file <- paste0(symphony_catalogue_data_dir, "catalogue-current-item-details.csv")
catalogue_current_title_metadata_file <- paste0(symphony_catalogue_data_dir, "catalogue-current-title-metadata.csv")

isbn_item_map_file <- paste0(symphony_catalogue_data_dir, "catalogue-current-isbn-item-number.csv")
isbn_item_map <- read_csv(isbn_item_map_file, col_types = "cc")

###
### Read in the Prism data
###
prism <- read_csv(prism_data_file)

## Filter out things we don't want
prism <- prism %>%
    filter(! grepl("^CK ", stitle)) %>% ## Course kits
    filter(faculty != "LW") ## Law courses

###
### Mix in with our holdings.
###

write("Reading checkouts ...", stderr())

## Get simple data on checkouts from this current year.
## Result is data frame: current_simple_checkouts
source(paste0(symphony_source_lib_dir, "get-current-year-simple-checkouts.R"))

###
### Catalogue data
###
write("Reading catalogue item data ...", stderr())

catalogue_current_item_details <- read_csv(catalogue_current_item_details_file, col_types = "")

all_prism_isbns <- prism$isbn
all_prism_items <- isbn_item_map %>% filter(isbn %in% all_prism_isbns) %>% select(item_barcode) %>% unlist

write("Writing ...", stderr())

prism_item_circs <- current_simple_checkouts %>%
    filter(item_barcode %in% all_prism_items) %>%
    count(item_barcode) %>%
    rename(circs = n)

write_csv(prism_item_circs, paste0(estutte_data_dir, "estutte-item-circs-a", current_ayear, ".csv"))

prism_isbn_item_map <- isbn_item_map %>% filter(isbn %in% all_prism_isbns)
write_csv(prism_isbn_item_map, paste0(estutte_data_dir, "estutte-isbn-item-a", current_ayear, ".csv"))

prism_item_details <- catalogue_current_item_details %>%
    filter(item_barcode %in% prism_isbn_item_map$item_barcode)
write_csv(prism_item_details, paste0(estutte_data_dir, "estutte-item-details-a", current_ayear, ".csv"))
