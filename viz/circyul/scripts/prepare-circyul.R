#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(tidyverse))

trans_data_d <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/transactions/")
cat_data_d   <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/catalogue/")
cat_item_details_rds <- paste0(cat_data_d, "catalogue-current-item-details.rds")
cat_title_metadata_rds <- paste0(cat_data_d, "catalogue-current-title-metadata.rds")

circyul_data_d <- paste0(Sys.getenv("DASHYUL_DATA"), "/viz/circyul/")

## Append appropriate suffix when saving.
circyul_checkouts_f <- paste0(circyul_data_d, "checkouts")
circulated_item_details_f <- paste0(circyul_data_d, "circulated_item_details")
circulated_title_metadata_f <- paste0(circyul_data_d, "circulated_title_metadata")

write("Reading checkouts ...", stderr())
checkouts <- readRDS(paste0(trans_data_d, "simple-checkouts-all.rds"))

write("Reading item details ...", stderr())
item_details <- readRDS(cat_item_details_rds) %>%
    filter(library == "YORK") %>%
    filter(class_scheme == "LC") %>%
    filter(home_location %in% c("BRONFMAN",
                                "FROST",
                                "SCOTT",
                                "SCOTT-MAPS",
                                "STEACIE"
                                )
           ) %>%
    filter(item_type %in% c("BRONF-BOOK",
                            "FROST-BOOK",
                            "MAP", "SCMAP-BOOK",
                            "SCORE",
                            "SCOTT-BOOK", "SCOTT-RESV",
                            "STEAC-BOOK", "STEAC-RESV"
                            )
           ) %>%
    select(item_barcode, control_number, call_number,
           lc_letters, lc_digits,
           home_location, library, item_type,
           acq_date, class_scheme)

circulated_item_details <- item_details %>%
    filter(item_barcode %in% checkouts$item_barcode)

write("Reading title_metadata ...", stderr())
title_metadata <- readRDS(cat_title_metadata_rds)

circulated_title_metadata <- title_metadata %>%
    filter(control_number %in% circulated_item_details$control_number)

write("Writing out ...", stderr())

write_csv(checkouts, paste0(circyul_checkouts_f, ".csv"))
saveRDS(checkouts,   paste0(circyul_checkouts_f, ".rds"))

write_csv(circulated_item_details, paste0(circulated_item_details_f, ".csv"))
saveRDS(circulated_item_details,   paste0(circulated_item_details_f, ".rds"))

write_csv(circulated_title_metadata, paste0(circulated_title_metadata_f, ".csv"))
saveRDS(circulated_title_metadata,   paste0(circulated_title_metadata_f, ".rds"))
