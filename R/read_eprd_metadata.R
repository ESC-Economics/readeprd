
#' Reads retailer plan metadata in a single data frame
#'
#' #' @param retailer character; default is "all". A retailer cdr brand name. See
#' `readeprd::base_uris` for valid names.
#' #' @param fuel_type character; default is "all". Other values are "electricity"
#' and "gas".
#'
#'
#' @return data
#' @export
#'

read_eprd_metadata <- function(retailer = "all", fuel_type = "all"){

  if (retailer == "all") {

    baseuris <- base_uris$cdr_brand

    d <- purrr::map(
      baseuris,
      \(x) tidy_planmeta_to_df(baseuris = x, fuel_type = fuel_type)
    ) %>%
      dplyr::bind_rows()

    return(d)

  }else{

    d <- purrr::map(
      retailer,
      \(x) tidy_planmeta_to_df(baseuris = x, fuel_type = fuel_type)
    ) %>%
      dplyr::bind_rows()

    return(d)

  }

}



# function that cleans individual plan metadata
planmeta_to_df <- function(plan){

  distributor <- plan$geography$distributors %>% stringr::str_c(., collapse = ", ")
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
tidy_planmeta_to_df <- function(baseuris, fuel_type = "all"){

  plan_list <- call_eprd_api(api_uri = baseuris,
                             fuel_type = fuel_type)$data$plans

  plan_df <- plan_list %>%
    purrr::map(
      planmeta_to_df
    ) %>%
    dplyr::bind_rows()

  return(plan_df)


}
