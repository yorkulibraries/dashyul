library(shiny)

shinyUI(
    fluidPage(
        titlePanel("EStuTTe: Every Student, Their Textbook estimator"),
        sidebarLayout(
            sidebarPanel(
                textInput("min_student_threshold", label = "Minimum student threshold", value = "100", width = "200px"),
                textInput("students_per_textbook", label = "Students per textbook", value = "50", width = "200px"),
                textInput("textbook_holdings_limit", label = "Maximum textbook holdings", value = "4", width = "200px"),
                textInput("max_courselevel", label = "Maximum course level", value = "1", width = "200px"),
                textInput("min_price_threshold", label = "Minimum price threshold", value = "25", width = "200px"),
                tags$p("All data is from A2016."),
                tags$p("William Denton (wdenton@yorku.ca)"),
                tags$p("Updated 01 December 2017."),
                width = 2
            ),
            mainPanel(
                tags$p("Estimated maximum cost:"),
                textOutput("buying_list_cost"),
                tableOutput("buying_list_table")
            )
        )
    )
)
