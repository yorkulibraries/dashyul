#!/usr/bin/env Rscript

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

library(tidyverse)

dashboard_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/viz/dashboard/")

platform_metrics_file <- paste0(dashboard_data_dir, "ezp-platform-metrics.csv")
ezp_daily_users_file  <- paste0(dashboard_data_dir, "ezp-daily-users.csv")

ezp_source_lib_dir <- paste0(Sys.getenv("DASHYUL_HOME"), "/sources/ezproxy/lib/")

## Read in the current year's EZProxy use
## Result is data frame: ezp
source(paste0(ezp_source_lib_dir, "get-current-ezproxy-use.R"))

## EZP platform metrics
ezp_users <- ezp %>% select(platform, user_barcode) %>% distinct %>% group_by(platform) %>% summarise(users = n())
ezp_uses  <- ezp %>% select(platform, date) %>% group_by(platform) %>% summarise(uses = n())

platform_metrics <- ezp_users %>% left_join(ezp_uses, by = c("platform")) %>% mutate(interest_factor = round(uses / users, 1))

write_csv(platform_metrics, platform_metrics_file)

## EZP daily users
ezp_daily_users <- ezp %>% select(date, user_barcode) %>% distinct %>% group_by(date) %>% summarise(users = n())
write_csv(ezp_daily_users, ezp_daily_users_file)

write(paste("Finished: ", Sys.time()), stderr())
