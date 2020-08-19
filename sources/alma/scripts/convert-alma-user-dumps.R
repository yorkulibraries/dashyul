#!/usr/bin/env Rscript

## Merge two files with similar information into one.
## (Alma won't export all this in one file!)

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

###
### Libraries
###

suppressMessages(library(tidyverse))
suppressMessages(library(lubridate))
library(yulr)

###
### Data
###

affiliations <- read_csv("~/Downloads/patrons_categories.csv", col_names = c("user_barcode", "affiliation"), col_types = "cc")

profiles <- read_csv("~/Downloads/patrons_groups.csv", col_names = c("user_barcode", "cyin", "profile"), col_types = "ccc")

user_information <- affiliations %>%
    left_join(profiles, by = "user_barcode") %>%
    select(user_barcode, cyin, profile, affiliation)

cat(format_csv(user_information))

write(paste("Finished: ", Sys.time()), stderr())
