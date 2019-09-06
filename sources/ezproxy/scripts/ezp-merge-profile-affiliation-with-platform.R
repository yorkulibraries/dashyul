#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(tidyverse))

args <- commandArgs(trailingOnly = TRUE)

ezproxy_file <- args[1]
user_information_file <- args[2]
output_file <- args[3]

ezproxy <- read_csv(ezproxy_file, col_names = c("date", "user_barcode", "platform"), col_types = "Dcc")

user_information <- read_csv(user_information_file, col_types = "cccc")

merged <- left_join(ezproxy, user_information, by = "user_barcode")

write_csv(merged, output_file)
