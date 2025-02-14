library(dplyr)
library(readr)


# read base uris
base_uris <- readr::read_csv("data-raw/cdr_base.csv") %>% janitor::clean_names()

save(base_uris, file = "data/baseuris.rda")
