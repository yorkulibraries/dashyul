#!/usr/bin/env Rscript

## A2019 is a special year: in late December 2019 we switched systems
## from Symphony to Alma.  Therefore special work is required to
## merge transaction data from the two source into one single
## file with the whole year's data.  The main complexity is that
## open circs were carried over from Symphony to Alma and we don't
## want to count some borrows twice.

write("------", stderr())
write(paste("Started: ", Sys.time()), stderr())

suppressMessages(library(tidyverse))
library(yulr)

## Start with the Symphony data.

write("Calculating Symphony circs ...", stderr())

symphony_circs_a2019 <- readRDS(paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/transactions/symphony-transactions-a2019.rds"))

## There are four kinds of transactions recorded. We only care about
## checkouts and returns.

## > symphony_circs_a2019 |> count(transaction_command)
## A tibble: 4 × 2
## transaction_command     n
## <chr>               <int>
## 1 CV                  68423  ## Checkout
## 2 EV                  60771  ## Return
## 3 JZ                   7207  ## Create hold
## 4 RV                  41887  ## Renew

## Here is the tricky bit.
##
## If something was checked out in October and returned in November,
## all of the data about both transactions is in Symphony.
##
## But if something was borrowed in November and returned in January,
## it is in both Symphony and Alma.  In Symphony there is a checkout,
## and in Alma there is a checkout (because the data was migrated) and
## a return.
##
## Such items we want to exclude from the Symphony data.  We'll
## see them in the Alma data.
##
## Finding these items is done by matching checkouts and returns and
## seeing what's left over.  There are probably several different ways
## to do this, and undoubtedly some are better than what I do here,
## but it works.
##
## First, count up how many times each item was checked out and
## returned.

checkouts <- symphony_circs_a2019 |> filter(transaction_command == "CV") |> count(item_barcode, name = "out")
returns   <- symphony_circs_a2019 |> filter(transaction_command == "EV") |> count(item_barcode, name = "back")

## Now we'll figure out which items weren't returned to Symphony. We
## do this by counting checkouts and returns and calculating the
## difference.
##
##  1:  more checkouts than returns, so was returned to Alma
##  0:  every checkout in Symphony was returned in Symphony
## -1:  more returns than checkouts, so first checkout was in A2018
##
## We're only interested when the difference is 1. Everything else is
## properly counted in just the Symphony data, either for the first
## part of A2019 or for A2018.

checked_out_not_returned <- left_join(checkouts, returns, by = "item_barcode") |>
    mutate(back = replace_na(back, 0)) |>
    mutate(diff = out - back) |>
    filter(diff > 0) |>
    pull(item_barcode)

## > length(checked_out_not_returned)
## [1] 17719

## So we have about 18,000 items that were checked out from Symphony
## and returned to Alma.  Here is how to look at samples to see
## this happening.

## > symphony_circs_a2019 |>
##     filter(transaction_command %in% c("CV", "EV"), item_barcode %in% sample(checked_out_not_returned, 5)) |>
##     select(date, transaction_command, item_barcode) |>
##     arrange(item_barcode) |>
##     print(n = Inf)
##  # A tibble: 11 × 3
##    date       transaction_command item_barcode
##    <date>     <chr>               <chr>
##  1 2019-12-09 CV                  39007051429660
##  2 2019-12-02 CV                  39007053066049
##  3 2019-10-30 CV                  39007053353082
##  4 2019-11-29 CV                  39007053874376
##  5 2019-10-13 CV                  39007054399308
##  6 2019-10-15 EV                  39007054399308
##  7 2019-10-17 CV                  39007054399308
##  8 2019-10-24 EV                  39007054399308
##  9 2019-11-04 CV                  39007054399308
## 10 2019-11-05 EV                  39007054399308
## 11 2019-11-06 CV                  39007054399308

## That last item was checked out and returned a few times, then
## borrowed on 06 November but not returned to Symphony.
##
## Now, this list is items where the *last Symphony checkout* was
## returned to Alma. But they may have been borrowed and returned to
## Symphony before then, and we don't want to lose those.

## We'll handle this by separating the Symphony data into two sets.
##
## First, items where all the borrowing and returning happened in
## Symphony.  None of these were checked out in Symphony and returned
## to Alma.

last_returned_to_symphony <- symphony_circs_a2019 |>
    filter(! item_barcode %in% checked_out_not_returned, transaction_command == "CV")

## Next, items that were checked out in Symphony and returned to Alma.
## The group_by and slice arrange the circs by item_barcode checkouts
## and drop the last one (which will show up in the Alma data).

last_returned_to_alma <- symphony_circs_a2019 |>
    filter(item_barcode %in% checked_out_not_returned, transaction_command == "CV") |>
    group_by(item_barcode) |>
    slice(1:n() - 1)

## Put the two sets together, and rename columns to go with the Alma
## data.

symphony_checkouts_a2019 <- bind_rows(last_returned_to_symphony, last_returned_to_alma) |>
    select(-transaction_command, -library) |>
    rename(Barcode = item_barcode,
           Primary.Identifier = user_barcode,
           Loan.Date = date) |>
    mutate(Return.Date = NA,
           Loan.Status = "Complete")


## Now we flesh this out with item-level information.  We want to make this match
## the Alma transactions information.

write("Adding item details ...", stderr())

alma_items_d <- paste0(Sys.getenv("DASHYUL_DATA"), "/alma/items/")
items <- readRDS(paste0(alma_items_d, "items-12052900060005164.rds"))

symphony_almaish_2019 <- left_join(symphony_checkouts_a2019, items, by = "Barcode") |>
    rename(Item.Id = Item.PID)

write("Adding user types ...", stderr())

alma_users_d <- paste0(Sys.getenv("DASHYUL_DATA"), "/alma/users/")
alma_users_f <- paste0(alma_users_d, "user-information-20200829.csv")

user_groups <- read_csv(alma_users_f, col_types = "cccc") |>
    rename(User.Group = profile,
           Primary.Identifier = user_barcode) |>
    select(Primary.Identifier, User.Group)

symphony_almaish_2019 <- left_join(symphony_almaish_2019, user_groups, by = "Primary.Identifier") |>
    select(MMS.Record.ID,
           Loan.Status,
           Item.Id,
           Call.Number,
           Loan.Date,
           Return.Date,
           Title,
           Barcode,
           User.Group,
           Primary.Identifier) |>
    mutate(Loan.Date = as.Date(Loan.Date),
           Return.Date = as.Date(Return.Date),
           User.Id = NA,
           User.Type = NA)

## Whew!  Finally this is done and it looks like the Alma transaction information.

## Now we get the Alma data ...

write("Getting Alma data ...", stderr())

alma_trans_d <- paste0(Sys.getenv("DASHYUL_DATA"), "/alma/transactions/")

alma_2019 <- readRDS(paste0(alma_trans_d, "transactions-20200830.rds"))

## ... then merge it all and write it out.

write("Combining ...", stderr())

combined_2019 <- bind_rows(symphony_almaish_2019, alma_2019) |>
    arrange(Loan.Date, desc(MMS.Record.ID))

write("Writing ...", stderr())

write_csv(combined_2019, paste0(alma_trans_d, "transactions-combined-a2019.csv"))
saveRDS(combined_2019, paste0(alma_trans_d, "transactions-combined-a2019.rds"))

write(paste("Finished: ", Sys.time()), stderr())
