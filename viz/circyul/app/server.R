library(tidyverse)
library(scales)
library(shiny)
library(lubridate)
library(yulr)

## TODO: Fix the hardcoding of the data directory.

## circyul_data_dir <- paste0(Sys.getenv("DASHYUL_DATA"), "/viz/circyul/")
circyul_data_d <- "/dashyul/data/viz/circyul/"
circyul_checkouts         <- readRDS(paste0(circyul_data_d, "checkouts.rds"))
circulated_item_details   <- readRDS(paste0(circyul_data_d, "circulated_item_details.rds"))
circulated_title_metadata <- readRDS(paste0(circyul_data_d, "circulated_title_metadata.rds"))

## Some items have never circulated, which causes an error when the
## circ history chart is being made. This line creates an empty tibble
## that has all the right column headings with the right formats,
## which we'll use when we set up record_item_history, below.
empty_record_item_history <- circulated_item_details %>%
    filter(control_number == "DOES NOT EXIST")

shinyServer(function(input, output, session) {

    record_control_number <- reactive({
        ## It's OK to paste in a VuFind URL
        ## e.g. https://www.library.yorku.ca/find/Record/2184579
        ## where then everything up to the last / is stripped
        record_control_number <- gsub(".*/", "", input$raw_control_number_or_barcode)
        ## It's also OK to paste in an item barcode, in which case we need to
        ## look up the control number.
        if (substr(record_control_number, 0, 4) == "3900") {
            record_control_number <- circulated_item_details %>%
                filter(item_barcode == record_control_number) %>%
                pull(control_number)
            ## If there's no data about it we get character(0),
            ## which will fail, but an empty string works.
            ## I know this is not neat, but it works.
            if (length(record_control_number) == 0) {
                record_control_number <- ""
            }
        }
        ## Need a leading a to get Sirsi control number, so paste if needed
        if (substr(record_control_number, 0, 1) != "a") {
            record_control_number <- paste0("a", record_control_number)
        }
        record_control_number
    })

    record_item_history <- reactive({
        items <- circulated_item_details %>%
            filter(control_number == record_control_number())
        ## Now force the tibble to look right, by matching it up with
        ## an empty tibble.  If this tibble is empty, the circ history
        ## chart be empty, but it will still work.
        items <- full_join(items, empty_record_item_history)
        circyul_checkouts %>%
            filter(item_barcode %in% items$item_barcode) %>%
            select(date, item_barcode) %>%
            mutate(date = as.Date(date))
    })

    title_author <- reactive({
        record_metadata <- circulated_title_metadata %>%
            filter(control_number == record_control_number())
        readable_marc245(record_metadata$title_author)
    })

    output$title_information <- renderText({
        title_author()
    })

    output$circ_history_plot <- renderPlot({
        checkouts_by_ayear <- record_item_history() %>%
            mutate(ayear = academic_year(date))
        ggplot(checkouts_by_ayear, aes(x = ayear)) +
            geom_bar(width = 0.8) +
            labs(title = paste("Circ history:", title_author()), x = "Academic year", y = "") +
            scale_y_continuous(breaks = pretty_breaks()) +
            scale_x_continuous(breaks = pretty_breaks())
    })

    output$item_history_table <- renderTable({
        item_circ_summary <- record_item_history() %>%
            count(item_barcode)
        item_details <- circulated_item_details %>%
            filter(item_barcode %in% item_circ_summary$item_barcode) %>%
            select(item_barcode, item_type, acq_date)
        last_circs <- record_item_history() %>%
            group_by(item_barcode) %>%
            mutate(last_circ = max(date)) %>%
            select(item_barcode, last_circ) %>%
            distinct()
        item_history_table <- merge(item_circ_summary, item_details) %>%
            merge(last_circs) %>%
            mutate(acq_date = as.character(acq_date), last_circ = as.character(last_circ))
        item_history_table
    })

    output$total_circ_count <- renderUI({
        tags$p(paste("Total circs in time range: ", nrow(record_item_history())))
    })


})
