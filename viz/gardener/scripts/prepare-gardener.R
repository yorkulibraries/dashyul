#!/usr/bin/env Rscript

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

library(tidyverse)
library(stringr)
library(yulr)

symphony_metrics_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/metrics/")

catalogue_data_dir   <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/catalogue/")
catalogue_current_title_metadata_file <- paste0(catalogue_data_dir, "catalogue-current-title-metadata.csv")

gardener_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/viz/gardener/")

write("Reading circ history ...", stderr())
item_circ_history <- read_csv(paste0(symphony_metrics_data_dir, "item-circ-history.csv"))

write("Reading title/author ...", stderr())
catalogue_current_title_metadata <- read_csv(catalogue_current_title_metadata_file, col_types = "ccc")

easy_weedable <- easy_weedable %>%
    left_join(catalogue_current_title_metadata, by = c("control_number", "call_number")) %>%
    mutate(title_author = readable_marc245(title_author))

write_csv(easy_weedable, paste0(easyweeder_data_dir, "easy-weedable.csv"))

write(paste("Finished: ", Sys.time()), stderr())
