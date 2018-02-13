#!/usr/bin/env Rscript

library(readr)
library(dplyr)

args <- commandArgs(trailingOnly = TRUE)

merged <- read_csv(args[1], col_types = "Dccccc")
student_information <- read_csv(args[2], col_types = "ccccccc")
detailed_platform <- left_join(merged, student_information, by = "cyin")

write_csv(detailed_platform, args[3])
