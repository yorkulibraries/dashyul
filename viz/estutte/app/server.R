library(dplyr)
library(readr)
library(shiny)

## prism_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/viz/estutte/")
prism_data_dir <- "/dashyul/data/prism/"

## estutte_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/viz/estutte/")
estutte_data_dir <- "/dashyul/data/viz/estutte/"

prism <- read_csv(paste0(prism_data_dir, "prism-a2017.csv"))
prism_item_circs <- read_csv(paste0(estutte_data_dir, "prism-item-circs-a2017.csv"), col_types = "ci")
prism_item_details <- read_csv(paste0(estutte_data_dir, "prism-item-details-a2017.csv"), col_types = "ccccc_______cc______cc_c")
prism_isbn_item_map <- read_csv(paste0(estutte_data_dir, "prism-isbn-item-a2017.csv"), col_types = "cc")

generate_buying_list <- function(min_student_threshold,
                                students_per_textbook,
                                textbook_holdings_limit,
                                max_courselevel,
                                min_price_threshold) {
    ## This shows how many students need each ISBN, filtering by the above constraints
    students_per_isbn <- prism %>%
        filter(rtype == "Req",
               ! binding == "WEB ACCESS CODE",
               courselevel <= max_courselevel,
               retail_cost >= min_price_threshold) %>%
        group_by(term, stitle, binding, isbn) %>%
        summarise(students = sum(enrol_act)) %>%
        group_by(stitle, isbn, term) %>%
        summarise(term_students = sum(students)) %>%
        group_by(stitle, isbn) %>%
        mutate(max_students = max(term_students)) %>%
        select(stitle, isbn, max_students) %>% distinct %>%
        filter(max_students >= min_student_threshold)

    costs <- textbooks %>% select(stitle, isbn, retail_cost) %>% distinct

    buying_list <- students_per_isbn %>%
        inner_join(costs) %>%
        mutate(required = min(floor((max_students + 10) / students_per_textbook), textbook_holdings_limit))

    isbns_and_items <- students_per_isbn %>%
        ungroup() %>%
        select(isbn) %>%
        left_join(textbook_isbn_item_map, by = "isbn") %>%
        left_join(textbook_item_circs, by = "item_barcode")

    isbns_owned_with_circs <- isbns_and_items %>%
        inner_join(textbook_item_details, by = "item_barcode") %>%
        group_by(isbn) %>%
        summarise(owned = n(), total_circs = sum(circs, na.rm = TRUE))

    buying_list <- buying_list %>% left_join(isbns_owned_with_circs, by = "isbn") %>% rename(circs = total_circs)
    buying_list$owned[is.na(buying_list$owned)] <- 0
    buying_list$circs[is.na(buying_list$circs)] <- ""
    buying_list <- buying_list %>% mutate(buy = max(required - owned, 0), cost = retail_cost * buy)

    ## Reorder for readability
    buying_list %>% select(stitle, isbn, max_students, circs, required, owned, buy, retail_cost, cost)
}

shinyServer(function(input, output, session) {

    buying_list <- reactive({
        generate_buying_list(min_student_threshold = as.integer(input$min_student_threshold),
                             students_per_textbook = as.integer(input$students_per_textbook),
                             textbook_holdings_limit = as.integer(input$textbook_holdings_limit),
                             max_courselevel = as.integer(input$max_courselevel),
                             min_price_threshold = as.integer(input$min_price_threshold))
    })

    output$buying_list_table <- renderTable({
        buying_list()
    })

    output$buying_list_cost <- renderText ({
        sum(buying_list()$cost)
    })

})
