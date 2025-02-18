## code to prepare `cdrbase` dataset goes here

library(dplyr)
library(readr)


# read base uris
base_uris <- readr::read_csv("data-raw/cdr_base.csv") %>% janitor::clean_names()


usethis::use_data(base_uris, internal = FALSE)
