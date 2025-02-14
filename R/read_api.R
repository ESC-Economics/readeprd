## GLOBAL SETTINGS -------------------------------------------------------------
rm(list = ls())
user <- "C:/Users/MAyala/Essential Services Commission/Economics Team - Documents/"
vec_setup <- function(){
  
  library(esctheme)
  r_setup()
  library(qs)
  library(httr2)
}

vec_setup()

# read base uris
base_uris <- read_csv("cdr_base.csv") %>% janitor::clean_names()

#Uniform Resource Identifier
baseuris <- base_uris$cdr_brand


# Generic Plan Metadata -------------------------------------------------------

# function to store base url
get_base_url <- function() {
  "https://cdr.energymadeeasy.gov.au/"
}



# function to call api
call_eprd_api <- function(api_uri, 
                          offer_type = "all", 
                          fuel_type = "all",
                          effective = "all"
                            ){
  
  #create the base request with uri
  req <- httr2::request(paste0(get_base_url(), api_uri))
  
  
  # Choose the appropriate method and perform the request
  resp <- req |>
    
    # Then we add on the generic plans path
    httr2::req_url_path_append("cds-au/v1/energy/plans") |>
    
    # Add query parameters type, fuel, effective and page-size
    httr2::req_url_query(
      type = str_to_upper(offer_type), 
      fuelType = str_to_upper(fuel_type),
      effective = str_to_upper(effective),
      `page-size` = 900
    ) |>
    # include required headers
    httr2::req_headers(
      `x-v` = 1,
      `x-min-v` = 1
    ) %>% 
    httr2::req_perform()
  
  # Check for errors based on the status code
  httr2::resp_check_status(resp)
  
  # Return the parsed content of the response
  httr2::resp_body_json(resp)
  
  
}



# function that cleans individual plan metadata
planmeta_to_df <- function(plan){
  
  distributor <- plan$geography$distributors %>% str_c(., collapse = ", ")
  postcodes <- plan$geography$includedPostcodes %>% stringr::str_c(., collapse = ", ")
  
  plan_df <- plan %>% 
    purrr::discard(~ is.list(.x)) %>% 
    dplyr::bind_rows() %>% 
    dplyr::mutate(
      distributor = distributor,
      included_postcodes = postcodes
    )
  
  return(plan_df)
  
}



# function that cleans retailer plans metadata
tidy_planmeta_to_df <- function(baseuris){
  
  plan_list <- call_eprd_api(api_uri = baseuris)$data$plans
  
  plan_df <- plan_list %>% 
    purrr::map(
      planmeta_to_df
    ) %>% 
    dplyr::bind_rows()
  
  return(plan_df)
  
  
}


# function that reads retailer plan metadata in a single data frame
read_eprd_metadata <- function(retailer = "all"){
  
  if (retailer == "all") {
    
    baseuris <- base_uris$cdr_brand
    
    d <- purrr::map(
      baseuris,
      tidy_planmeta_to_df
    ) %>%
      bind_rows()
    
    return(d)
    
  }else{
    
    d <- purrr::map(
      retailer,
      tidy_planmeta_to_df
    ) %>%
      bind_rows()
    
    return(d)
    
  }
  
}






