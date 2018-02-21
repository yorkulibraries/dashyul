#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)

merged_file <- args[1]
student_information_file <- args[2]
output_file <- args[3]

suppressWarnings(library(dplyr))
suppressWarnings(library(readr))

merged <- read_csv(merged_file, col_types = "Dccccc")

student_information <- read_csv(student_information_file, , col_types = "ccccccc")

detailed_platform <- left_join(merged, student_information, by = "cyin")

write_csv(detailed_platform, output_file)
