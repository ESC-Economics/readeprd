#' Download, extract, and tidy AER Energy plan metadata
#'
#' @param api_uri character. Supply retailer uniform resource identifier.
#' @param offer_type character; default is "all". Other values are "standing",
#' "market" and "regulated"
#' @param fuel_type character; default is "all". Other values are "gas",
#' "electricity" and "dual"
#' @param effective  character; default is "all". Other values are "current" and
#' "future"
#'
#'
#' @export

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
      type = stringr::str_to_upper(offer_type),
      fuelType = stringr::str_to_upper(fuel_type),
      effective = stringr::str_to_upper(effective),
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


# function to store base url
get_base_url <- function() {
  "https://cdr.energymadeeasy.gov.au/"
}









