#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)

ezproxy_weekly_file <- args[1]
user_information_file <- args[2]
output_file <- args[3]

suppressWarnings(library(dplyr))
suppressWarnings(library(readr))

ezproxy_weekly <- read_csv(ezproxy_weekly_file, col_names = c("date", "user_barcode", "platform"), col_types = "Dcc")

user_information <- read_csv(user_information_file, col_types = "cccc")

merged <- left_join(ezproxy_weekly, user_information, by = "user_barcode")

write_csv(merged, output_file)
