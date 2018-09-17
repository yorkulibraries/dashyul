## The September problem:  in September we don't yet have any
## date for the current academic year, so use use last year's
## data.  That is, in Septepmber 2018, start from 2017-09-01.
start_date <- start_of_academic_year(academic_year(Sys.Date()))
if (format(Sys.Date(), "%m") == "09") {
    start_date <- start_of_academic_year(academic_year(Sys.Date()) - 1)
}

## But in later months, e.g. December, we want September--November, so
## floor the month, subtract a month, and that gives the previous
## month.
months_to_read <- format(seq(from = start_date,
                             to = floor_date(Sys.Date(), "month") - months(1),
                             by = "month"),
                         "%Y%m")

write("Reading monthly transactions ...", stderr())

all_transaction_details <- data.frame()
for (month in months_to_read) {
    write(month, stderr())
    monthly_transactions <- read_csv(paste0(symphony_transactions_data_dir, month, "-transactions.csv"), col_types = "Dcccc")
    items <- read_csv(paste0(symphony_transactions_data_dir, month, "-items.csv"), col_types = "cccccccccc")
    users <- read_csv(paste0(symphony_transactions_data_dir, month, "-users.csv"), col_types = "cccccccccc")
    monthly_transaction_details <- left_join(monthly_transactions, items, by = "item_barcode") %>%
        left_join(users, by = "user_barcode") %>%
        filter(! is.na(faculty))
    all_transaction_details <- rbind(all_transaction_details, monthly_transaction_details)
}
