library(gtools)
library(tidyverse)
library(shiny)
library(yulr)

## TODO: Fix the hardcoding of the data directory.

## metrics_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/sources/symphony/metrics/")
metrics_data_dir <- "/dashyul/data/symphony/metrics/"

item_circ_history <- read_csv(paste0(metrics_data_dir, "item-circ-history.csv"))

item_circ_history$circ_ayear[is.na(item_circ_history$circ_ayear)] <- "0"

locations = c("BRONFMAN", "FROST", "LAW", "SCOTT", "STEACIE")

current_academic_year <- academic_year(Sys.Date())

shinyServer(function(input, output, session) {

    output$home_locations <- renderUI({
        selectInput("home_location", "Home location", locations, selected = "SCOTT")
    })

    output$digits_low <- renderUI({
        textInput("lc_digit_low", "Lowest number", value = 0)
    })

    output$digits_high <- renderUI({
        textInput("lc_digit_high", "Highest number", value = 10000)
    })

    gardener_data <- reactive({
        gardener <- item_circ_history %>%
            filter(home_location == input$home_location,
                   lc_letters == toupper(input$lc_letters),
                   lc_digits >= as.numeric(input$lc_digit_low),
                   lc_digits <= as.numeric(input$lc_digit_high),
                   circ_ayear >= as.numeric(input$min_circ_ayear),
                   circ_ayear <= as.numeric(input$max_circ_ayear),
                   ) %>%
            group_by(control_number, lc_letters, lc_digits, call_number) %>%
            summarise(copies = n(),
                      total_circs = sum(circs),
                      max_circ_ayear = max(circ_ayear)) %>%
            filter(copies >= as.numeric(input$min_copies),
                   copies <= as.numeric(input$max_copies),
                   total_circs >= as.numeric(input$min_total_circs),
                   total_circs <= as.numeric(input$max_total_circs)
                   ) %>%
            select(-lc_letters, -lc_digits)

        ## Sort by call number
        gardener[mixedorder(gardener$call_number), ]
    })

    gardener_readable <- reactive({
        gardener_data() %>%
            ## mutate(link = link_to_vufind(control_number, title_author)) %>%
            ## select link
            select(call_number, copies, total_circs, max_circ_ayear)
    })

    output$gardener_table <- renderDataTable(
        gardener_readable(), escape = FALSE
    )

    output$downloadData <- downloadHandler(
    filename = function() {
        paste("gardener-", input$home_location, "-", input$lc_letters, ".csv", sep = "")
    },
    content = function(file) {
        write.csv(gardener_data(), file, row.names = FALSE)
    }
  )

})
