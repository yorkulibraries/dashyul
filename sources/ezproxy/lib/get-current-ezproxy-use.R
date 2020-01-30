####
####
####

ezproxy_current_data_dir <-  paste0(Sys.getenv("DASHYUL_DATA"), "/ezproxy/current/")
files <- list.files(ezproxy_current_data_dir, pattern = "20.*-daily-users-per-platform-detailed.csv", full.names = TRUE)

write("Reading detailed EZProxy logs ...", stderr())

ezp <- do.call("rbind", lapply(files,
                               function (f) {
                                   read_csv(f, col_types = "Dccccccccccc")
                               }
                               )
               ) %>%
    filter(date >= start_of_academic_year(academic_year(Sys.Date()))) %>%
    filter(! is.na(faculty))

## Filter out raw hostnames
ezp <- ezp %>%
    filter(! grepl("[[:alpha:]]\\.[[:alpha:]]", platform))

## Rewrite the ED students's subject1 so that instead of being grouped by teachable
## (BIOL, EN, HIST, VISA) they are all grouped into EDUC.
ezp$subject1[ezp$faculty == "ED"] <- "EDUC"
