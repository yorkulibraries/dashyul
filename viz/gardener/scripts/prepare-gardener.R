#!/usr/bin/env Rscript

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

library(tidyverse)
library(stringr)
library(yulr)

symphony_metrics_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/metrics/")
catalogue_data_dir   <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/catalogue/")
gardener_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/viz/gardener/")

write("Reading item circ history ...", stderr())
item_circ_history <- readRDS(paste0(symphony_metrics_data_dir, "item-circ-history.rds"))

write("Reading title metadata ...", stderr())
catalogue_current_title_metadata <- readRDS(paste0(catalogue_data_dir, "catalogue-current-title-metadata.rds"))

gardener_titles <- catalogue_current_title_metadata %>%
    filter(control_number %in% item_circ_history$control_number) %>%
    mutate(title_author = readable_marc245(title_author)) %>%
    select(control_number, title_author)

write("Writing title/author ...", stderr())
write_csv(gardener_titles, paste0(gardener_data_dir, "gardener-titles.csv"))
saveRDS(gardener_titles, paste0(gardener_data_dir, "gardener-titles.rds"))

write(paste("Finished: ", Sys.time()), stderr())
