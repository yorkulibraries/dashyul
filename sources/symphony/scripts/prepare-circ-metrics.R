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
metrics_data_d    <-  paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/metrics/")
item_circ_history_rds <- paste0(metrics_data_d, "item-circ-history.rds")
circ_metrics_f    <- paste0(metrics_data_d, "circ-metrics.csv")
circ_metrics_rds  <- paste0(metrics_data_d, "circ-metrics.rds")

###
### The work
###

## The item circ history filed is prepared by another script,
## so all the necessary information is ready and waiting.

write("Reading item circ history ...", stderr())
item_circ_history <- readRDS(item_circ_history_rds)

## If an item has never circed, say it circed in 0, not NA.
item_circ_history$circ_ayear[is.na(item_circ_history$circ_ayear)] <- "0"

## Set up a table with two columns: item_barcode and the last year
## that item circulated.  We'll paste this to another table in a moment.
item_last_circed_ayear <- item_circ_history %>%
    group_by(item_barcode) %>%
    mutate(item_last_circed_ayear = max(circ_ayear)) %>%
    distinct(item_barcode, item_last_circed_ayear)

## Now count up the total circs for each item, across all years,
## then paste in the last year circed (as calculated just above).
item_circ_summary <- item_circ_history %>%
    count(item_barcode,
          control_number,
          lc_letters,
          lc_digits,
          call_number,
          home_location,
          wt = circs) %>%
    rename(total_circs = n) %>%
    left_join(item_last_circed_ayear, by = "item_barcode")

## Create the circ metrics data frame, which we'll add to. Here, for
## each control number (which could contain multiple items), in each
## location, show the number of copies, total circs, and year of last
## circ.

write("Setting up circ metrics ...", stderr())

circ_metrics <- item_circ_summary %>%
       group_by(control_number,
                lc_letters,
                lc_digits,
                call_number,
                home_location
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

call_number_circs_in_window <- item_circ_history %>%
    filter(circ_ayear >= circ_window_ayear) %>%
    group_by(control_number,
             call_number,
             home_location
             ) %>%
    summarise(circs_in_window = sum(circs))

## Join the circ_metrics data frame we began with this information
## about circs in the year window.
circ_metrics <- left_join(circ_metrics, call_number_circs_in_window,
                          by = c("control_number", "call_number", "home_location"))

## Minor fixes so the arithmetic works.
circ_metrics$circs_in_window[is.na(circ_metrics$circs_in_window)] <- "0"
circ_metrics$circs_in_window <- as.integer(circ_metrics$circs_in_window)

## Calculate busy factor
write("Calculating busy factor ...", stderr())

circ_metrics <- circ_metrics %>%
    mutate(raw_circs_per_copy = circs_in_window / copies,
           circs_per_copy = round(raw_circs_per_copy, 1),
           busy = round(raw_circs_per_copy / circ_window_years, 1)) %>%
    select(-raw_circs_per_copy)

## Phew, finally, we can write it all out.
write("Writing circ metrics ...", stderr())

write_csv(circ_metrics, circ_metrics_f)
saveRDS(circ_metrics %>% ungroup(), circ_metrics_rds)

write(paste("Finished: ", Sys.time()), stderr())
