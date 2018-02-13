#!/usr/bin/env Rscript
library(readr)
library(dplyr)

args <- commandArgs(trailingOnly = TRUE)

catalogue_items_used <- read_csv(args[1], col_types = "cccccccccc")
catalogue_title_metadata <- read_csv(args[2], col_types = "ccc")

catalogue_records_used <- catalogue_items_used %>% select(control_number) %>% distinct %>% left_join(catalogue_title_metadata, by = "control_number")

write(format_csv(catalogue_records_used), stdout())
