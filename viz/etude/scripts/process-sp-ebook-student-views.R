#!/usr/bin/env Rscript

## Merge all current detailed CSV files into one and then pick out just the student views, suitable for Étude.

## DELETE THIS FILE WHEN I KNOW I DON'T NEED IT

library(tidyverse)

sp_ebooks_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/ebooks/scholarsportal/")
etude_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/viz/etude/")

sp_student_ebook_views_file <- paste0(etude_data_dir, "sp-student-ebook-views.csv")

files <- list.files(sp_ebooks_data_dir, pattern = "sp-ebook-views-.*.csv", full.names = TRUE)

sp_student_ebook_views <- do.call("rbind", lapply(files, function (f) {read_csv(f, col_types = "Dccccccccccc")})) %>% filter(date >= as.Date("2017-09-01")) %>% filter(! is.na(faculty))

write_csv(sp_student_ebook_views, sp_student_ebook_views_file)
