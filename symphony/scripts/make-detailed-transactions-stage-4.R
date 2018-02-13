#!/usr/bin/env Rscript
library(readr)
library(dplyr)

args <- commandArgs(trailingOnly = TRUE)

tmp_user_information <- read_csv(args[1], col_types = "cccc")
sis_information <- read_csv(args[2])

user_details <- left_join(tmp_user_information, sis_information, by = "cyin")

write(format_csv(user_details), stdout())
