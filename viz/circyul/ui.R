library(shiny)

shinyUI(

    fluidPage(

        titlePanel("CircYUL: YUL circulation history"),

        sidebarLayout(

            sidebarPanel(

                textInput("raw_control_number", label = "Control number", value = "https://www.library.yorku.ca/find/Record/2184579"),
                tags$p("The control number is the number at the end of the URL in VuFind. Enter it alone, or just paste in the entire URL."),
                tags$p("Circulation records cover A2006-A2016."),
                tags$p("William Denton (wdenton@yorku.ca)")

            ),

            mainPanel(
                tags$h2(textOutput("title_information")),
                plotOutput("circ_history_plot"),
                tableOutput("item_history_table")
            )

        )
    )
)
