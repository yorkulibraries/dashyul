library(shiny)

shinyUI(
    fluidPage(
        titlePanel("CircYUL"),
        sidebarLayout(
            sidebarPanel(
                tags$p("CircYUL shows the total annual circulation",
                       "of all items of a given bibliographic record",
                       "of something in our circulating collection."),
                textInput("raw_control_number_or_barcode",
                          label = "Control number or item barcode",
                          value = "https://www.library.yorku.ca/find/Record/2184579"),
                tags$p("The control number is the number at the end",
                       "of the URL in VuFind. Enter it alone, or just paste in the entire URL.",
                       "Or, use a barcode reader to scan the item's barcode."),
                tags$p("Circulation records cover A1996 to last month."),
                tags$p("William Denton (wdenton@yorku.ca)")
            ),
            mainPanel(
                tags$h2(textOutput("title_information")),
                htmlOutput("total_circ_count"),
                plotOutput("circ_history_plot"),
                tableOutput("item_history_table")
            )
        )
    )
)
