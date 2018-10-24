#!/usr/bin/env Rscript

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

suppressMessages(library(tidyverse))
suppressMessages(library(lubridate))
suppressMessages(library(scales))

library(tidyverse)
library(lubridate)
library(scales)
library(yulr)

ezp_annual_data_d <- paste0(Sys.getenv("DASHYUL_DATA"), "/ezproxy/annual/")

## All these file paths should just work and don't require tweaking
ezp_metrics_data_d    <-  paste0(Sys.getenv("DASHYUL_DATA"), "/ezproxy/metrics/")

platform_use_csv <- paste0(ezp_metrics_data_d, "platform-use-pii.csv")
platform_use_rds <- paste0(ezp_metrics_data_d, "platform-use-pii.rds")

platform_metrics_csv <- paste0(ezp_metrics_data_d, "platform-metrics.csv")
platform_metrics_rds <- paste0(ezp_metrics_data_d, "platform-metrics.rds")

write("Reading daily use per platform files ...", stderr())
dupp_files <- fs::dir_ls(ezp_annual_data_d, regexp = "daily-users-per-platform\\.csv$")
platform_use <- dupp_files %>%
    map_dfr(read_csv, col_types = "Dcc")

write("Processing the data ...", stderr())
platform_use <- platform_use %>%
    mutate(ayear = academic_year(date), platform = as.factor(platform)) %>%
    filter(! user_barcode %in% c("OCULVR", "-")) %>% ## Remove the OCULVR account and unknown account
    filter(! grepl("[[:alnum:]]\\.[[:alnum:]]", platform)) ## Remove the raw hostnames.

write("Writing platform use ...", stderr())

write_csv(platform_use, platform_use_csv)
saveRDS(platform_use, platform_use_rds)

## Metrics

dates_known <- platform_use %>% select(ayear, date) %>% distinct() %>% count(ayear) %>% rename(dates_known = n)

write("Calculating metrics ...", stderr())

users          <- platform_use %>% select(platform, ayear, user_barcode) %>% distinct %>% count(platform, ayear) %>% rename(users = n)
uses           <- platform_use %>% select(platform, ayear, date)                      %>% count(platform, ayear) %>% rename(uses = n)
calendar_days  <- platform_use %>% select(platform, ayear, date)         %>% distinct %>% count(platform, ayear) %>% rename(calendar_days = n)

platform_metrics <- users %>%
    left_join(uses, by = c("platform", "ayear")) %>%
    left_join(calendar_days, by = c("platform", "ayear")) %>%
    left_join(dates_known, by = "ayear") %>%
    mutate(auf = round(100 * calendar_days / dates_known),
           interest_factor = round(uses / users, 1)
           )

write("Writing metrics ...", stderr())

write_csv(platform_metrics, platform_metrics_csv)
saveRDS(platform_metrics, platform_metrics_rds)

write(paste("Finished: ", Sys.time()), stderr())
