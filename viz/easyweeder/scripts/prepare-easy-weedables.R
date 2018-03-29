#!/usr/bin/env Rscript

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

library(tidyverse)

symphony_metrics_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/metrics/")

easyweeder_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/viz/easyweeder/")

write("Reading circ metrics ...", stderr())
circ_metrics <- read_csv(paste0(symphony_metrics_data_dir, "circ-metrics.csv"))

circ_window_years <- 5

target_busy_factor <- 1

how_many_copies_should_we_have <- function(copies = NULL, circs = NULL) {
    if (circs == 0) { return(1) }
    ## Calculate a vector of all possible busy values
    ## for all possible numbers of copies, and then
    ## the first one where busy >= 0.5.  The index
    ## of that leads to the number of copies we want.
    possible_copies <- seq(copies, 1)
    possible_busy <- circs / possible_copies / circ_window_years
    possible_busy_in_range <- which(possible_busy >= target_busy_factor)
    if (length(possible_busy_in_range) > 0) {
        index_of_recommended_copies <- max(possible_busy_in_range)
        return(possible_copies[index_of_recommended_copies])
    } else {
        return(1)
    }
}

write("Calculating ...", stderr())

easy_weedable <- circ_metrics %>%
    filter(copies > 1, busy < target_busy_factor) %>%
    rowwise() %>%
    mutate(rec_copies = how_many_copies_should_we_have(copies, circs_in_window), weedable = copies - rec_copies) %>%
    select(-circs_per_copy)

write_csv(easy_weedable, paste0(easyweeder_data_dir, "easy-weedable.csv"))

write(paste("Finished: ", Sys.time()), stderr())
