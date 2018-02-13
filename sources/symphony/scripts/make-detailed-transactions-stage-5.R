#!/usr/bin/env Rscript
library(readr)
library(dplyr)

args <- commandArgs(trailingOnly = TRUE)

transactions <- read_csv(args[1], col_types = "Dcccc")
catalogue_current_item_details <- read_csv(args[2], col_types = "ccccc_______cc______cc_c")

catalogue_items_used <- transactions %>% select(item_barcode) %>% distinct %>% left_join(catalogue_current_item_details, by = "item_barcode")

write(format_csv(catalogue_items_used), stdout())
