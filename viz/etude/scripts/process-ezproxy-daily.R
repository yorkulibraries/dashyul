#!/usr/bin/env Rscript

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

library(tidyverse)
library(lubridate)

etude_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/viz/etude/")

ezp_source_lib_dir <- paste0(Sys.getenv("DASHYUL_HOME"), "/sources/ezproxy/lib/")

## Read in the current year's EZProxy use
## Result is data frame: ezp
source(paste0(ezp_source_lib_dir, "get-current-ezproxy-use.R"))

## Platform uses

ezp_platform_uses_file <- paste0(etude_data_dir, "ezp-platform-uses.csv")

ezp_platform_uses <- ezp %>%
    select(date, platform, user_barcode, faculty, subject1) %>%
    distinct %>%
    group_by(platform, faculty, subject1) %>%
    summarise(uses = n())
write_csv(ezp_platform_uses, ezp_platform_uses_file)

## Users per day

ezp_users_per_day_file <- paste0(etude_data_dir, "ezp-users-per-day.csv")

ezp_users_per_day <- ezp %>%
    select(date, user_barcode, faculty, subject1) %>%
    distinct %>%
    group_by(date, faculty, subject1) %>%
    summarise(users = n())
write_csv(ezp_users_per_day, ezp_users_per_day_file)

## Platforms by student year

ezp_platforms_by_student_year_file <- paste0(etude_data_dir, "ezp-platforms-by-student-year.csv")

ezp_platforms_by_student_year <- ezp %>%
    select(platform, user_barcode, faculty, subject1, degree, year) %>%
    distinct %>%
    group_by(user_barcode, faculty, subject1, degree, year) %>%
    summarise(platforms = n()) %>%
    ungroup %>%
    select(faculty, subject1, platforms, degree, year)
write_csv(ezp_platforms_by_student_year, ezp_platforms_by_student_year_file)

####
#### Scholars Portal ebook views
####

sp_ebooks_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/ebooks/scholarsportal/")

sp_student_most_viewed_ebooks_file <- paste0(etude_data_dir, "sp-most-viewed-ebooks.csv")

files <- list.files(sp_ebooks_data_dir, pattern = "sp-ebook-views-.*.csv", full.names = TRUE)

sp_student_ebook_views <- do.call("rbind", lapply(files, function (f) {read_csv(f, col_types = "Dccccccccccc")})) %>%
    filter(date >= as.Date("2017-09-01")) %>%
    filter(! is.na(faculty))

## Count of ebook views (count multiple per day as one), at least 5
sp_student_most_viewed_ebooks <- sp_student_ebook_views %>%
    select(date, ebook_id, faculty, subject1) %>%
    distinct %>%
    group_by(ebook_id, faculty, subject1) %>%
    summarise(viewed = n()) %>%
    filter(viewed >= 5)

write_csv(sp_student_most_viewed_ebooks, sp_student_most_viewed_ebooks_file)

## EZP demographics

write("Demographics ...", stderr())

ezp_demographics_file <- paste0(etude_data_dir, "ezp-demographics.csv")

ezp_demographics <- ezp %>%
    select(user_barcode, faculty, subject1, degree, year) %>%
    distinct %>%
    group_by(faculty, subject1, degree, year) %>%
    summarise(ezproxy = n())
write_csv(ezp_demographics, ezp_demographics_file)

write(paste("Finished: ", Sys.time()), stderr())
