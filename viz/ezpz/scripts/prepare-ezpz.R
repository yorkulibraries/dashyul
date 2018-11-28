#!/usr/bin/env Rscript

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

library(tidyverse)
library(lubridate)
library(yulr)

ezp_data_d <- paste0(Sys.getenv("DASHYUL_DATA"), "/ezproxy/")

ezpz_data_d <-  paste0(Sys.getenv("DASHYUL_DATA"), "/viz/ezpz/")

daily_platform_use_csv <- paste0(ezpz_data_d, "daily-platform-use.csv")
daily_platform_use_rds <- paste0(ezpz_data_d, "daily-platform-use.rds")

write("Reading data ...", stderr())

platform_use <- readRDS(paste0(ezp_data_d, "annual/platform-use-pii.rds"))

write("Calculating ...", stderr())

daily_platform_use <- platform_use %>%
    filter(! grepl('[[:alnum:]]\\.[[:alnum:]]', platform)) %>%
    filter(ayear %in% c(2012, 2013, 2016, 2017)) %>%
    count(date, platform, ayear)

write("Writing ...", stderr())

write_csv(daily_platform_use, daily_platform_use_csv)
saveRDS(daily_platform_use, daily_platform_use_rds)

write(paste("Finished: ", Sys.time()), stderr())
