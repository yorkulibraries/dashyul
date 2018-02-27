#!/usr/bin/env Rscript

## Merge all current detailed CSV files into one and then pick out just the student views, suitable for Étude.

library(tidyverse)

sp_ebooks_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/ebooks/scholarsportal/")

student_sp_ebook_views_file <- paste0(sp_ebooks_data_dir, "student-sp-ebook-views.csv")

files <- list.files(sp_ebooks_data_dir, pattern = "sp-ebook-views-.*.csv", full.names = TRUE)

student_sp_ebook_views <- do.call("rbind", lapply(files, function (f) {read_csv(f, col_types = "Dccccccccccc")})) %>% filter(date >= as.Date("2017-09-01")) %>% filter(! is.na(faculty))

write_csv(student_sp_ebook_views, student_sp_ebook_views_file)
