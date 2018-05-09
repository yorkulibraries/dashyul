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
                tags$p("William Denton (wdenton@yorku.ca)"),
                tags$p("Updated 09 May 2018."),
                width = 2
            ),

            mainPanel(
                dataTableOutput("weedable_table")
            )
        )
    )
)
