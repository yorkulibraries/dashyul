#!/usr/bin/env Rscript

## Convert a large CSV file into a structured R data frame,
## suitable for easy loading and reuse.
##
## All this does is load in catalogue-YYYYMMDD-title-metadata.csv,
## define the column types (character, integer, etc.) and then
## save it as an RDS file.

"usage: extract-catalogue-title-metadata.R --prefix <prefix>

options:
 --prefix <prefix>     Basename prefix to use, e.g. catalogue-201801
" -> doc

library(docopt)
suppressMessages(library(tidyverse))

opts <- docopt(doc)

prefix <- opts["prefix"]

catalogue_data_dir <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/catalogue/")

title_metadata_csv <- paste0(catalogue_data_dir, prefix, "-title-metadata.csv")
title_metadata_rds <- paste0(catalogue_data_dir, prefix, "-title-metadata.rds")

title_metadata <- read_csv(title_metadata_csv, col_types = "ccc")
saveRDS(title_metadata, file = title_metadata_rds)
