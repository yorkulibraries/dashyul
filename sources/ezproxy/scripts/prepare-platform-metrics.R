#!/usr/bin/env Rscript

## Run this annually to update EZProxy metrics for EZPZ.

## UPDATE THIS ANNUALLY
## Everything else can stay the same.
## Get the numbers from OIPA's Quick-Facts: https://oipa.info.yorku.ca/data-hub/quick-facts/
## People = students + full-time faculty + full-time librarians + contract faculty
people_per_year <- data.frame(ayear = seq(2011, 2020, 1), total = c(57781, 57848, 57352, 56210, 55709, 55563, 56797, 59144, 59295, 59369))

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

suppressMessages(library(tidyverse))
suppressMessages(library(lubridate))
suppressMessages(library(scales))
library(yulr)

ezp_annual_data_d <- paste0(Sys.getenv("DASHYUL_DATA"), "/ezproxy/annual/")

## All these file paths should just work and don't require tweaking
ezp_metrics_data_d    <-  paste0(Sys.getenv("DASHYUL_DATA"), "/ezproxy/metrics/")

platform_use_csv <- paste0(ezp_annual_data_d, "platform-use-pii.csv")
platform_use_rds <- paste0(ezp_annual_data_d, "platform-use-pii.rds")

platform_metrics_csv <- paste0(ezp_metrics_data_d, "platform-metrics.csv")
platform_metrics_rds <- paste0(ezp_metrics_data_d, "platform-metrics.rds")

write("Reading daily use per platform files ...", stderr())
dupp_files <- fs::dir_ls(ezp_annual_data_d, regexp = "daily-users-per-platform\\.csv$")
platform_use <- dupp_files %>%
    map_dfr(read_csv, col_types = "Dcc")

write("Processing the data ...", stderr())
platform_use <- platform_use %>%
    mutate(ayear = academic_year(date)) %>% ## Could use platform = as.factor(platform), but no need
    filter(ayear %in% people_per_year$ayear) %>% ## Keep out stragglers if running midyear
    mutate(user_barcode = str_replace(user_barcode, "^ID", "")) %>% ## Sometimes "ID29100..." appears as barcode; don't know why
    filter(! user_barcode %in% c("OCULVR", "-")) %>% ## Remove the OCULVR account and unknown account
    filter(! grepl("[[:alnum:]]\\.[[:alnum:]]", platform)) %>% ## Remove the raw hostnames.
    distinct()

write("Writing platform use ...", stderr())

write_csv(platform_use, platform_use_csv)
saveRDS(platform_use, platform_use_rds)

## Metrics

write("Calculating use metrics ...", stderr())

dates_known <- platform_use %>%
    select(ayear, date) %>%
    distinct() %>%
    count(ayear) %>%
    rename(dates_known = n)

users <- platform_use %>%
    select(platform, ayear, user_barcode) %>%
    distinct() %>%
    count(platform, ayear) %>%
    rename(users = n) %>%
    left_join(people_per_year, by = "ayear") %>%
    mutate(upm = round(1000 * users / total, 1)) %>%
    select(-total)

uses <- platform_use %>%
    select(platform, ayear, date) %>%
    count(platform, ayear) %>%
    rename(uses = n)

auf <- platform_use %>%
    select(platform, ayear, date) %>%
    distinct() %>%
    count(platform, ayear) %>%
    rename(calendar_days = n) %>%
    left_join(dates_known, by = "ayear") %>%
    mutate(auf = round(100 * calendar_days / dates_known, 1)) %>%
    select(ayear, platform, auf)

interest_factor <- platform_use %>%
    count(ayear, platform, user_barcode) %>%
    filter(n > 1) %>% ## Disregard users who used a platform once in a year
    select(-user_barcode) %>%
    group_by(ayear, platform) %>%
    summarise(i_f = round(mean(n), 1) - 1) ## Take away 1 so minimum is 1, not 2

platform_metrics <- users %>%
    left_join(uses, by = c("platform", "ayear")) %>%
    left_join(auf, by = c("ayear", "platform")) %>%
    left_join(interest_factor, by = c("platform", "ayear"))

## If a platform has no interest factor defined, make it 0.
## This is more meaningful and noticeable, and also makes filtering easier.
platform_metrics$i_f[is.na(platform_metrics$i_f)] <- 0

## Now the rankings, which are based on deciles.

write("Calculating rank metrics ...", stderr())

## Deciles
## ranking_labels <- c("1", "2", "3", "4", "5", "6", "7", "8", "9", "10")
## ranking_probs <- seq(0, 1, 0.1)

## Quartiles
ranking_labels <- c("1", "2", "3", "4")
ranking_probs <- seq(0, 1, 0.25)

upm_quantiles <- platform_metrics %>% group_by(ayear) %>% summarise(quantiles = list(quantile(upm, ranking_probs)))
i_f_quantiles <- platform_metrics %>% group_by(ayear) %>% summarise(quantiles = list(quantile(i_f, ranking_probs)))
auf_quantiles <- platform_metrics %>% group_by(ayear) %>% summarise(quantiles = list(quantile(auf, ranking_probs)))

determine_ranks <- function(platform_name) {
    platform_years_known <- platform_metrics %>% filter(platform == platform_name) %>% pull(ayear)

    relatives <- dplyr::tibble(platform = character(),
                               ayear = integer(),
                               upm_rank = character(),
                               i_f_rank = character(),
                               auf_rank = character())

    for (y in platform_years_known) {
        upm_rank <- platform_metrics %>%
            filter(platform == platform_name, ayear == y) %>%
            pull(upm) %>%
            cut(upm_quantiles %>% filter(ayear == y) %>% pull(quantiles) %>% unlist(),
                labels = ranking_labels)
        i_f_rank <- platform_metrics %>%
            filter(platform == platform_name, ayear == y) %>%
            pull(i_f) %>%
            cut(i_f_quantiles %>% filter(ayear == y) %>% pull(quantiles) %>% unlist(),
                labels = ranking_labels)
        auf_rank <- platform_metrics %>%
            filter(platform == platform_name, ayear == y) %>%
            pull(auf) %>%
            cut(auf_quantiles %>% filter(ayear == y) %>% pull(quantiles) %>% unlist(),
                labels = ranking_labels)
        relatives <- relatives %>%
            add_row(platform = platform_name,
                    ayear = y,
                    upm_rank = upm_rank,
                    i_f_rank = i_f_rank,
                    auf_rank = auf_rank)
    }
    return(relatives)
}

rankings <- dplyr::tibble(platform = character(),
                          ayear = integer(),
                          upm_rank = character(),
                          i_f_rank = character(),
                          auf_rank = character())

for (p in platform_metrics %>% select(platform) %>% distinct() %>% pull(platform)) {
    rankings <- rankings %>% bind_rows(determine_ranks(p))
}

rankings$upm_rank[is.na(rankings$upm_rank)] <- 0
rankings$i_f_rank[is.na(rankings$i_f_rank)] <- 0
rankings$auf_rank[is.na(rankings$auf_rank)] <- 0
rankings$upm_rank <- as.integer(rankings$upm_rank)
rankings$i_f_rank <- as.integer(rankings$i_f_rank)
rankings$auf_rank <- as.integer(rankings$auf_rank)

platform_metrics <- platform_metrics %>% left_join(rankings, by = c("platform", "ayear"))

write("Writing metrics ...", stderr())

write_csv(platform_metrics, platform_metrics_csv)
saveRDS(platform_metrics, platform_metrics_rds)

write(paste("Finished: ", Sys.time()), stderr())
