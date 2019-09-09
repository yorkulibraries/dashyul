library(tidyverse)
library(ggplot2)
library(lubridate)
library(scales)
library(shiny)

## ezpz_data_dir <- paste0(Sys.getenv("DASHYUL_DATA"), "/viz/ezpz/")
ezpz_data_d <- "/dashyul/data/viz/ezpz/"
ezp_data_d <- "/dashyul/data/ezproxy/"

platform_metrics <- readRDS(paste0(ezp_data_d, "metrics/platform-metrics.rds")) %>%
    filter(ayear %in% c(2012, 2013, 2016, 2017, 2018))
platform_metrics$platform <- as.factor(platform_metrics$platform)

daily_platform_use <- readRDS(paste0(ezpz_data_d, "daily-platform-use.rds"))
## daily_per_platform$platform <- as.factor(daily_per_platform$platform)

platform_names <- levels(platform_metrics$platform)

metrics_summary_by_platform <- function(platform_name) {
    platform_metrics %>%
        filter(platform == platform_name) %>%
        mutate(ayear = as.integer(ayear)) %>%
        select(ayear, users, uses, auf, upm, i_f, upm_rank, i_f_rank)
}

## relative_metrics <- function(platform_name) {
##     ## First find the people who used the platform.
##     platform_users <- daily_per_platform %>%
##         filter(ayear == 2016, platform == platform_name) %>%
##         select(user_barcode) %>% distinct
##     ## Then calculate relative metrics.
##     relative_metrics <- daily_per_platform %>%
##         filter(user_barcode %in% platform_users$user_barcode, ayear == 2016) %>%
##         group_by(platform) %>%
##         summarise(count = n()) %>%
##         mutate(rif = round(count/length(platform_users$user_barcode), 1)) %>%
##         select(platform, rif)
##     relative_metrics <- left_join(relative_metrics, platform_metrics %>% filter(ayear == 2016) %>% select(platform, interest_factor), by = "platform") %>%
##         mutate(interestedness = round(rif/interest_factor, 1))
##     relative_metrics %>%
##         filter(interestedness >= 1) %>%
##         filter(platform != platform_name) %>%
##         arrange(desc(interestedness))
## }

chart_platform_metrics <- function(platform_name) {
    this_platform_metrics <- platform_metrics %>%
        filter(platform == platform_name)
    this_platform_metrics %>%
        ggplot(aes(x = upm_rank, y = i_f_rank)) +
        geom_label(data = this_platform_metrics,
                   aes(label = ayear, colour = as.character(ayear)), position = position_jitter(), show.legend = FALSE) +
        scale_colour_grey(start = 0.6, end = 0.2) +
        labs(x = "UPM rank",
             y = "IF rank",
             title = paste(platform_name, "ranks")) +
        scale_x_continuous(breaks = seq(1, 4)) +
        scale_y_continuous(breaks = seq(1, 4)) +
        expand_limits(x = c(1, 4), y = c(1, 4)) +
        theme(panel.grid.minor = element_blank())
}

graph_users_per_day_historical <- function(platform_name) {
    daily_platform_use %>%
        filter(platform == platform_name) %>%
        mutate (date = date + years(2017 - ayear)) %>%
        ggplot(aes(x = date, y = n)) +
        facet_grid(ayear ~ .) +
        geom_step() +
        labs(x = "", y = "",
             title = paste0("Users per day: ", platform_name)) +
        scale_x_date(date_breaks = "1 month", labels = date_format("%b")) + expand_limits(y = 0)
}

chart_platform_annual_upm <- function(platform_name) {
    this_platform_metrics <- platform_metrics %>%
        filter(platform == platform_name) %>%
        mutate(upm_change = round(100 * (upm / first(upm) - 1)))
    this_platform_metrics %>%
        ggplot(aes(x = ayear, y = upm)) +
        geom_line() +
        geom_point(alpha = 0.5) +
        geom_label(data = this_platform_metrics %>% filter(ayear == 2016),
                   aes(label = paste0(upm_change, "%"),
                       vjust = "inward",
                       hjust = "inward")) +
        labs(x = "",
             y = "",
             title = paste(platform_name, "users per mille")) +
        theme(panel.background = element_rect(fill = "white", colour = "white"),
              axis.ticks.x = element_blank(),
              axis.ticks.y = element_blank(),
              strip.background = element_blank(),
              legend.title = element_blank(),
              legend.key = element_blank())
}

