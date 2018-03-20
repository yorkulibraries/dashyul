## We want checkouts of everything that isn't an accessory, laptop, headphone, etc.
## These item types should be normalised---looks like people sometimes make up new ones.
current_checkouts <- all_transaction_details %>% filter(transaction_command == "CV")
current_checkouts <- current_checkouts %>% filter(! item_type %in% c("LAPTOP", "PHONECHAR", "SMIL-ACSRY", "ACCESSORY", "CABLEPC", "LAW-ACSRY", "IPAD"))
current_checkouts <- current_checkouts %>% filter(! grepl("(HEAD|MACBOOK|IPAD)", call_number))
current_checkouts <- current_checkouts %>% filter(! control_number %in% c("a1506037", "a2529550", "a2215511", "a3103097", "a2275708", "a1983265", "a2309305", "a2877007", "a3103097", "a3195548", "a3195552", "a3197914", "a3326615", "a3355741", "a2999756", "a1952111"))

## Not sure how this can happen, but it did with a phone charger that seemed to be removed from the catalogue.
current_checkouts <- current_checkouts %>% filter(! is.na(call_number))

## Rewrite the ED students's subject1 so that instead of being grouped by teachable
## (BIOL, EN, HIST, VISA) they are all grouped into EDUC.
current_checkouts$subject1[current_checkouts$faculty == "ED"] <- "EDUC"
