#!/usr/bin/env Rscript

## Merge all weekly detailed CSV files into one.

library(readr)

data_path <- "/data/ezproxy/weekly/data"
files <- list.files(data_path, pattern = "20.*detailed.csv", full.names = TRUE)
m <- do.call("rbind", lapply(files, read.csv))

write_csv(m, paste0(data_path, "/data/ezproxy/weekly/data/all-daily-users-per-platform-detailed.csv"))
