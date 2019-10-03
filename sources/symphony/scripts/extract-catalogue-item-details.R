#!/usr/bin/env Rscript

## Convert a large CSV file into a structured R data frame,
## suitable for easy loading and reuse.
##
## All this does is load in catalogue-YYYYMMDD-item-details.csv,
## define the column types (character, integer, etc.) and then
## save it as an RDS file.

"usage: extract-catalogue-item-details.R --prefix <prefix>

options:
 --prefix <prefix>     Basename prefix to use
" -> doc

library(docopt)
suppressMessages(library(tidyverse))

opts <- docopt(doc)

prefix <- opts["prefix"]

catalogue_data_dir <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/catalogue/")

item_details_csv <- paste0(catalogue_data_dir, prefix, "-item-details.csv")
item_details_rds <- paste0(catalogue_data_dir, prefix, "-item-details.rds")

item_details <- read_csv(item_details_csv, col_types = "ccccciDDDiiccciccicccDcc")
saveRDS(item_details, file = item_details_rds)
