library(tidyverse)
library(scales)
library(shiny)

## TODO: Fix the hardcoding of the data directory.

## yucoll_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/yucoll/")
yucoll_data_dir <- "/dashyul/data/yucoll/"
yucoll_data_file <- paste0(yucoll_data_dir, "yucoll-data.csv.gz")

yucoll_data <- read_csv(yucoll_data_file)

types <- list("BRONFMAN" = c("BRONF-BOOK"),
             "FROST" = c("FROST-BOOK"),
             "LAW" = c("LAW-BOOK"),
             "SCOTT" = c("SCOTT-BOOK", "SCORE"),
             "SCOTT-MAPS" = c("MAP", "SCMAP-BOOK"),
             "STEACIE" = c("STEAC-BOOK")
             )

## min_lc_digits <- function(df) { min(df$lc_digits, na.rm = TRUE) }
## max_lc_digits <- function(df) { min(df$lc_digits, na.rm = TRUE) }

shinyServer(function(input, output, session) {

    output$home_locations <- renderUI({
        selectInput("home_location", "Home location", names(types), selected = "SCOTT")
    })

    output$item_types <- renderUI({
        selectInput("item_type", "Item type", types[[input$home_location]])
    })

    j <- reactive({
        print(input$lc_digit_high)
        yucoll_data %>%
        filter(home_location == input$home_location,
               item_type == input$item_type,
               lc_letters == toupper(input$lc_letters),
               lc_digits >= as.numeric(input$lc_digit_low),
               lc_digits <= as.numeric(input$lc_digit_high)
               ) %>%
        group_by(acq_ayear) %>%
        summarise(total_circed = sum(circed), total_uncirced = sum(uncirced)) %>%
        mutate(pct_uncirced = as.integer(round((total_uncirced / (total_uncirced + total_circed) * 100))))
    })

    output$digits_low <- renderUI({
        textInput("lc_digit_low", "Lowest number", value = 0)
    })

    output$digits_high <- renderUI({
        textInput("lc_digit_high", "Highest number", value = 10000)
    })

    acqs <- reactive({
        j() %>%
        ## filter(lc_digits >= input$lc_digit_low,
        ##        lc_digits <= input$lc_digit_high) %>%
        group_by(acq_ayear) %>%
        summarise(count = sum(total_circed + total_uncirced))
    })

    output$acqs_plot <- renderPlot({
        ## i <- items %>%
        ##   filter(home_location == input$home_location,
        ##          item_type == input$item_type,
        ##          lc_letters == input$lc_letters) %>%
        ##   select(lc_letters, lc_digits, acq_year)
        ## i <- j %>% group_by(acq_year) %>% summarise(count = n())

        ggplot(acqs(), aes(x = acq_ayear, y = count)) +
        geom_bar(stat = "identity") +
        labs(title = paste(input$home_location,
                           input$item_type,
                           toupper(input$lc_letters),
                           "(", input$lc_digit_low, "–", input$lc_digit_high, ")",
                           "total acquisitions"),
             x = "Academic year",
             y = "") +
        theme(axis.text = element_text(size = 12), axis.text.x = element_text(angle = 90))
    })

    output$uncirced_plot <- renderPlot({

        ggplot(j(), aes(x = acq_ayear, y = pct_uncirced)) +
        geom_bar(stat = "identity") +
        labs(title = paste(input$home_location,
                           input$item_type,
                           toupper(input$lc_letters),
                           "(", input$lc_digit_low, "–", input$lc_digit_high, ")",
                           "acquisitions uncirced at end of A2016"),
             x = "Academic year",
             y = "%") +
        theme(axis.text = element_text(size = 12), axis.text.x = element_text(angle = 90))
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
