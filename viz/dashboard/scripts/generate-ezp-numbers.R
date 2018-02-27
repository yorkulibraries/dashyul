#!/usr/bin/env Rscript

library(tidyverse)

dashboard_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/viz/dashboard/")

dashboard_platform_metrics_file <- paste0(dashboard_data_dir, "ezp-platform-metrics.csv")
dashboard_ezp_daily_users_file  <- paste0(dashboard_data_dir, "ezp-daily-users.csv")

ezproxy_current_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/ezproxy/current/")
files <- list.files(ezproxy_current_data_dir, pattern = "201.*-daily-users-per-platform-detailed.csv", full.names = TRUE)

ezp <- do.call("rbind", lapply(files, function (f) {read_csv(f, col_types = "Dccccccccccc")})) %>% filter(date >= as.Date("2017-09-01")) %>% filter(! is.na(faculty))

## Filter out raw hostnames
ezp <- ezp %>% filter(! grepl('[[:alpha:]]\\.[[:alpha:]]', platform))

## EZP platform metrics
ezp_users <- ezp %>% select(platform, user_barcode) %>% distinct %>% group_by(platform) %>% summarise(users = n())
ezp_uses  <- ezp %>% select(platform, date) %>% group_by(platform) %>% summarise(uses = n())

dashboard_platform_metrics <- ezp_users %>% left_join(ezp_uses, by = c("platform")) %>% mutate(interest_factor = round(uses / users, 1))

write_csv(dashboard_platform_metrics, dashboard_platform_metrics_file)

## EZP daily users
dashboard_ezp_daily_users <- ezp %>% select(date, user_barcode) %>% distinct %>% group_by(date) %>% summarise(users = n())
write_csv(dashboard_ezp_daily_users, dashboard_ezp_daily_users_file)
