#!/usr/bin/env Rscript

## Merge all weekly detailed CSV files into one and then pick out just the student views, suitable for Étude.

library(dplyr)
library(readr)

data_path <- "/data/ezproxy/ebooks/data/"

files <- list.files(data_path, pattern = "sp-ebook-views-.*.csv", full.names = TRUE)
student_views <- do.call("rbind", lapply(files, function (f) {read_csv(f, col_types = "Dccccccccccc")})) %>% filter(date >= as.Date("2017-09-01")) %>% filter(! is.na(faculty))

write_csv(student_views, paste0(data_path, "student-sp-ebook-views.csv"))
