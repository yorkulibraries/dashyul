#!/usr/bin/env Rscript

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

## Generate a list of titles of things that the Gardener will report
## on. It's helpful to prepare this smaller list in advance because it
## means we don't have to deal with the huge long list of all titles
## of everything in our collection, which includes a lot of
## non-circulating stuff as well as circulating material that we don't
## track here (phone chargers, DVDs, etc.).

suppressPackageStartupMessages(library(tidyverse))
library(yulr)

symph_metrics_data_d <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/metrics/")
cat_data_d           <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/catalogue/")
gardener_data_d      <- paste0(Sys.getenv("DASHYUL_DATA"), "/viz/gardener/")

write("Reading item circ history ...", stderr())
item_circ_history <- readRDS(paste0(symph_metrics_data_d, "item-circ-history.rds"))

write("Reading title metadata ...", stderr())
cat_current_title_metadata <- readRDS(paste0(cat_data_d, "catalogue-current-title-metadata.rds"))

gardener_titles <- cat_current_title_metadata %>%
    filter(control_number %in% item_circ_history$control_number) %>%
    mutate(title_author = readable_marc245(title_author)) %>%
    select(control_number, title_author)

write("Writing title/author ...", stderr())
write_csv(gardener_titles, paste0(gardener_data_d, "gardener-titles.csv"))
saveRDS(gardener_titles, paste0(gardener_data_d, "gardener-titles.rds"))

write(paste("Finished: ", Sys.time()), stderr())
