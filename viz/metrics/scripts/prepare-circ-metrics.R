#!/usr/bin/env Rscript

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

suppressMessages(library(tidyverse))
suppressMessages(library(lubridate))
library(yulr)

###
### Configuration
###

## Window for considering circ metrics, like circs per year.
## 5 should mean "in the last five years before this year", e.g.
## during a2017 that means a2012, a2013, a2014, a2015, a2016 and a2017
## to date.
circ_window_years <- 5

## The starting year of the circulation window.  Used below for filtering.
circ_window_ayear <- academic_year(Sys.Date()) - circ_window_years

## All these file paths should just work and don't require tweaking
metrics_data_d    <-  paste0(Sys.getenv("DASHYUL_DATA"), "/metrics/")
book_circ_histories_rds <- paste0(metrics_data_d, "book-circ-histories.rds")
book_metrics_f    <- paste0(metrics_data_d, "book-metrics.csv")
book_metrics_rds  <- paste0(metrics_data_d, "book-metrics.rds")

###
### The work
###

## The item circ history filed is prepared by another script,
## so all the necessary information is ready and waiting.

write("Reading book circ histories ...", stderr())
book_circ_histories <- readRDS(book_circ_histories_rds)

## If an item has never circed, say it circed in 0, not NA.
book_circ_histories$circ_ayear[is.na(book_circ_histories$circ_ayear)] <- "0"

## Set up a table with two columns: item_barcode and the last year
## that item circulated.  We'll paste this to another table in a moment.
item_last_circed_ayear <- book_circ_histories %>%
    group_by(Barcode) %>%
    mutate(item_last_circed_ayear = max(circ_ayear)) %>%
    distinct(Barcode, item_last_circed_ayear)

## Now count up the total circs for each item, across all years,
## then paste in the last year circed (as calculated just above).
item_circ_summary <- book_circ_histories |>
    count(Barcode,
          MMS.Record.ID,
          Call.Number,
          Item.Call.Number,
          Local.Location,
          Permanent.Physical.Location,
          Policy,
          Item.Material.Type,
          wt = circs) |>
    rename(total_circs = n) |>
    left_join(item_last_circed_ayear, by = "Barcode")

## Create the circ metrics data frame, which we'll add to. Here, for
## each control number (which could contain multiple items), in each
## location, show the number of copies, total circs, and year of last
## circ.

write("Setting up circ metrics ...", stderr())

book_metrics <- item_circ_summary %>%
    group_by(MMS.Record.ID,
             Call.Number,
             Item.Call.Number,
             Local.Location,
             Permanent.Physical.Location,
             Policy
             ) %>%
    summarise(copies = n(),
              total_circs = sum(total_circs),
              last_circed_ayear = max(item_last_circed_ayear)
              )

## Now, count total number of circs (in the circ window) for all items
## with the same control number and call number. This lets us
## distinguish multiple volumes in a set (which each have different
## call numbers, ending e.g. in v1, v2, v3) from multiple copies of
## the same edition (which all have the same call number).

call_number_circs_in_window <- book_circ_histories %>%
    filter(circ_ayear >= circ_window_ayear) %>%
    group_by(MMS.Record.ID,
             Call.Number,
             Local.Location,
             Permanent.Physical.Location,
             Policy
             ) %>%
    summarise(circs_in_window = sum(circs))

## Join the circ_metrics data frame we began with this information
## about circs in the year window.
book_metrics <- left_join(book_metrics, call_number_circs_in_window,
                          by = c("MMS.Record.ID", "Call.Number", "Local.Location",
                                 "Permanent.Physical.Location", "Policy"))

## Minor fixes so the arithmetic works.
book_metrics$circs_in_window[is.na(circ_metrics$circs_in_window)] <- "0"
book_metrics$circs_in_window <- as.integer(circ_metrics$circs_in_window)

## Calculate busy factor
write("Calculating busy factor ...", stderr())

book_metrics <- book_metrics |>
    mutate(raw_circs_per_copy = circs_in_window / copies,
           circs_per_copy = round(raw_circs_per_copy, 1),
           busy = round(raw_circs_per_copy / circ_window_years, 1)) |>
    select(-raw_circs_per_copy)

## Phew, finally, we can write it all out.
write("Writing book metrics ...", stderr())

write_csv(book_metrics, book_metrics_f)
saveRDS(book_metrics, book_metrics_rds)

write(paste("Finished: ", Sys.time()), stderr())
