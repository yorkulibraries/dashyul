library(gtools)
library(tidyverse)
library(shiny)
library(yulr)

## TODO: Fix the hardcoding of the data directory.

## metrics_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/sources/symphony/metrics/")
metrics_data_dir <- "/dashyul/data/symphony/metrics/"

item_circ_history <- read_csv(paste0(metrics_data_dir, "item-circ-history.csv"))

item_circ_history$circ_ayear[is.na(item_circ_history$circ_ayear)] <- 0

locations = c("BRONFMAN", "FROST", "LAW", "SCOTT", "STEACIE")

current_academic_year <- academic_year(Sys.Date())

shinyServer(function(input, output, session) {

    output$home_locations <- renderUI({
        selectInput("home_location", "Home location", locations, selected = "STEACIE")
    })

    ## output$digits_low <- renderUI({
    ##     textInput("min_lc_digits", "Min LC digits", value = 0)
    ## })

    ## output$digits_high <- renderUI({
    ##     textInput("max_lc_digits", "Max LC digits", value = 10000)
    ## })

    gardener_data <- reactive({
        gardener <- item_circ_history %>%
            filter(home_location == input$home_location,
                   lc_letters == toupper(input$lc_letters),
                   lc_digits >= as.numeric(input$min_lc_digits),
                   lc_digits <= as.numeric(input$max_lc_digits),
                   circ_ayear >= as.numeric(input$min_circ_ayear),
                   circ_ayear <= as.numeric(input$max_circ_ayear),
                   ) %>%
            group_by(control_number, lc_letters, lc_digits, call_number) %>%
            summarise(copies = n(),
                      total_circs = sum(circs),
                      last_circed = max(circ_ayear)) %>%
            filter(copies >= input$num_copies[1],
                   copies <= input$num_copies[2],
                   total_circs >= as.numeric(input$min_total_circs),
                   total_circs <= as.numeric(input$max_total_circs),
                   last_circed <= (current_academic_year - as.numeric(input$not_circed_within_years))
                   ) %>%
            ungroup() %>%
            select(-lc_letters, -lc_digits)

        ## Sort by call number
        gardener[mixedorder(gardener$call_number), ]
    })

    gardener_readable <- reactive({
        gardener_data() %>%
            ## mutate(link = link_to_vufind(control_number, title_author)) %>%
            ## select link
            select(call_number, copies, total_circs, last_circed)
    })

    output$gardener_table <- renderDataTable(
        gardener_readable(), escape = FALSE
    )

    output$results_count <- renderUI({
        tags$h2(paste("Results count: ", nrow(gardener_data())))
    })

    output$readable_query <- renderText({
        paste0("Query in words: ", input$home_location, " books, ",
               input$lc_letters, " ", input$min_lc_digits, " to ", input$max_lc_digits,
               ", where we have from ", input$num_copies[1], " to ", input$num_copies[2], " copies.  Circs counted from ",
               input$min_circ_ayear, " to ", input$max_circ_ayear,
               ", filtered to show only books that have not circed in ", input$not_circed_within_years,
               " years, where the total number of circs is between ",
               input$min_total_circs, " and ", input$max_total_circs,
               ".  (Last circed in year 0 means it has never circed (data goes back to 1996); circs 'not within 0 years' means it did circ this year.)")
    })

    output$downloadData <- downloadHandler(
    filename = function() {
        paste("gardener-", input$home_location, "-", input$lc_letters, ".csv", sep = "")
    },
    content = function(file) {
        write.csv(gardener_data(), file, row.names = FALSE)
    }
  )

})