library(tidyverse)
library(lubridate)
library(scales)
library(shiny)

library(yulr)

## dashboard_data_d <- paste0(Sys.getenv("DASHYUL_DATA"), "/viz/etude/")
etude_data_d <- "/dashyul/data/viz/etude/"

sp_ebooks_data_d <- "/dashyul/data/ebooks/scholarsportal/"

symph_checkouts_by_acq_year      <- read_csv(paste0(etude_data_d, "symphony-checkouts-by-acq-year.csv"))
symph_checkouts_by_checkout_date <- read_csv(paste0(etude_data_d, "symphony-checkouts-by-checkout-date.csv"))
symph_checkouts_by_class_letter  <- read_csv(paste0(etude_data_d, "symphony-checkouts-by-class-letter.csv"))
symph_checkouts_by_item_type     <- read_csv(paste0(etude_data_d, "symphony-checkouts-by-item-type.csv"))
symph_checkouts_by_student_year  <- read_csv(paste0(etude_data_d, "symphony-checkouts-by-student-year.csv"))
symph_checkouts_most_checkouted  <- read_csv(paste0(etude_data_d, "symphony-checkouts-most-checkouted.csv"))

ezp_platform_uses <- read_csv(paste0(etude_data_d, "ezp-platform-uses.csv"))
ezp_users_per_day <- read_csv(paste0(etude_data_d, "ezp-users-per-day.csv"))
ezp_user_per_day  <- ezp_users_per_day %>% filter(date <= Sys.Date() - days(2)) ## Drop the partial yesterday
ezp_platforms_by_student_year <- read_csv(paste0(etude_data_d, "ezp-platforms-by-student-year.csv"))

sp_ebook_most_viewed <- read_csv(paste0(etude_data_d, "sp-most-viewed-ebooks.csv"))
sp_ebook_id_map      <- read_csv(paste0(sp_ebooks_data_d, "sp-ebook-id-mapping.csv"))

ezp_demographics   <- read_csv(paste0(etude_data_d, "ezp-demographics.csv"))
symph_demographics <- read_csv(paste0(etude_data_d, "symphony-demographics.csv"))
demographics       <- merge(symph_demographics, ezp_demographics)

all_faculties_and_subjects <- rbind(symph_checkouts_by_class_letter %>% select(faculty, subject1),
                                    ezp_platform_uses %>% select(faculty, subject1)
                                    ) %>% distinct()

