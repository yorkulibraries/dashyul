#!/usr/bin/env Rscript

library(tidyverse)
library(lubridate)
library(yulr)

ezproxy_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/ezproxy/annual/")
ezpz_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/viz/ezpz/")

ezpz_platform_use_file <- paste0(ezpz_data_dir, "ezpz-platform-use.csv")
ezpz_platform_metrics_file <- paste0(ezpz_data_dir, "ezpz-platform-metrics.csv")

write("Reading transaction logs ...", stderr())

files <- list.files(ezproxy_data_dir, pattern = "^a201[23456].*daily-users-per-platform.csv.gz$", full.names = TRUE)
daily_per_platform <- do.call("rbind", lapply(files, read_csv, col_names = c("date", "user_barcode", "platform"), col_types = "Dcc"))

write("Analyzing ...", stderr())

daily_per_platform$ayear <- academic_year(daily_per_platform$date)
daily_per_platform$platform <- as.factor(daily_per_platform$platform)

## Remove the special OCULVR account.
daily_per_platform <- daily_per_platform %>% filter(user_barcode != "OCULVR")

## Drop all raw hostnames.
## # This matches foo.com and baz.foo.com, but not Cairn..info, which
## is why any platform name with an actual period in it is "escaped"
## to two periods.
daily_per_platform <- daily_per_platform %>% filter(! grepl('[[:alnum:]]\\.[[:alnum:]]', platform))

dates_known <- daily_per_platform %>% select(ayear, date) %>% distinct %>% group_by(ayear) %>% summarise(dates_known = n())

write("Calculating metrics ...", stderr())

users          <- daily_per_platform %>% select(platform, ayear, user_barcode) %>% distinct %>% group_by(platform, ayear) %>% summarise(users = n())
uses           <- daily_per_platform %>% select(platform, ayear, date)                      %>% group_by(platform, ayear) %>% summarise(uses = n())
calendar_days  <- daily_per_platform %>% select(platform, ayear, date)         %>% distinct %>% group_by(platform, ayear) %>% summarise(calendar_days = n())

platform_metrics <- users %>% left_join(uses, by = c("platform", "ayear")) %>% left_join(calendar_days, by = c("platform", "ayear"))
platform_metrics <- platform_metrics %>% left_join(dates_known) %>% mutate(auf = round(100 * calendar_days / dates_known), interest_factor = round(uses / users, 1))

write("Writing ...", stderr())
write_csv(daily_per_platform, ezpz_platform_use_file)
write_csv(platform_metrics, ezpz_platform_metrics_file)
