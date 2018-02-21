#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)

sp_ebook_raw_file <- args[1]
user_information_file <- args[2]
output_file <- args[3]

suppressWarnings(library(dplyr))
suppressWarnings(library(readr))

sp_ebook_raw <- read_csv(sp_ebook_raw_file, col_names = c("date", "user_barcode", "ebook_id"), col_types = "Dcc")

user_information <- read_csv(user_information_file, col_types = "cccc")

merged <- left_join(sp_ebook_raw, user_information, by = "user_barcode")

write_csv(merged, output_file)
