#!/usr/bin/env Rscript

## Fix the A2019 mishegas where user_barcode in the logs changed to
## Passport York username, then CYIN, then back to user_barcode.

suppressMessages(library(tidyverse))
library(yulr)

ezproxy_current_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/ezproxy/current/")
files <- list.files(ezproxy_current_data_dir, pattern = "20.*-daily-users-per-platform-detailed.csv", full.names = TRUE)

ezp_annual_data_d <- paste0(Sys.getenv("DASHYUL_DATA"), "/ezproxy/annual/")

## Get all the user information from the various sources
write("Reading user information ...", stderr())

## Alma knows CYIN, user_barcode, profile and affiliation
write("  Alma user data ...", stderr())
alma_users <- read_csv(paste0(Sys.getenv("DASHYUL_DATA"), "/alma/users/user-information.csv"), col_types = "cccc")

## This file has the CYIN numbers for the 10,000-odd PPY usernames that were
## recorded for a couple of weeks in May.
write("  PPY to CYIN mapping ...", stderr())
ppy2cyin <- read_csv(paste0(Sys.getenv("DASHYUL_DATA"), "/sis/a2019-fix-ppy-cyin.csv"), col_types = "cc")

## This has all the detailed student information (from SIS)
write("  Student information ...", stderr())
student_data <- read_csv(paste0(Sys.getenv("DASHYUL_DATA"), "/sis/all-students.csv"), col_types = "ccccccc") %>%
    group_by(cyin) %>%
    slice(1) ## Students may be listed multiple times, for various reasons.  Just use the first.

## And now we get all the detailed EZProxy logs.
write("Reading detailed EZProxy logs ...", stderr())
ezp <- do.call("rbind", lapply(files,
                               function (f) {
                                   read_csv(f, col_types = "Dccccccccccc")
                               }
                               )
               ) %>%
    filter(date >= as.Date("2019-09-01"), date <= as.Date("2020-08-31"))

## Rewrite the ED students's subject1 so that instead of being grouped by teachable
## (BIOL, EN, HIST, VISA) they are all grouped into EDUC.
ezp$subject1[ezp$faculty == "ED"] <- "EDUC"

## Identify which user ID was used.
ezp <- ezp %>%
    mutate(type = case_when(grepl("^[[:digit:]]{9}$", user_barcode) ~ "cyin",
                            grepl("^[[:digit:]]{14}$", user_barcode) ~ "user_barcode",
                            grepl("^[[:alpha:]]*$", user_barcode) ~ "ppy",
                            TRUE ~ "other")) %>%
    mutate(type = if_else(user_barcode == "OCULVR", "oculvr", type)) ## Fix this special case; this is not a PPY username

## Split up into chunks that we will reassemble later.

## Early barcodes are OK, so just leave them as is.
## They are all from 2020-05-02 or before.
## All the early barcodes are OK (though after March they were
## using slightly outdated student information).
## Late barcodes are OK.  There are a few dozen of them from May (2020-05-04) until
## 12 August 2020, when the logging went back to using barcodes, and
## from then on everything worked and was using current student information.
## Before then they would have been using slightly outdated  student data,
## but everything is so confused a few minor things like this won't matter.
write("Barcodes (early or late) are OK ...", stderr())
ezp_barcodes <- ezp %>%
    filter(type == "user_barcode") %>%
    select(-type)

## There are two weeks in May with PPY usernames.
write("PPY usernames get matched with CYINs, then barcodes ...", stderr())
ezp_ppy <- ezp %>%
    filter(type == "ppy") %>%
    select(date, user_barcode, platform) %>%
    rename(ppy = user_barcode) %>%
    left_join(ppy2cyin, by = "ppy") %>% # Match up with CYINs
    filter(! is.na(cyin)) %>% # Ignore the 400-odd users with no CYIN, like musicresearch and oculvr
    left_join(alma_users, by = "cyin") %>% # Get their user_barcodes
    select(date, user_barcode, platform, cyin, profile, affiliation)  %>% # Tidy
    left_join(student_data, by = "cyin") # Merge with SIS information

## Most with CYINs can be matched with barcodes and recovered
write("CYIN entries get matched with barcodes ...", stderr())
ezp_cyin <- ezp %>%
    filter(type == "cyin") %>%
    select(date, user_barcode, platform) %>%
    rename(cyin = user_barcode) %>%
    left_join(alma_users, by = "cyin")  %>%
    left_join(student_data, by = "cyin")

## So now everything is fixed and we can paste it all together.
fixed_ezp <- bind_rows(ezp_barcodes,
                       ezp_ppy,
                       ezp_cyin) %>%
    arrange(date, user_barcode)

