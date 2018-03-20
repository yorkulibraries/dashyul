## In e.g. December we want September--November, so floor the month, subtract a month, and that gives
## the previous month.
## TODO Update this so it rolls over nicely in October without human intervention.  Or solve the September problem somehow.
months_to_read <- format(seq(from = as.Date("2017-09-01"), to = floor_date(Sys.Date(), "month") - months(1), by = "month"), "%Y%m")

write("Reading monthly transactions ...", stderr())

current_simple_transactions <- data.frame()
for (month in months_to_read) {
    write(month, stderr())
    monthly_transactions <- read_csv(paste0(symphony_transactions_data_dir, month, "-transactions.csv"), col_types = "Dcccc")
    current_simple_transactions <- rbind(current_simple_transactions, monthly_transactions)
}

current_simple_checkouts <- current_simple_transactions %>% filter(transaction_command == "CV") %>% select(item_barcode, library)

current_ayear <- academic_year(Sys.Date())
current_simple_checkouts <- current_simple_checkouts %>% mutate(circ_ayear = current_ayear)
