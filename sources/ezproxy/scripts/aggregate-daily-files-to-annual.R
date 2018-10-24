#!/usr/bin/env Rscript

## Aggregates a year's worth of daily EZProxy daily users files
## into annual files, suitable for analysis.
##
## Depends on all the daily files having been moved into
## DASHYUL_DATA/ezproxy/annual/A2017 (for 2017)

library(docopt)

"usage: aggregate-daily-files-to-annual.R --year <ayear>

options:
 --ayear <ayear>     Academic year to aggregate
" -> doc

opts <- docopt(doc)

suppressMessages(library(tidyverse))

library(fs)
library(tidyverse)
library(yulr)

ayear <- opts["ayear"]

ezp_annual_data_d <- paste0(Sys.getenv("DASHYUL_DATA"), "/ezproxy/annual/")
ezp_this_year_data_d <- paste0(ezp_annual_data_d, "A", ayear)

## First, aggregate the daily users per platform files.

write("Aggregating daily users per platform ...", stderr())

dupp_files <- fs::dir_ls(ezp_this_year_data_d, regexp = "daily-users-per-platform\\.csv$")

dupp <- dupp_files %>% map_dfr(read_csv, col_names=c("date", "user_barcode", "platform"), col_types="Dcc")

write_csv(dupp, paste0(ezp_annual_data_d, "a", ayear, "-daily-users-per-platform.csv"))
saveRDS(dupp, paste0(ezp_annual_data_d, "a", ayear, "-daily-users-per-platform.rds"))

## First, aggregate the *detailed* daily users per platform files.

write("Aggregating daily detailed users per platform ...", stderr())

duppd_files <- fs::dir_ls(ezp_this_year_data_d, regexp = "daily-users-per-platform-detailed\\.csv$")

duppd <- duppd_files %>% map_dfr(read_csv, col_types = "Dccccccccccc")
write_csv(duppd, paste0(ezp_annual_data_d, "a", ayear, "-daily-users-per-platform-detailed.csv"))
saveRDS(duppd, paste0(ezp_annual_data_d, "a", ayear, "-daily-users-per-platform-detailed.rds"))
