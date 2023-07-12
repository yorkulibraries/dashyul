#!/usr/bin/env Rscript

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

suppressMessages(library(tidyverse))
library(gtools)
library(yulr)

metrics_data_d <-  paste0(Sys.getenv("DASHYUL_DATA"), "/metrics/")

alma_items_current_f <- paste0(Sys.getenv("DASHYUL_DATA"), "/alma/items/items-current.rds")

## cat_data_d   <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/catalogue/")
## cat_current_title_metadata_f <- paste0(cat_data_d, "catalogue-current-title-metadata.csv")

easyweeder_data_d <-  paste0(Sys.getenv("DASHYUL_DATA"), "/viz/easyweeder/")

write("Reading book metrics ...", stderr())
book_metrics <- readRDS(paste0(metrics_data_d, "book-metrics.rds"))

## Use the minimum acquisition year to filter out any recent purchases.
## We'll ignore any titles where the min acq year is within circ_window_years + 1
## of the current academic year.
## Thus if we have two copies of a book we got three years ago, and neither has circed,
## we'll still keep both.
write("Reading min acquisitions year ...", stderr())
record_min_acq_year <- readRDS(paste0(metrics_data_d, "record-min-acquisition-year.rds"))

circ_window_years <- 5

target_busy_factor <- 1

this_academic_year <- academic_year(Sys.Date())

how_many_copies_should_we_have <- function(copies = NULL,
                                           circs = NULL,
                                           circ_window_years = 5,
                                           target_busy_factor = 1) {
    if (circs == 0) {
        return(1)
    }
    ## Calculate a vector of all possible busy values
    ## for all possible numbers of copies, and then
    ## the first one where busy >= 0.5.  The index
    ## of that leads to the number of copies we want.
    possible_copies <- seq(copies, 1)
    possible_busy <- circs / possible_copies / circ_window_years
    possible_busy_in_range <- which(possible_busy >= target_busy_factor)
    if (length(possible_busy_in_range) > 0) {
        index_of_recommended_copies <- min(possible_busy_in_range)
        return(possible_copies[index_of_recommended_copies])
    } else {
        return(1)
    }
}

write("Calculating ...", stderr())

easy_weedable <- book_metrics |>
    left_join(record_min_acq_year, by = "MMS.Record.ID") |>
    filter(min_acq_ayear <= this_academic_year - (circ_window_years + 1)) %>%
    filter(copies > 1, busy < target_busy_factor) %>%
    rowwise() %>%
    mutate(rec_copies = how_many_copies_should_we_have(copies, circs_in_window, circ_window_years, target_busy_factor),
           weedable = copies - rec_copies) %>%
    select(-circs_per_copy)

## Sort by call numbers so it's neat and orderly and we
## don't have to do it in every subsequent script.
## gtools::mixedorder sorts LC call numbers perfectly.
easy_weedable <- easy_weedable[mixedorder(easy_weedable$Shelf.Call.Number), ]

## TODO Fix this so it's just a join and then select.

write("Adding title/author ...", stderr())
alma_title_author <- readRDS(alma_items_current_f) |>
    select(MMS.Record.ID, Shelf.Call.Number, Title, Creator, Local.Location, Permanent.Physical.Location, Policy) |>
    distinct()

easy_weedable <- easy_weedable |>
    left_join(alma_title_author,
              by = c("MMS.Record.ID", "Shelf.Call.Number", "Local.Location", "Permanent.Physical.Location", "Policy"))

write_csv(easy_weedable, paste0(easyweeder_data_d, "easy-weedable.csv"))
saveRDS(easy_weedable |> ungroup(), paste0(easyweeder_data_d, "easy-weedable.rds"))

write(paste("Finished: ", Sys.time()), stderr())
