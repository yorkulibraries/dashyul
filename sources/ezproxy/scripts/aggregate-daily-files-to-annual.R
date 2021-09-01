#!/usr/bin/env Rscript

## Aggregates a year's worth of daily EZProxy daily users files
## into annual files, suitable for analysis.
##
## Depends on all the daily files having been moved into e.g.
## DASHYUL_DATA/ezproxy/annual/A2020/ (for 2020)

library(docopt)

"usage: aggregate-daily-files-to-annual.R --ayear <ayear>

options:
 --ayear <ayear>     Academic year to aggregate
" -> doc

opts <- docopt(doc)

suppressMessages(library(tidyverse))
library(fs)
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
dupp$platform[grep("apa.org", dupp$platform)] <- "APA"
dupp$platform[grep("acf-film.com", dupp$platform)] <- "Audio Ciné Films"
dupp$platform[grep("bloomsburycollections", dupp$platform)] <- "Bloomsbury Collections"
dupp$platform[grep("chronicle.com", dupp$platform)] <- "Chronicle of Higher Education"
dupp$platform[grep("dapresy", dupp$platform)] <- "Dapresy"
dupp$platform[grep("dramaonlinelibrary", dupp$platform)] <- "Drama Online"
dupp$platform[grep("docuseek2", dupp$platform)] <- "Docuseek"
dupp$platform[grep("r2library.com", dupp$platform)] <- "R2 Digital Library"
dupp$platform[grep("scitation", dupp$platform)] <- "Scitation"
dupp$platform[grep("veryshortintroductions", dupp$platform)] <- "Very Short Introductions"

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
duppd$platform[grep("apa.org", duppd$platform)] <- "APA"
duppd$platform[grep("acf-film.com", duppd$platform)] <- "Audio Ciné Films"
duppd$platform[grep("bloomsburycollections", duppd$platform)] <- "Bloomsbury Collections"
duppd$platform[grep("chronicle.com", duppd$platform)] <- "Chronicle of Higher Education"
duppd$platform[grep("dapresy", duppd$platform)] <- "Dapresy"
duppd$platform[grep("dramaonlinelibrary", duppd$platform)] <- "Drama Online"
duppd$platform[grep("docuseek2", duppd$platform)] <- "Docuseek"
duppd$platform[grep("r2library.com", duppd$platform)] <- "R2 Digital Library"
duppd$platform[grep("scitation", duppd$platform)] <- "Scitation"
duppd$platform[grep("veryshortintroductions", duppd$platform)] <- "Very Short Introductions"

duppd <- duppd %>% unique()

write_csv(duppd, paste0(ezp_annual_data_d, "a", ayear, "-daily-users-per-platform-detailed.csv"))
saveRDS(duppd, paste0(ezp_annual_data_d, "a", ayear, "-daily-users-per-platform-detailed.rds"))
