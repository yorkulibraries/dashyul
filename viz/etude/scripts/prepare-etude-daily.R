#!/usr/bin/env Rscript

library(tidyverse)
library(lubridate)

dashboard_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/viz/dashboard/")

####
#### EZProxy
####

ezproxy_current_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/ezproxy/current/")
files <- list.files(ezproxy_current_data_dir, pattern = "201.*-daily-users-per-platform-detailed.csv", full.names = TRUE)

write("Reading detailed EZProxy logs ...", stderr())

ezp <- do.call("rbind", lapply(files, function (f) {read_csv(f, col_types = "Dccccccccccc")})) %>% filter(date >= as.Date("2017-09-01")) %>% filter(! is.na(faculty))

## Filter out raw hostnames
ezp <- ezp %>% filter(! grepl('[[:alpha:]]\\.[[:alpha:]]', platform))

## Rewrite the ED students's subject1 so that instead of being grouped by teachable
## (BIOL, EN, HIST, VISA) they are all grouped into EDUC.
ezp$subject1[ezp$faculty == "ED"] <- "EDUC"

## Platform uses

dashboard_ezp_platform_uses_file <- paste0(dashboard_data_dir, "ezp-platform-uses.csv")

dashboard_ezp_platform_uses <- ezp %>% select(date, platform, user_barcode, faculty, subject1) %>% distinct %>% group_by(platform, faculty, subject1) %>% summarise(uses = n())
write_csv(dashboard_ezp_platform_uses, dashboard_ezp_platform_uses_file)

## Users per day

dashboard_ezp_users_per_day_file <- paste0(dashboard_data_dir, "ezp-users-per-day.csv")

dashboard_ezp_users_per_day <- ezp %>% select(date, user_barcode, faculty, subject1) %>% distinct %>% group_by(date, faculty, subject1) %>% summarise(users = n())
write_csv(dashboard_ezp_users_per_day, dashboard_ezp_users_per_day_file)

## Platforms by student year

dashboard_ezp_platforms_by_student_year_file <- paste0(dashboard_data_dir, "ezp-platforms-by-student-year.csv")

dashboard_ezp_platforms_by_student_year <- ezp %>% select(platform, user_barcode, faculty, subject1, degree, year) %>% distinct %>% group_by(user_barcode, faculty, subject1, degree, year) %>% summarise(platforms = n()) %>% ungroup %>% select(faculty, subject1, platforms, degree, year)
write_csv(dashboard_ezp_platforms_by_student_year, dashboard_ezp_platforms_by_student_year_file)

####
#### Scholars Portal ebook views
####

sp_ebooks_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/ebooks/scholarsportal/")

student_sp_ebook_views_file <- paste0(sp_ebooks_data_dir, "student-sp-ebook-views.csv")
student_sp_ebook_views <- read_csv(student_sp_ebook_views_file)

student_sp_most_viewed_ebooks_file <- paste0(dashboard_data_dir, "sp-most-viewed-ebooks.csv")

## Count of ebook views (count multiple per day as one), at least 5
student_sp_most_viewed_ebooks <- student_sp_ebook_views %>% select(date, ebook_id, faculty, subject1) %>% distinct %>% group_by(ebook_id, faculty, subject1) %>% summarise(viewed = n()) %>% filter(viewed >= 5)

write_csv(student_sp_most_viewed_ebooks, student_sp_most_viewed_ebooks_file)

####
#### Demographics
####

write("Demographics ...", stderr())

dashboard_ezp_demographics_file <- paste0(dashboard_data_dir, "ezp-demographics.csv")

dashboard_ezp_demographics <- ezp %>% select(user_barcode, faculty, subject1, degree, year) %>% distinct %>% group_by(faculty, subject1, degree, year) %>% summarise(ezproxy = n())
write_csv(dashboard_ezp_demographics, dashboard_ezp_demographics_file)
