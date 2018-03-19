library(shiny)

shinyUI(

    fluidPage(

        titlePanel("Growth and usage of the collection (A2000–A2016)"),

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
                plotOutput("acqs_plot"),
                plotOutput("uncirced_plot"),
                tableOutput("acqs_table")
                )

            )
        )
    )
