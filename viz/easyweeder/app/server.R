library(tidyverse)
library(scales)
library(shiny)

## TODO: Fix the hardcoding of the data directory.

## ezweeder_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/viz/ezweeder/")
ezweeder_data_dir <- "/dashyul/data/viz/ezweeder/"

ezweeder_checkouts <- read_csv(paste0(ezweeder_data_dir, "ezweeder-checkouts.csv"))
ezweeder_items     <- read_csv(paste0(ezweeder_data_dir, "ezweeder-items.csv"))
ezweeder_titles    <- read_csv(paste0(ezweeder_data_dir, "ezweeder-titles.csv"))

types <- list("BRONFMAN" = c("BRONF-BOOK"),
             "FROST" = c("FROST-BOOK"),
             "LAW" = c("LAW-BOOK"),
             "SCOTT" = c("SCOTT-BOOK", "SCORE"),
             "SCOTT-MAPS" = c("MAP", "SCMAP-BOOK"),
             "STEACIE" = c("STEAC-BOOK")
             )

shinyServer(function(input, output, session) {

    output$home_locations <- renderUI({
        selectInput("home_location", "Home location", names(types), selected = "SCOTT")
    })

    output$item_types <- renderUI({
        selectInput("item_type", "Item type", types[[input$home_location]])
    })

    output$digits_low <- renderUI({
        textInput("lc_digit_low", "Lowest number", value = 0)
    })

    output$digits_high <- renderUI({
        textInput("lc_digit_high", "Highest number", value = 10000)
    })

    items_in_range <- reactive({
        items %>%
        filter(home_location == input$home_location,
               item_type == input$item_type,
               lc_letters == toupper(input$lc_letters),
               lc_digits >= as.numeric(input$lc_digit_low),
               lc_digits <= as.numeric(input$lc_digit_high)
               )
    })

    checkouts_in_range <- reactive({
        checkouts %>% filter(item_barcode) %in% items_in_range()$item_barcode)
    })

    output$acqs_table <- renderTable({
        growth <- j() %>%
        rename(year = acq_ayear) %>%
        mutate(acquired = total_circed + total_uncirced) %>%
        rename(uncirced = total_uncirced) %>%
        select(year, acquired, uncirced, pct_uncirced)
        ## growth$year <- substring(as.character(growth$year), 0, 4)
        ## print(growth)
        growth
    })

})
