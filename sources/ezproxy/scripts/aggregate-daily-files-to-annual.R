#!/usr/bin/env Rscript

## Aggregates a year's worth of daily EZProxy daily users files
## into annual files, suitable for analysis.
##
## Depends on all the daily files having been moved into
## DASHYUL_DATA/ezproxy/annual/A2017 (for 2017)

library(docopt)

"usage: aggregate-daily-files-to-annual.R --ayear <ayear>

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

## Correct raw hostnames that didn't get transformed into platform names
## and then remove any resulting duplicates
## Replace and update each year as necessary
dupp$platform[dupp$platform == "yorku.kanopy.com"]          <- "Kanopy"
dupp$platform[dupp$platform == "www.kanopy.com"]            <- "Kanopy"
dupp$platform[dupp$platform == "www.taylorfrancis.com"]     <- "T & F Online"
dupp$platform[dupp$platform == "wwww.taylorandfrancis.com"] <- "T & F Online"
dupp$platform[dupp$platform == "www.fulcrum.org"]           <- "Fulcrum"
dupp$platform[dupp$platform == "www.statista.com"]          <- "Statista"
dupp$platform[dupp$platform == "lexisadvancequicklaw.ca"]   <- "Lexis Advance Quicklaw"
dupp$platform[dupp$platform == "www.criterionondemand.com"] <- "Criterion on Demand"
dupp$platform[dupp$platform == "filmplatform.net"]          <- "Film Platform"
dupp <- dupp %>% unique()

write_csv(dupp, paste0(ezp_annual_data_d, "a", ayear, "-daily-users-per-platform.csv"))
saveRDS(dupp, paste0(ezp_annual_data_d, "a", ayear, "-daily-users-per-platform.rds"))

## First, aggregate the *detailed* daily users per platform files.

write("Aggregating daily detailed users per platform ...", stderr())

duppd_files <- fs::dir_ls(ezp_this_year_data_d, regexp = "daily-users-per-platform-detailed\\.csv$")

duppd <- duppd_files %>% map_dfr(read_csv, col_types = "Dccccccccccc")

## Correct raw hostnames that didn't get transformed into platform names
## and then remove any resulting duplicates
## (Duplicate of above, but different data frame.)
## Replace and update each year as necessary
duppd$platform[duppd$platform == "yorku.kanopy.com"]          <- "Kanopy"
duppd$platform[duppd$platform == "www.kanopy.com"]            <- "Kanopy"
duppd$platform[duppd$platform == "www.taylorfrancis.com"]     <- "T & F Online"
duppd$platform[duppd$platform == "wwww.taylorandfrancis.com"] <- "T & F Online"
duppd$platform[duppd$platform == "www.fulcrum.org"]           <- "Fulcrum"
duppd$platform[duppd$platform == "www.statista.com"]          <- "Statista"
duppd$platform[duppd$platform == "lexisadvancequicklaw.ca"]   <- "Lexis Advance Quicklaw"
duppd$platform[duppd$platform == "www.criterionondemand.com"] <- "Criterion on Demand"
duppd$platform[duppd$platform == "filmplatform.net"]          <- "Film Platform"
duppd <- duppd %>% unique()

write_csv(duppd, paste0(ezp_annual_data_d, "a", ayear, "-daily-users-per-platform-detailed.csv"))
saveRDS(duppd, paste0(ezp_annual_data_d, "a", ayear, "-daily-users-per-platform-detailed.rds"))
