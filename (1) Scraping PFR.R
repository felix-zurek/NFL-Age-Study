library(tidyverse)
library(rvest)

Sys.setlocale("LC_TIME", "English")

make_draft_table <- function(season){
  
  link <- str_c("https://www.pro-football-reference.com/years/",
                season,
                "/draft.htm")
  
  page <- read_html(link)
  str_c("Reading in the ", season, " Draft... \n") %>% cat()
  table <- html_table(page)[[1]] %>%
    janitor::row_to_names(row_number = 1) %>% 
    janitor::clean_names() %>%
    select(round = rnd,
           pick,
           team = tm,
           name = player,
           position = pos,
           av = w_av) %>%
    mutate(season = season,
           name = name %>% str_remove(" HOF")) %>% 
    relocate(season, 1) %>% 
    filter(!is.na(as.double(pick))) %>% 
    mutate(av = av %>% as.double() %>%  replace_na(0))
  
  visit_indiv_pages <- function(name,link){
    
    page_indiv <- try(link %>% session() %>%
      session_follow_link(name), silent = TRUE)
    
    if(class(page_indiv) == "try-error"){
      cat("error: loading page of", name, "\n")
      return(list(name = name,
                  av_five = NA,
                  day_of_birth = NA))
    }
    
    day_of_birth <- page_indiv %>% 
      html_nodes("#necro-birth") %>%
      html_text2() %>%
      lubridate::as_date(format = "%B %d, %Y") %>% 
      as.character()
    
    table_av <- try(html_table(page_indiv)[[1]])
    
    if(any(class(table_av) == "try-error")){
      cat("error: loading table of", name, "\n")
      av_five <- 0
    }else{
        if(any(colnames(table_av) == "")){
        table_av <- table_av %>% janitor::row_to_names(row_number = 1) %>% 
          janitor::clean_names()
      }else{
        table_av <- table_av %>% janitor::clean_names()
      }
      
      av_five <- table_av %>% select(year,av) %>%
        mutate(year = year %>% str_remove_all("\\*|\\+") %>% as.double()) %>% 
        filter(!is.na(year)) %>% 
        pull(av) %>% as.double() %>% head(5) %>% sum()
      }
    
    if(length(av_five) == 0){
      cat("error: no av in table", name, "\n")
      av_five <- 0 
    }
    
    if(length(day_of_birth) == 0){
      cat("error: no birthday of", name, "\n")
      return(list(name = name,
                  av_five = NA,
                  day_of_birth = NA
      ))
    }
    
    
    return(list(name = name,
                av_five = av_five,
                day_of_birth = day_of_birth
                ))
  }

  indiv_table <- table %>% pull(name) %>% 
    map(visit_indiv_pages, link = link) %>% bind_rows()
  
  table <- table %>%
    left_join(indiv_table) %>% 
    mutate(day_of_birth = day_of_birth %>% as.Date(),
                   age = lubridate::time_length(
                     as.Date(str_c(season,"-09-01")) - day_of_birth,
                     unit = "years"
                   ) %>% round(2))
  return(table)
}

tables <- map(2000:2017,make_draft_table)

data_draft <- tables %>% bind_rows()

# data_draft %>% write_csv('data_draft.csv')
