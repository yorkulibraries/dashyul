#!/usr/bin/env Rscript

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

## ADD NOTES

library(docopt)

"usage: extract-alma-item-details.R --id <id>

options:
 --id <id>     Report number (e.g. 12052900060005164)
" -> doc

opts <- docopt(doc)

suppressMessages(library(tidyverse))
library(fs)
library(yulr)

## Don't report on all the name repair done when reading the CSV
## files.  It just takes up space.
options(rlib_name_repair_verbosity = "quiet")

report_number <- opts["id"]

alma_items_d <- paste0(Sys.getenv("DASHYUL_DATA"), "/alma/items/")

item_files <- fs::dir_ls(alma_items_d, regexp = paste0("PHYSICAL_ITEM_", report_number))

## EXPLAIN WHY THIS IS NEEDED
shelf_call_number <- function(this, that, theother) {
    ## Call.Number always exists
    shelf <- this
    ## If Alt..call.. exists, we want to use it instead
    if (! is.na(that)) {
        shelf <- that
    }
    ## If Description exists, tack it on, in either case
    if (! is.na(theother)) {
        shelf <- (paste(shelf, theother))
    }
    return(shelf)
}

decide_received_date <- function(receiving, creation) {
    if (! is.na(receiving)) {
        return(as.Date(receiving, format = "%a %b %d %T UTC %Y"))
    } else {
        return(as.Date(creation))
    }
}

write("Reading and processing CSV files (this takes a while) ...", stderr())

items <- item_files |>
    map_dfr(read_csv, name_repair = "universal", col_types = list(.default = col_character())) |>
    ## There are some bad rows in the CSV export that mess up the parsing,
    ## so skip any where the date doesn't start YYYY-MM-DD.  There are under 8,000 of these as of mid-2022.
    filter(grepl("^[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}", Creation.date)) |>
    mutate(MMS.Record.ID = gsub("'", "", MMS.Record.ID), ## Don't know why it's '123' and not just 123
           Item.PID = gsub("'", "", Item.PID),
           Barcode = gsub("'", "", Barcode)
    ) |>
    rowwise() |>
    mutate(Received.Date = decide_received_date(Receiving.date, Creation.date),
           Shelf.Call.Number = shelf_call_number(Call.Number, Alt..call.., Description)
           ) |>
    select(MMS.Record.ID,
           Item.PID,
           Barcode,
           Local.Location,
           Permanent.Physical.Location,
           Policy,
           Item.Material.Type,
           Bib.Material.Type,
           Received.Date,
           Call.Number,
           Alt..call..,
           Description,
           Shelf.Call.Number,
           Copy.ID,
           Title,
           Creator)

write("Writing ...", stderr())
write_csv(items, paste0(alma_items_d, "items-", report_number, ".csv"))
saveRDS(items, paste0(alma_items_d, "items-", report_number, ".rds"))

## From the old item information:

## puts %w[item_barcode control_number call_number lc_letters lc_digits copy
##         last_activity_date date_last_charged date_inventoried
##         times_inventoried number_of_pieces current_location
##         home_location library total_charges item_extended_info
##         price inhouse_charges circulate_flag permanence_flag item_type
##         acq_date vol_part class_scheme].to_csv

## All information in the Alma dump:

## MMS Record ID, HOL Record ID, Item PID, Barcode, Title,
## Publisher, Bib Material Type, Creator, Call Number, Permanent Call Number,
## Permanent Physical Location, Local Location, Holding Type, Item Material Type, Policy,
## Seq. Number, Chronology, Enumeration, Issue year, Description,
## Public note, Fulfillment note, Inventory  #, Inventory date, Shelf report #,
## On shelf date, On shelf seq, Last shelf report, Temp library, Temp location, Temp call # type,
## Temp call #, Temp item policy, Alt. call # type, Alt. call #, Pieces,
## Pages, Internal note (1), Internal note (2), Internal note (3),
## Statistics note (1), Statistics note (2), Statistics note (3),
## Creation date, Modification date, Status, Process type, Process Id, Number of loans,
## Last loan, Number of loans in house, Last loan in house, Year-to-date Loans,
## Receiving date, Copy ID, Receiving number, Weeding number, Weeding date, Other System Number
