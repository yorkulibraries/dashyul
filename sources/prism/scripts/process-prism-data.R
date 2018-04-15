#!/usr/bin/env Rscript

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

library(tidyverse)
library(readxl)
library(yulr)

## Default to the current academic year unless one is specified
args <- commandArgs(trailingOnly = TRUE)
current_ayear <- args[1]
if (length(args) == 0) {
    current_ayear <- academic_year(Sys.Date())
    write(paste("Using year:", current_ayear), stderr())
}

prism_data_dir <- paste0(Sys.getenv("DASHYUL_DATA"), "/prism/")

raw_prism_data_file <- paste0(prism_data_dir, "prism-data-raw-a", current_ayear, ".xlsx")
prism_data_file <- paste0(prism_data_dir, "prism-data-a", current_ayear, ".csv")

prism_raw <- read_excel(raw_prism_data_file,
                       col_names = c("title", "author",
                                     "isbn", "course",
                                     "comment", "retail_cost",
                                     "ed", "coursename",
                                     "retail_used_cost", "binding",
                                     "request_type", "cr_enrolment_act",
                                     "cr_enrolment_est","term_name"),
                       skip = 1
                 )

## Set up the map from the bookstore's term names to ours.
term_names_map <- data.frame(store_term = c("A", "B", "F", "G"), term = c("W", "S", "F", "Y"))

## Map short codes for faculties to readable names.
faculty_names_map <- data.frame(faculty = c("AP", "CB",
                                           "CS", "ED",
                                           "ES", "FA",
                                           "GL", "GS",
                                           "HH", "LE",
                                           "LW", "SB",
                                           "SC"),
                               faculty_name = c("LA&PS", "??",
                                                "Continuing Studies", "Education",
                                                "Environmental Studies", "AMPD",
                                                "Glendon", "Graduate Studies",
                                                "Health", "Lassonde",
                                                "Osgoode", "Schulich",
                                                "Science"))

prism <- prism_raw %>%
    filter(! grepl("NO TEXTBOOK|CANCELLED COURSE", title, ignore.case = TRUE)) %>%
    filter(! is.na(title)) %>%
    select(-coursename) %>%
    separate(course, c("course.1", "coursename", "section"), "/") %>%
    separate(course.1, c("faculty", "program"), "-") %>%
    separate(term_name, c("ayear", "store_term", "campus"), c(4, 5, 7)) %>%
    left_join(term_names_map, by = "store_term") %>%
    rename(enrol_act = cr_enrolment_act, enrol_est = cr_enrolment_est)

## Using mutate to do this doesn't work.  Can't see why.
prism$stitle <- strtrim(prism$title, 40)

## Shorten request_type
prism <- prism %>% rename(rtype = request_type)
prism$rtype = as.factor(prism$rtype)
levels(prism$rtype) <- list("Opt" = "Optional", "Rec" = "Recommended", "Req" = "Required")

## Need to turn the store calendar year into academic year.  Winter and summer terms mean
## we need to use the previous year.
prism$ayear <- as.numeric(prism$ayear)
prism$ayear <- ifelse(prism$term == "W", (prism$ayear - 1), prism$ayear)
prism$ayear <- ifelse(prism$term == "S", (prism$ayear - 1), prism$ayear)

## What level (year) is the course?
prism$courselevel <- substr(str_extract(prism$coursename, "[[:digit:]]+"), 0, 1)

## Tidy and save
prism <- prism %>% select(ayear, term,
                         campus, faculty,
                         program, coursename,
                         courselevel, section,
                         enrol_act, enrol_est,
                         rtype, stitle,
                         ed, author,
                         isbn, binding,
                         retail_cost, retail_used_cost,
                         title)

write("Writing cleaned Prism data ...", stderr())
write_csv(prism, prism_data_file)

write(paste("Finished: ", Sys.time()), stderr())
