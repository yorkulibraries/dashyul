#!/usr/bin/env Rscript

## Convert a large CSV file into a structured R data frame,
## suitable for easy loading and reuse.
##
## All this does is load in catalogue-YYYYMMDD-item-details.csv,
## define the column types (character, integer, etc.) and then
## save it as an RDS file.

"usage: extract-catalogue-item-details.R --dump-file <prefix>

options:
 --dump-file <prefix>     Basename prefix to use
" -> doc

library(docopt)
library(tidyverse)

opts <- docopt(doc)

dump_file <- opts["dump-file"]

catalogue_data_dir <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/catalogue/")

item_details_csv <- paste0(catalogue_data_dir, dump_file, "-item-details.csv")
item_details_rds <- paste0(catalogue_data_dir, dump_file, "-item-details.rds")

item_details <- read_csv(item_details_csv, col_types = "cccciiDDDiiccciccicccDcc")
saveRDS(item_details, file = item_details_rds)
