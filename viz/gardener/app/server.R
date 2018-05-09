library(gtools)
library(tidyverse)
library(shiny)
library(yulr)

## TODO: Fix the hardcoding of the data directory.

## metrics_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/sources/symphony/metrics/")
metrics_data_dir <- "/dashyul/data/symphony/metrics/"

circ_metrics <- read_csv(paste0(metrics_data_dir, "circ-metrics.csv"))

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
        gardener <- circ_metrics %>%
            filter(home_location == input$home_location,
                   lc_letters == toupper(input$lc_letters),
                   lc_digits >= as.numeric(input$lc_digit_low),
                   lc_digits <= as.numeric(input$lc_digit_high),
                   copies >= as.numeric(input$min_copies),
                   copies <= as.numeric(input$max_copies),
                   last_circed_ayear >= as.numeric(input$min_last_circed_ayear),
                   last_circed_ayear <= as.numeric(input$max_last_circed_ayear),
                   total_circs >= as.numeric(input$min_total_circs),
                   total_circs <= as.numeric(input$max_total_circs)
                   )
        ## Sort by call number
        gardener[mixedorder(gardener$call_number), ]
    })

    gardener_readable <- reactive({
        gardener_data() %>%
            ## mutate(link = link_to_vufind(control_number, title_author)) %>%
            ## select link
            select(call_number, copies, total_circs, last_circed_ayear)
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
