library(dplyr)
library(ggplot2)
library(readr)
library(scales)
library(shiny)

platform_metrics <- read_csv("data/platform_metrics.csv.gz")
platform_metrics$platform <- as.factor(platform_metrics$platform)

daily_per_platform <- read_csv("data/daily_per_platform.csv.gz", col_names = TRUE, col_types = "Dccc")
daily_per_platform$platform <- as.factor(daily_per_platform$platform)

platform_names <- levels(daily_per_platform$platform)

metrics_summary_by_platform <- function(platform_name) {
    platform_metrics %>% filter(platform == platform_name) %>% ungroup %>% select(ayear, users, auf, interest_factor)
}

relative_metrics <- function(platform_name) {
    ## First find the people who used the platform.
    platform_users <- daily_per_platform %>% filter(ayear == 2016, platform == platform_name) %>% select(user_barcode) %>% distinct
    ## Then calculate relative metrics.
    relative_metrics <- daily_per_platform %>% filter(user_barcode %in% platform_users$user_barcode, ayear == 2016) %>% group_by(platform) %>% summarise(count = n()) %>% mutate(rif = round(count/length(platform_users$user_barcode), 1)) %>% select(platform, rif)
    relative_metrics <- left_join(relative_metrics, platform_metrics %>% filter(ayear == 2016) %>% select(platform, interest_factor), by = "platform") %>% mutate(interestedness = round(rif/interest_factor, 1))
    relative_metrics %>% filter(interestedness >= 1) %>% filter(platform != platform_name) %>% arrange(desc(interestedness))
}

server <- function(input, output, session) {

    users_per_day <- reactive({
        daily_per_platform %>% filter(platform == trimws(input$platform_name), ayear == 2016) %>% group_by(date) %>% summarise(count = n())
    })

    output$platform_list <- renderUI ({
        selectInput("platform_name", "... then choose from this list:", as.list(platform_names[grep(input$platform_guess, platform_names, ignore.case = TRUE)]))
    })

    output$users_per_day_plot <- renderPlot({
        users_per_day() %>% ggplot(aes(x = date, y = count)) + geom_bar(stat = "identity") + labs(x = "", y = "", title = paste0("Users per day in A2016: ", input$platform_name))
    })

    output$change_in_usage_plot <- renderPlot ({
        platform_metrics %>% filter(platform == input$platform_name ) %>% ggplot(aes(x = users, y = uses)) + geom_point() + geom_path(arrow = arrow(type ="closed", length = unit(0.2, "cm"))) + labs(x = "Users", y = "Uses", title = paste0("Usage of ", input$platform_name, ", A2012, A2013, A2016"))

    })

    output$metrics_summary <- renderTable ({
        metrics_summary_by_platform(input$platform_name)
    })

    output$relative_metrics <- renderTable ({
        relative_metrics(input$platform_name)
    })

}

ui <- fluidPage(

    titlePanel("EZProxy platforms: interactive"),

    sidebarLayout(

        sidebarPanel(

            textInput("platform_guess", label = "Search for a platform ...", value = "Scholars Portal Journals"),
            uiOutput("platform_list"),
            tags$p("Data covers A2012, A2013 and A2016."),
            tags$p("Updated 13 October by William Denton (wdenton@yorku.ca).")

        ),

        mainPanel(
            plotOutput("users_per_day_plot"),
            tags$h2("Primary metrics"),
            tableOutput("metrics_summary"),
            tags$h2("Relative metrics"),
            tableOutput("relative_metrics"),
            tags$h2("Change in usage"),
            plotOutput("change_in_usage_plot")
        )

    )
)

shinyApp(ui = ui, server = server)
