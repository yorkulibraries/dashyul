library(shiny)

shinyUI(
    fluidPage(
        titlePanel("Easy Weeder"),
        sidebarLayout(
            sidebarPanel(
                uiOutput("home_locations"),
                uiOutput("item_types"),
                textInput("lc_letters", label = "LC class letter(s)", value = "B"),
                downloadButton("downloadData", "Download data"),
                tags$hr(),
                tags$p("William Denton (wdenton@yorku.ca)"),
                tags$p("Updated 03 January 2019."),
                tags$a(href="https://www.youtube.com/watch?v=g9eX2ajK3A4", "See also Easy Reader."),
                width = 2
            ),

            mainPanel(
                dataTableOutput("weedable_table")
            )
        )
    )
)