shinyServer(function(input, output, session) {

    output$faculty <- renderUI({
        selectInput("faculty", "Faculty", c("AP", "ED", "ES", "FA", "GL", "GS", "HH", "LE", "LW", "SB", "SC"), selected = "AP")
    })

    output$subject <- renderUI({
        selectInput("subject", "Subject", all_faculties_and_subjects %>% filter(faculty == input$faculty) %>% select(subject1) %>% distinct %>% arrange(subject1))
    })

    output$checkouts_by_class_letter_plot <- renderPlot({
        checkouts_by_class_letter <- symph_checkouts_by_class_letter %>%
            filter(faculty == input$faculty, subject1 == input$subject)
        minimum_checkouts <- signif(mean(checkouts_by_class_letter$checkouts), 1) ## Round it nicely to a ten or hundred
        ggplot(checkouts_by_class_letter %>% filter(checkouts > minimum_checkouts),
               aes(x = lc_letters, y = checkouts)) +
            geom_col() +
            labs(title = paste("Checkouts by class letter (minimum", minimum_checkouts, "):", input$faculty, "/", input$subject, "(includes multiples by same student)"),
                 x = "Subject",
                 y = "") +
            theme(axis.text = element_text(size = 10), axis.text.x = element_text(angle = 45))
    })

    output$checkouts_by_checkout_date_plot <- renderPlot({
        ggplot(symph_checkouts_by_checkout_date %>% filter(faculty == input$faculty, subject1 == input$subject),
               aes(x = date, y = checkouts)) +
            geom_col() +
            labs(title = paste("Checkouts by date:", input$faculty, "/", input$subject, "(includes multiples by same student)"),
                 x = "",
                 y = "") +
            theme(axis.text = element_text(size = 10), axis.text.x = element_text(angle = 45))
    })

    output$checkouts_by_item_type_plot <- renderPlot({
        checkouts_by_item_type <- symph_checkouts_by_item_type %>%
            filter(faculty == input$faculty, subject1 == input$subject)
        minimum_checkouts <- signif(mean(checkouts_by_item_type$checkouts), 1) ## Round it nicely to a ten or hundred
        ggplot(checkouts_by_item_type %>% filter(checkouts > minimum_checkouts),
               aes(x = item_type, y = checkouts)) +
            geom_col() +
            labs(title = paste("Checkouts by item type (minimum", minimum_checkouts, "):", input$faculty, "/", input$subject, "(includes multiples by same student)"),
                 x = "Item type",
                 y = "") +
            theme(axis.text = element_text(size = 10), axis.text.x = element_text(angle = 45))
    })

    output$checkouts_by_year_acq_plot <- renderPlot({
        ggplot(symph_checkouts_by_acq_year %>% filter(faculty == input$faculty, subject1 == input$subject),
               aes(x = acq_year, y = count)) +
            geom_col() +
            labs(title = paste("Checkouts by acquisition year:", input$faculty, "/", input$subject, "(no duplicate items)"), x = "Acquisition year", y = "") +
            theme(axis.text = element_text(size = 10), axis.text.x = element_text(angle = 45))
    })

    output$most_checkouted_table <- renderTable({
        symph_checkouts_most_checkouted %>%
            filter(faculty == input$faculty, subject1 == input$subject) %>%
            arrange(desc(checkouts)) %>%
            head(10) %>%
            mutate(record_link = link_to_vufind(control_number, readable_marc245(title_author))) %>%
            select(checkouts, record_link)
    }, include.rownames = FALSE, sanitize.text.function = function(x) x)

    output$demographics_degree_table <- renderTable({
        demographics %>%
            filter(faculty == input$faculty, subject1 == input$subject) %>%
            select(degree, symphony, ezproxy) %>%
            gather(where, count, symphony:ezproxy) %>%
            group_by(degree, where) %>%
            summarise(students = sum(count)) %>%
            spread(where, students)
    }, include.rownames = FALSE)

    output$demographics_year_table <- renderTable({
        ## Only show the year breakdown for undergrads.  Some grad programs are small.
        if (! input$faculty == "GS") {
            demographics %>%
                filter(faculty == input$faculty, subject1 == input$subject) %>%
                select(year, symphony, ezproxy) %>%
                gather(where, count, symphony:ezproxy) %>%
                group_by(year, where) %>%
                summarise(students = sum(count)) %>%
                spread(where, students)
        }
    }, include.rownames = FALSE)

    output$checkouts_by_student_year_scatter_plot <- renderPlot({
        if (! input$faculty == "GS") {
            ggplot(symph_checkouts_by_student_year %>% filter(faculty == input$faculty, subject1 == input$subject),
                   aes(year, items)) +
                geom_boxplot() +
                geom_jitter(width = 0.5) +
                labs(title = paste("Symphony checkouts per student:", input$faculty, "/", input$subject, "(distinct items)"),
                     x = "Student year",
                     y = "") +
                theme(axis.text = element_text(size = 10), axis.text.x = element_text(angle = 45))
        } else {
            ggplot(symph_checkouts_by_student_year %>% filter(faculty == input$faculty, subject1 == input$subject),
                   aes(degree, items)) +
                geom_boxplot() +
                geom_jitter(width = 0.5) +
                labs(title = paste("Symphony checkouts per student:", input$faculty, "/", input$subject, "(distinct items)"),
                     x = "Degree",
                     y = "") +
                theme(axis.text = element_text(size = 10), axis.text.x = element_text(angle = 45))
        }
    })

    ## EZProxy platform uses
    ##
    ## There get to be so many of these that we can't show them all.
    ## Because most students look at very few platforms, showing only
    ## the ones with more than the median number of views is one
    ## approach to cutting off the little-used platforms. Just using >
    ## 10 ended up making for some very crowded charts in big
    ## subjects.

    output$platform_uses_plot <- renderPlot({
        platforms_used <- ezp_platform_uses %>% filter(faculty == input$faculty, subject1 == input$subject)
        minimum_uses <- signif(mean(platforms_used$uses), 1) ## Round it nicely to a ten or hundred
        ggplot(platforms_used %>% filter(uses > minimum_uses),
               aes(x = platform, y = uses)) +
            geom_col() +
            labs(title = paste("Platform uses (>", minimum_uses, "through EZProxy):", input$faculty, "/", input$subject),
                 x = "Platform",
                 y = "") +
            theme(axis.text = element_text(size = 10), axis.text.x = element_text(angle = 90, hjust = 0.95)) +
            coord_flip()
    })

    output$ezp_users_per_day_plot <- renderPlot({
        ggplot(ezp_users_per_day %>% filter(faculty == input$faculty, subject1 == input$subject),
               aes(x = date, y = users)) +
            geom_step() +
            labs(title = paste("EZProxy users per day:", input$faculty, "/", input$subject),
                 x = "",
                 y = "") +
            theme(axis.text = element_text(size = 10), axis.text.x = element_text(angle = 45))
    })

    output$platforms_by_student_year_scatter_plot <- renderPlot({
        if (! input$faculty == "GS") {
            ggplot(ezp_platforms_by_student_year %>% filter(faculty == input$faculty, subject1 == input$subject),
                   aes(year, platforms)) +
                geom_boxplot() +
                geom_jitter(width = 0.5) +
                labs(title = paste("EZProxy platforms per student:", input$faculty, "/", input$subject),
                     x = "Student year",
                     y = "") +
                theme(axis.text = element_text(size = 10), axis.text.x = element_text(angle = 45))
        } else {
            ggplot(ezp_platforms_by_student_year %>% filter(faculty == input$faculty, subject1 == input$subject),
                   aes(degree, platforms)) +
                geom_boxplot() +
                geom_jitter(width = 0.5) +
                labs(title = paste("EZProxy platforms per student:", input$faculty, "/", input$subject),
                     x = "Degree",
                     y = "") +
                theme(axis.text = element_text(size = 10), axis.text.x = element_text(angle = 45))
        }
    })

    output$sp_ebook_most_viewed_table <- renderTable({
        sp_ebook_most_viewed %>%
            filter(faculty == input$faculty, subject1 == input$subject) %>%
            arrange(desc(viewed)) %>%
            head(10) %>%
            left_join(sp_ebook_id_map, by = c("ebook_id" = "complete_id")) %>%
            mutate(record_link = link_to_sp_books(ebook_id, title)) %>%
            select(viewed, record_link)
    }, include.rownames = FALSE, sanitize.text.function = function(x) x)

})
