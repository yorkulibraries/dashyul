library(shiny)

shinyUI(

    fluidPage(

        titlePanel("Easy Weeder!"),

        sidebarLayout(

            sidebarPanel(

                uiOutput("home_locations"),
                uiOutput("item_types"),
                textInput("lc_letters", label = "LC class letter(s)", value = "B"),
                uiOutput("digits_low"),
                uiOutput("digits_high"),

                tags$p("William Denton (wdenton@yorku.ca)"),
                tags$p("Updated 22 February 2018.")

            ),

            mainPanel(
                tableOutput("acqs_table")
            )

        )
    )
)
