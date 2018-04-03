library(tidyverse)
library(shiny)
library(yulr)

## TODO: Fix the hardcoding of the data directory.

## ezweeder_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/viz/ezweeder/")
ezweeder_data_dir <- "/dashyul/data/viz/easyweeder/"

easy_weedable <- read_csv(paste0(ezweeder_data_dir, "easy-weedable.csv"))

locations = c("BRONFMAN", "FROST", "LAW", "SCOTT", "STEACIE")

shinyServer(function(input, output, session) {

    output$home_locations <- renderUI({
        selectInput("home_location", "Home location", locations, selected = "SCOTT")
    })

    weedable_data <- reactive({
        easy_weedable %>%
            filter(home_location == input$home_location,
                   lc_letters == toupper(input$lc_letters))
    })

    weedable_readable <- reactive({
        weedable_data() %>%
            mutate(link = link_to_vufind(control_number, title_author)) %>%
            select(link, call_number, copies, circs_in_window, busy, rec_copies, weedable)
    })

    output$weedable_table <- renderDataTable(
        weedable_readable(), escape = FALSE
    )

    output$downloadData <- downloadHandler(
    filename = function() {
        paste("easy-weedable-", input$home_location, "-", input$lc_letters, ".csv", sep = "")
    },
    content = function(file) {
        write.csv(weedable_data(), file, row.names = FALSE)
    }
  )

})
