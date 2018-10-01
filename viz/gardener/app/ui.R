library(shiny)

shinyUI(
    fluidPage(
        titlePanel("The Gardener"),
        sidebarLayout(
            sidebarPanel(
                uiOutput("home_locations"),
                uiOutput("item_types"),
                textInput("lc_letters", label = "LC class letter(s)", value = "FC"),
                fluidRow(
                ## Thanks to https://stackoverflow.com/a/42515042
                      splitLayout(
                        textInput("min_lc_digits", "Digits min", value = 0),
                        textInput("max_lc_digits", "max", value = 10000)
                      )
                ),
                tags$hr(),
                selectInput("last_circed_in_or_before",
                            "Last circ was in or before",
                            choices = seq(1995, 2018, by = 1), selected = 2018),
                selectInput("acquired_in_or_before",
                            "Acquired in or before",
                            choices = seq(1995, 2018, by = 1), selected = 2018),
                sliderInput("num_copies",
                            "Copies",
                            min = 1, max = 28, value = c(1, 28)),
                textInput("min_total_circs", label = "Min total circs", value = "0"),
                textInput("max_total_circs", label = "Max total circs", value = "10000"),
                downloadButton("downloadData", "Download data"),
                tags$hr(),
                tags$p("William Denton (wdenton@yorku.ca)"),
                tags$p("Updated 01 October 2018."),
                width = 2
            ),

            mainPanel(
                htmlOutput("results_count"),
                textOutput("readable_query"),
                tags$hr(),
                dataTableOutput("gardener_table")
            )
        )
    )
)
