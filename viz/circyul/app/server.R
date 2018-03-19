library(tidyverse)
library(scales)
library(shiny)
library(lubridate)
library(yulr)

## TODO: Fix the hardcoding of the data directory.

## circyul_data_dir <- paste0(Sys.getenv("DASHYUL_DATA"), "/viz/circyul/")
circyul_data_dir <- "/dashyul/data/viz/circyul/"
circyul_checkouts_file         <- paste0(circyul_data_dir, "checkouts.csv.gz")
circulated_item_details_file   <- paste0(circyul_data_dir, "circulated_item_details.csv.gz")
circulated_title_metadata_file <- paste0(circyul_data_dir, "circulated_title_metadata.csv.gz")

circyul_checkouts         <- read_csv(circyul_checkouts_file, col_types = "Dcc")
circulated_item_details   <- read_csv(circulated_item_details_file, col_types = "ccccccccDc")
circulated_title_metadata <- read_csv(circulated_title_metadata_file, col_types = "ccc")

shinyServer(function(input, output, session) {

    record_control_number <- reactive({
        record_control_number <- gsub(".*/", "", input$raw_control_number)
        ## Need a leading a to get Sirsi control number, so paste if needed
        if (substr(record_control_number, 0, 1) != "a") {
            record_control_number <- paste0("a", record_control_number)
        }
        record_control_number
    })

    record_item_history <- reactive({
        items <- circulated_item_details %>% filter(control_number == record_control_number())
        circyul_checkouts %>% filter(item_barcode %in% items$item_barcode) %>% select(date, item_barcode) %>% mutate(date = as.Date(date))
    })

    output$title_information <- renderText({
        record_metadata <- circulated_title_metadata %>% filter(control_number == record_control_number())
        readable_marc245(record_metadata$title_author)
    })

    output$circ_history_plot <- renderPlot({
        checkouts_by_ayear <- record_item_history() %>% mutate(ayear = academic_year_as_year(date)) ## %>% count(ayear)
        ## ggplot(checkouts_by_ayear, aes(x = ayear, y = n)) + geom_col() + labs(title = paste("Checkouts"), x = "Academic year", y = "") + scale_x_date(date_labels = "%Y")
        ggplot(checkouts_by_ayear, aes(x = ayear)) + geom_bar(width = 300) + labs(title = paste("Circs per academic year"), x = "", y = "") + scale_y_continuous(breaks = pretty_breaks())
    })

    output$item_history_table <- renderTable({
        item_circ_summary <- record_item_history() %>% count(item_barcode)
        item_details <- circulated_item_details %>% filter(item_barcode %in% item_circ_summary$item_barcode) %>% select(item_barcode, item_type, acq_date)
        last_circs <- record_item_history() %>% group_by(item_barcode) %>% mutate(last_circ = max(date)) %>% select(item_barcode, last_circ) %>% distinct
        item_history_table <- merge(item_circ_summary, item_details) %>% merge(last_circs) %>% mutate(acq_date = as.character(acq_date), last_circ = as.character(last_circ))
        ## print(item_history_table)
        item_history_table
    })

})
