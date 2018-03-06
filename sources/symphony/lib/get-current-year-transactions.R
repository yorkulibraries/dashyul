## In e.g. December we want September--November, so floor the month, subtract a month, and that gives
## the previous month.
## TODO Update this so it rolls over nicely in October without human intervention.  Or solve the September problem somehow.
months_to_read <- format(seq(from = as.Date("2017-09-01"), to = floor_date(Sys.Date(), "month") - months(1), by = "month"), "%Y%m")

write("Reading monthly transactions ...", stderr())

all_transaction_details <- data.frame()
for (month in months_to_read) {
    write(month, stderr())
    monthly_transactions <- read_csv(paste0(symphony_transactions_data_dir, month, "-transactions.csv"), col_types = "Dcccc")
    items <- read_csv(paste0(symphony_transactions_data_dir, month, "-items.csv"), col_types = "cccccccccc")
    users <- read_csv(paste0(symphony_transactions_data_dir, month, "-users.csv"), col_types = "cccccccccc")
    monthly_transaction_details <- left_join(monthly_transactions, items, by = "item_barcode") %>% left_join(users, by = "user_barcode") %>% filter(! is.na(faculty))
    all_transaction_details <- rbind(all_transaction_details, monthly_transaction_details)
}
