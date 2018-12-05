#!/usr/bin/env Rscript

## Convert a large CSV file into a structured R data frame,
## suitable for easy loading and reuse.
##
## All this does is load in catalogue-YYYYMMDD-isbn-item-number-map.csv,
## define the column types (character, integer, etc.) and then
## save it as an RDS file.

"usage: extract-catalogue-isbn-item-number-map.R --prefix <prefix>

options:
 --prefix <prefix>     Basename prefix to use
" -> doc

library(docopt)
library(tidyverse)

opts <- docopt(doc)

prefix <- opts["prefix"]

catalogue_data_dir <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/catalogue/")

isbn_item_number_csv <- paste0(catalogue_data_dir, prefix, "-isbn-item-number.csv")
isbn_item_number_rds <- paste0(catalogue_data_dir, prefix, "-isbn-item-number.rds")

isbn_item_number <- read_csv(isbn_item_number_csv, col_types = "cc")
saveRDS(isbn_item_number, file = isbn_item_number_rds)
