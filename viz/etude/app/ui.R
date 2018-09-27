## library(shiny)

shinyUI(

    fluidPage(

        titlePanel("Étude"),

        sidebarLayout(

            sidebarPanel(
                tags$p('How students (undergraduate or graduate, but', em('only'), 'students, no others) use our collections.  Work in progress.'),
                uiOutput("faculty"),
                uiOutput("subject"),
                tags$p("Covers only this academic year. EZProxy updates happen daily; Symphony monthly."),
                tags$p("William Denton (wdenton@yorku.ca)")
            ),

            mainPanel(
                tags$h2("EZProxy"),
                plotOutput("platform_uses_plot"),
                plotOutput("ezp_users_per_day_plot"),
                tags$h3("Top 10 Scholars Portal ebooks viewed >= 5 times"),
                tableOutput("sp_ebook_most_viewed_table"),
                tags$h2("Symphony"),
                tags$p("Note: Laptops, headphones, chargers and other accessories are not included here."),
                plotOutput("checkouts_by_class_letter_plot"),
                plotOutput("checkouts_by_checkout_date_plot"),
                plotOutput("checkouts_by_item_type_plot"),
                plotOutput("checkouts_by_year_acq_plot"),
                tags$p("Note: anything acquired in 1996 or earlier has an acquisition date of 1996 in Symphony."),
                tags$h3("Top 10 titles borrowed >= 5 times"),
                tableOutput("most_checkouted_table"),
                tags$h2("Demographics"),
                tags$p("These counts are the number of students who checked out an item in Symphony or used a platform through EZProxy."),
                tableOutput("demographics_degree_table"),
                tableOutput("demographics_year_table"),
                tags$h2("Patterns of individual use"),
                plotOutput("checkouts_by_student_year_scatter_plot"),
                tags$p("The above box and whisker plots show the distribution of distinct items borrowed per student; the box contains the first to third quartile and the line inside shows the median."),
                plotOutput("platforms_by_student_year_scatter_plot"),
                tags$p("The above box and whisker plots show the distribution of different platforms used through EZProxy per student.")
            )
        )
    )
)
