library(shiny)

shinyUI(
    fluidPage(
        titlePanel("The Gardener"),
        sidebarLayout(
            sidebarPanel(
                uiOutput("home_locations"),
                uiOutput("item_types"),
                textInput("lc_letters", label = "LC class letter(s)", value = "B"),
                uiOutput("digits_low"),
                uiOutput("digits_high"),
                ## sliderInput("num_copies", "Copies", min = 1, max = 20, value = c(1, 20)),
                textInput("min_copies", label = "Min copies", value = "1"),
                textInput("max_copies", label = "Max copies", value = "20"),
                textInput("min_circ_ayear", label = "Min circ year", value = "2007"),
                textInput("max_circ_ayear", label = "Max circ year", value = "2017"),
                ## sliderInput("total_circs", "Circs", min = 0, max = 100, value = c(0, 100)),
                textInput("min_total_circs", label = "Min total circs", value = "0"),
                textInput("max_total_circs", label = "Max total circs", value = "1000"),
                downloadButton("downloadData", "Download data"),
                tags$p("William Denton (wdenton@yorku.ca)"),
                tags$p("Updated 09 May 2018."),
                width = 2
            ),

            mainPanel(
                dataTableOutput("gardener_table")
            )
        )
    )
)
