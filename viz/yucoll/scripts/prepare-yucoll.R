#!/usr/bin/env Rscript

library(readr)
library(dplyr)
library(lubridate)
library(yulr)

yucoll_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/viz/yucoll/")
yucoll_data_file <- paste0(yucoll_data_dir, "yucoll-data.csv")

transaction_data_dir <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/transactions/")
catalogue_data_dir   <- paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/catalogue/")

catalogue_current_item_details_file <- paste0(catalogue_data_dir, "catalogue-current-item-details.csv")

## First, read in transaction logs.

write("Reading transaction logs ...", stderr())

files <- list.files(transaction_data_dir, pattern = "symphony-transactions-a20[[:digit:]]{2}.csv.gz$", full.names = TRUE)
## files <- list.files(transaction_data_dir, pattern = "symphony-transactions-a(200[6789]|201[0123456]).csv.gz$", full.names = TRUE)

checkouts <- do.call("rbind", lapply(files, read_csv, col_types = "Dcccc")) %>%
filter(transaction_command == "CV") %>%
mutate(circ_ayear = academic_year(date)) %>%
select(item_barcode, library, circ_ayear)

## Next, all item details from the catalogue.

write("Reading item details ...", stderr())

## Trim down all the holdings to just things that can circulate.  There's no point dealing
## with all of the periodicals and microfiche and such.

items <- read_csv(catalogue_current_item_details_file, col_types = "")
items <- items %>% filter(class_scheme == "LC")
items <- items %>% mutate(acq_ayear = academic_year(acq_date)) %>% filter(acq_ayear >= 2000, acq_ayear <= 2016)
items <- items %>% select(item_barcode, control_number, lc_letters, lc_digits, home_location, item_type, acq_ayear)
items <- items %>% filter(home_location %in% c("SCOTT", "SCOTT-LEIS", "STEACIE", "FROST", "BRONFMAN", "SCOTT-MAPS", "LAW"))
items <- items %>% filter(item_type %in% c("SCOTT-BOOK", "STEAC-BOOK", "FROST-BOOK", "BRONF-BOOK", "SCORE", "MAP", "SCMAP-BOOK", "LAW-BOOK"))

## Do not count things currently on reserve, e.g. SCOTT-RESV, STEAC-RESV and BRONF-RESV.

## outliers_bar_codes <- c("39007049736515", "39007045555463", "39007049765860", "39007049765852")
## acquisitions_and_circs_since_2005 %>% filter(item_barcode %in% outliers_bar_codes)

## Join items with checkouts: the left join means that all the items are there, and any checkout information is added.
## There will be duplicate rows, because some items have been checked out multiple times, but we don't care how many
## times they've been checked out, just whether or not they have. We want things broken by by location and item_type,
## and within that lc_letters and lc_digits, so group by those and acq_ayear, and for each of those count up the number
## of items that have ever circed and those that never have.

write("Merging and calculating ...", stderr())

yucoll_data <- left_join(items, checkouts) %>% mutate(has_circed = ! is.na(circ_ayear)) %>% distinct(item_barcode, lc_letters, lc_digits, acq_ayear, home_location, item_type, has_circed) %>% group_by(lc_letters, lc_digits, acq_ayear, home_location, item_type) %>% mutate(total = n(), circed = sum(has_circed), uncirced = total - circed) %>% ungroup %>% select(acq_ayear, lc_letters, lc_digits, home_location, item_type, circed, uncirced) %>% distinct

write_csv(yucoll_data, yucoll_data_file)
