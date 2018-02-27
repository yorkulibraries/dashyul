#!/usr/bin/env Rscript

## Add up the total number of OJS downloads for the current year.

## TODO: Filter to just this current academic year.

library(dplyr)
library(readr)

files <- list.files("../data/ojs", pattern = "ojs-downloads.*csv", full.names = TRUE)

write("Reading OJS stats ...", stderr())

ojs_downloads <- do.call("rbind", lapply(files, function (f) {read_csv(f, col_names = TRUE, col_types = "cci")})) %>% filter(month != "Month")

ojs_downloads_total <- sum(ojs_downloads$downloads)

cat(ojs_downloads_total, file = stdout())
