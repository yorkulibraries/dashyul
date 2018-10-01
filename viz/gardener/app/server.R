library(gtools)
library(tidyverse)
library(shiny)
library(yulr)

## TODO: Fix the hardcoding of the data directory.

## metrics_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/symphony/metrics/")
metrics_data_d <- "/dashyul/data/symphony/metrics/"

item_circ_history <- readRDS(paste0(metrics_data_d, "item-circ-history.rds")) %>% tbl_df()
item_circ_history$circ_ayear[is.na(item_circ_history$circ_ayear)] <- 0

## record_min_acq_year <- read_csv(paste0(metrics_data_dir, "record-min-acquisition-year.csv"))
record_min_acq_year <- readRDS(paste0(metrics_data_d, "record-min-acquisition-year.rds")) %>% tbl_df()

## gardener_data_dir <- paste0(Sys.getenv("DASHYUL_DATA"), "/viz/gardener/")
gardener_data_d <- "/dashyul/data/viz/gardener/"

gardener_titles <- readRDS(paste0(gardener_data_d, "gardener-titles.rds")) %>% tbl_df()

locations <- c("BRONFMAN", "FROST", "LAW", "SCOTT", "STEACIE")

current_academic_year <- academic_year(Sys.Date())

shinyServer(function(input, output, session) {

    output$home_locations <- renderUI({
        selectInput("home_location", "Home location", locations, selected = "SCOTT")
    })

    gardener_data <- reactive({
        ## First, get all the items in the right location
        ## that are in the right LC range.
        all_items_in_range <- item_circ_history %>%
            filter(home_location == input$home_location,
                   lc_letters == toupper(input$lc_letters),
                   lc_digits >= as.numeric(input$min_lc_digits),
                   lc_digits <= as.numeric(input$max_lc_digits))

        ## Make a list of all of the control_numbers that have
        ## circed ONLY before or in the deadline year.
        ## I.e., if we say "Last circ was in or before" 2005,
        ## then filter to only control_numbers where the last circ
        ## year was 2005 or less.
        uncirced_after_deadline <- all_items_in_range %>%
            group_by(control_number) %>%
            mutate(last_circed = max(circ_ayear)) %>%
            distinct(control_number, last_circed) %>%
            filter(last_circed <= input$last_circed_in_or_before)

        gardener <- all_items_in_range %>%
            ## Filter all the items we have to just ones where the
            ## most recent circ is before the deadline year.
            filter(control_number %in% uncirced_after_deadline$control_number) %>%
            ## Filter to items where the record's minimum acq year
            ## is before the deadline (so this could include items
            ## acquired after the deadline, if other items part of
            ## the same record were acquired before it).
            left_join(record_min_acq_year) %>%
            filter(min_acq_ayear <= input$acquired_in_or_before) %>%
            ## And now filter all that to shows just the circs in the
            ## given range
            ## filter(circ_ayear >= as.numeric(input$min_circ_ayear),
            ##        circ_ayear <= as.numeric(input$max_circ_ayear)) %>%
            group_by(control_number, lc_letters, lc_digits, call_number) %>%
            summarise(copies = n(),
                      total_circs = sum(circs),
                      last_circed = max(circ_ayear)) %>%
            filter(copies >= input$num_copies[1],
                   copies <= input$num_copies[2],
                   total_circs >= as.numeric(input$min_total_circs),
                   total_circs <= as.numeric(input$max_total_circs)) %>%
            ungroup() %>%
            select(-lc_letters, -lc_digits)

        ## Sort by call number
        gardener[mixedorder(gardener$call_number), ]
    })

    gardener_readable <- reactive({
        gardener_data() %>%
            select(control_number, call_number, copies, total_circs, last_circed) %>%
            left_join(gardener_titles, by = "control_number")
    })

    output$gardener_table <- renderDataTable(
        gardener_readable() %>%
        mutate(link = link_to_vufind(control_number, title_author)) %>%
        select(link, call_number, copies, total_circs, last_circed), escape = FALSE
    )

    output$results_count <- renderUI({
        tags$h2(paste("Results count: ", nrow(gardener_data())))
    })

    output$readable_query <- renderText({
        paste0("Query in words: ", input$home_location, " books, ",
               input$lc_letters, " ", input$min_lc_digits, " to ", input$max_lc_digits,
               ", filtered to include only books that last circed in or before ", input$last_circed_in_or_before,
               ", that were acquired in or before ", input$acquired_in_or_before,
               ", where we have from ", input$num_copies[1], " to ", input$num_copies[2],
               " copies, ",
               ## "Circ data goes from ",
               ## input$min_circ_ayear, " to ", input$max_circ_ayear,
               "where the total number of circs is from ",
               input$min_total_circs, " to ", input$max_total_circs, ".")
    })

    output$downloadData <- downloadHandler(
    filename = function() {
        paste("gardener-", input$home_location, "-", input$lc_letters, ".csv", sep = "")
    },
    content = function(file) {
        write.csv(gardener_readable(), file, row.names = FALSE)
    }
  )

})
