library(shiny)

shinyUI(
    fluidPage(
        titlePanel("The Gardener"),
        sidebarLayout(
            sidebarPanel(
                uiOutput("home_locations"),
                uiOutput("item_types"),
                textInput("lc_letters", label = "LC class letter(s)", value = "B"),
                fluidRow(
                ## Thanks to https://stackoverflow.com/a/42515042
                      splitLayout(
                        textInput("min_lc_digits", "Digits min", value = 0),
                        textInput("max_lc_digits", "max", value = 10000)
                      )
                ),
                ## uiOutput("digits_low"),
                ## uiOutput("digits_high"),
                tags$hr(),
                selectInput("last_circed_in_or_before", "Last circ was in or before", choices = seq(1995, 2017, by = 1), selected = 2017),
                selectInput("acquired_in_or_before", "Acquired in or before", choices = seq(1995, 2017, by = 1), selected = 2017),
                sliderInput("num_copies", "Copies", min = 1, max = 28, value = c(1, 28)),
                ## textInput("min_copies", label = "Min copies", value = "1"),
                ## textInput("max_copies", label = "Max copies", value = "20"),
                textInput("min_circ_ayear", label = "Min circ year", value = "0"),
                textInput("max_circ_ayear", label = "Max circ year", value = "2017"),
                textInput("min_total_circs", label = "Min total circs", value = "0"),
                textInput("max_total_circs", label = "Max total circs", value = "10000"),
                downloadButton("downloadData", "Download data"),
                tags$hr(),
                tags$p("William Denton (wdenton@yorku.ca)"),
                tags$p("Updated 16 July 2018."),
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
