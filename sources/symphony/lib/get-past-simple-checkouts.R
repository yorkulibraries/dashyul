## Read in Symphony transactions from 2000 onwards. It will end with
## the previous academic year.

write("Reading annual transactions ...", stderr())

## First, grab the complete years.
files <- list.files(symphony_transactions_data_dir,
                    pattern = "symphony-transactions-a[[:digit:]]{4}.csv.gz$",
                    full.names = TRUE)
## files <- list.files(symphony_transactions_data_dir, pattern = "symphony-transactions-a201[[:digit:]].csv.gz$", full.names = TRUE)

past_simple_checkouts <- do.call("rbind", lapply(files, read_csv, col_types = "Dcccc")) %>%
    filter(transaction_command == "CV") %>%
    mutate(circ_ayear = academic_year(date)) %>%
    select(item_barcode, library, circ_ayear)