## Fix-ups.
write("Fixing domain and platform names ...", stderr())

## Remove ignored platforms that weren't ignored from the start
fixed_ezp <- fixed_ezp %>%
    filter(! grepl("(appdynamics.com|noodletools.com|scholarlyiq.com|silverchair.com|silverchair-cdn.com|umich.edu|analytics.scholarsportal.info|europepmc.org)", platform))

## Fix up domain names that are actually platforms.
## (These come from the updated rename-hosts-to-platform.rb).
fixed_ezp$platform[grepl("bloomsburydesignlibrary", fixed_ezp$platform)] <- "Bloomsbury Design Library"
fixed_ezp$platform[grepl("cairn-int.info", fixed_ezp$platform)]     <- "Cairn..info"
fixed_ezp$platform[grepl("clarivate", fixed_ezp$platform)]          <- "Clarivate Analytics"
fixed_ezp$platform[grepl("dramaonlinelibrary.com", fixed_ezp$platform)]  <- "Drama Online"
fixed_ezp$platform[grepl("ebsco.com", fixed_ezp$platform)]          <- "EbscoHost"
fixed_ezp$platform[grepl("ebsco.zone", fixed_ezp$platform)]         <- "EbscoHost"
fixed_ezp$platform[grepl("elgaronline", fixed_ezp$platform)]        <- "Edward Elgar"
fixed_ezp$platform[grepl("els-cdn.com", fixed_ezp$platform)]        <- "Elsevier"
fixed_ezp$platform[grepl("emerald.com", fixed_ezp$platform)]        <- "Emerald Insight"
fixed_ezp$platform[grepl("equinoxpub.com", fixed_ezp$platform)]     <- "Equinox Online"
fixed_ezp$platform[grepl("avention.com", fixed_ezp$platform)]       <- "Hoovers"
fixed_ezp$platform[grepl("onesource.com", fixed_ezp$platform)]      <- "Hoovers"
fixed_ezp$platform[grepl("ibisworld", fixed_ezp$platform)]          <- "IbisWorld"
fixed_ezp$platform[grepl("iopscience.org", fixed_ezp$platform)]     <- "Inst of Physics"
fixed_ezp$platform[grepl("lawyersdaily", fixed_ezp$platform)]       <- "Lawyer's Daily"
fixed_ezp$platform[grepl("lerobert.com", fixed_ezp$platform)]       <- "Le Robert"
fixed_ezp$platform[grepl("lexis.com", fixed_ezp$platform)]          <- "LexisNexis"
fixed_ezp$platform[grepl("nexisuni.com", fixed_ezp$platform)]       <- "LexisNexis"
fixed_ezp$platform[grepl("loebclassics.com", fixed_ezp$platform)]   <- "Loeb Classics"
fixed_ezp$platform[grepl("pressreader.com", fixed_ezp$platform)]    <- "PressReader"
fixed_ezp$platform[grepl("simplyanalytics", fixed_ezp$platform)]    <- "Simply Analytics"
fixed_ezp$platform[grepl("springernature.com", fixed_ezp$platform)] <- "Springer"
fixed_ezp$platform[grepl("springerpub.com", fixed_ezp$platform)]    <- "Springer"
fixed_ezp$platform[grepl("statcdn.com", fixed_ezp$platform)]        <- "Statista"
fixed_ezp$platform[grepl("thomsonreuters.com", fixed_ezp$platform)] <- "Thomson Reuters"
fixed_ezp$platform[grepl("utpjournals.press", fixed_ezp$platform)]  <- "U Toronto Press"
fixed_ezp$platform[grepl("wol-prod-cdn.literatumonline.com", fixed_ezp$platform)]   <- "Wiley"
fixed_ezp$platform[grepl("wolterskluwer.com", fixed_ezp$platform)]  <- "Wolters Kluwer"
fixed_ezp$platform[grepl("wkhealth.com", fixed_ezp$platform)]       <- "Wolters Kluwer"

## Dedupe and we're almost done.
fixed_ezp <- fixed_ezp %>%
    unique() %>%
    as_tibble()

## Write out annual information all together in one file..
## Don't need the -per-platform.csv (without detailed information), so just write out this one.
write("Writing out annual files ...", stderr())
write_csv(fixed_ezp, paste0(ezp_annual_data_d, "a2019-daily-users-per-platform-detailed.csv"))
saveRDS(fixed_ezp, paste0(ezp_annual_data_d, "a2019-daily-users-per-platform-detailed.rds"))
