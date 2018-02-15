#!/usr/bin/env Rscript

library(readr)
library(dplyr)

args <- commandArgs(trailingOnly = TRUE)

transactions <- read_csv(args[1], col_types = "Dcccc")
all_user_information <- read_csv(args[2], col_types = "cccc")

tmp_user_details <- transactions %>% select(user_barcode) %>% distinct %>% left_join(all_user_information, by = "user_barcode")

write(format_csv(tmp_user_details), stdout())
