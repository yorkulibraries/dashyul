#!/usr/bin/env Rscript

## Convert a large CSV file into a structured R data frame,
## suitable for easy loading and reuse.
##
## All this does is load in catalogue-YYYYMMDD-isbn-item-number-map.csv,
## define the column types (character, integer, etc.) and then
## save it as an RDS file.

"usage: extract-catalogue-number-map.R --prefix <prefix>

options:
 --prefix <prefix>     Basename prefix to use
" -> doc

library(docopt)
suppressMessages(library(tidyverse))

opts <- docopt(doc)

prefix <- opts["prefix"]

catalogue_data_dir <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/catalogue/")

number_mapping_csv <- paste0(catalogue_data_dir, prefix, "-number-mapping.csv")
number_mapping_rds <- paste0(catalogue_data_dir, prefix, "-number-mapping.rds")

number_mapping <- read_csv(number_mapping_csv, col_types = "ccc")
saveRDS(number_mapping, file = number_mapping_rds)