chart_platform_annual_if <- function(platform_name) {
    this_platform_metrics <- platform_metrics %>%
        filter(platform == platform_name) %>%
        mutate(i_f_change = round(100 * (i_f / first(i_f) - 1)))
    this_platform_metrics %>%
        ggplot(aes(x = ayear, y = i_f)) +
        geom_line() +
        geom_point(alpha = 0.5) +
        geom_label(data = this_platform_metrics %>% filter(ayear == 2016),
                   aes(label = paste0(i_f_change, "%"),
                       vjust = "inward",
                       hjust = "inward")) +
        labs(x = "",
             y = "",
             title = paste(platform_name, "interest factor")) +
        theme(panel.background = element_rect(fill = "white", colour = "white"),
              axis.ticks.x = element_blank(),
              axis.ticks.y = element_blank(),
              strip.background = element_blank(),
              legend.title = element_blank(),
              legend.key = element_blank())
}

## chart_platform_annual_overlay <- function(platform_name) {
##     get_monthly_platform_use(platform_name) %>%
##         ggplot(aes(x = month, y = n)) +
##         geom_line(aes(group = ayear, colour = as.character(ayear))) +
##         scale_colour_grey(start = 0.8, end = 0.1) +
##         geom_point(alpha = 0.5, aes(group = ayear, colour = as.character(ayear))) +
##         labs(x = "",
##              y = "",
##              title = paste(platform_name, "annual overlay")) +
##         theme(panel.background = element_rect(fill = "white", colour = "white"),
##               axis.ticks.y = element_blank(),
##               strip.background = element_blank(),
##               legend.title = element_blank(),
##               legend.key = element_blank())
## }

server <- function(input, output, session) {

    users_per_day <- reactive({
        daily_platform_use %>% filter(platform == trimws(input$platform_name), ayear == 2017) ## %>% group_by(date) %>% summarise(count = n())
    })

    output$platform_list <- renderUI ({
        selectInput("platform_name", "... then choose from this list:",
                    as.list(platform_names[grep(input$platform_guess, platform_names, ignore.case = TRUE)]))
    })

    output$platform_ranks_plot <- renderPlot({
        chart_platform_metrics(input$platform_name)
    })

    output$users_per_day_plot <- renderPlot({
        graph_users_per_day_historical(input$platform_name)
    })

    ## output$platform_annual_overlay_plot <- renderPlot({
    ##     chart_platform_annual_overlay(input$platform_name)
    ## })

    output$platform_upm_plot <- renderPlot({
        chart_platform_annual_upm(input$platform_name)
    })

    output$platform_if_plot <- renderPlot({
        chart_platform_annual_if(input$platform_name)
    })

    output$metrics_summary <- renderTable ({
        metrics_summary_by_platform(input$platform_name)
    })

    ## output$relative_metrics <- renderTable ({
    ##     relative_metrics(input$platform_name)
    ## })

}

ui <- fluidPage(

    titlePanel("EZPZ: Metrics and data for platforms used through EZProxy"),

    sidebarLayout(

        sidebarPanel(

            textInput("platform_guess", label = "Search for a platform ...", value = "Scholars Portal Journals"),
            uiOutput("platform_list"),
            tags$p("Data covers A2012, A2013, A2016, A2017, A2018"),
            tags$p("Updated 06 Sep 2019 by William Denton (wdenton@yorku.ca).")

        ),

        mainPanel(
            plotOutput("users_per_day_plot", width = "75%"),
            ## plotOutput("platform_annual_overlay_plot"),
            plotOutput("platform_ranks_plot", height = "400px", width = "400px"),
            tags$h2("Primary metrics"),
            tableOutput("metrics_summary"),
            plotOutput("platform_upm_plot", height = "200px", width = "75%"),
            plotOutput("platform_if_plot", height = "200px", width = "75%")
            ## tags$h2("Relative metrics")
            ## tableOutput("relative_metrics")
        )

    )
)

shinyApp(ui = ui, server = server)
