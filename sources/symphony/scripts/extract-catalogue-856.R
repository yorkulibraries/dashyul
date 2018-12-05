#!/usr/bin/env Rscript

## Convert a large CSV file into a structured R data frame,
## suitable for easy loading and reuse.
##
## All this does is load in catalogue-YYYYMMDD-856.csv,
## define the column types (character, integer, etc.) and then
## save it as an RDS file.

"usage: extract-856.R --prefix <prefix>

options:
 --prefix <prefix>     Basename prefix to use
" -> doc

library(docopt)
library(tidyverse)

opts <- docopt(doc)

prefix <- opts["prefix"]

catalogue_data_d <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/catalogue/")

eight56_csv <- paste0(catalogue_data_dir, prefix, "-856.csv")
eight56_rds <- paste0(catalogue_data_dir, prefix, "-856.rds")

eight56 <- read_csv(eight56_csv, col_types = "cccc")
saveRDS(eight56, file = eight56_rds)
