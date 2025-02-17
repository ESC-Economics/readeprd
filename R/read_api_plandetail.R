#' Call EPRD API plan detail
#' @param base_uri character. A retailer cdr brand name. See `readeprd::base_uris` for valid names.
#' @param planid character; Supply an EME or VEFS offer identifier
#'
#' @export

# need  retailer base_uri and plan_id

call_eprd_api_plandetail <- function(base_uri, planid){

  # Create the base request
  req <- httr2::request(paste0(get_base_url(), base_uri))


  # Choose the appropriate method and perform the request
  resp_plandetail <- req |>

    httr2::req_url_path_append("cds-au/v1/energy/plans") |>

    httr2::req_url_path_append(planid) |>

    httr2::req_headers(
      `x-v` = 3,
      `x-min-v` = 3
    ) %>%
    httr2::req_perform()

  # Check for errors based on the status code
  httr2::resp_check_status(resp_plandetail)

  # Return the parsed content of the response
  httr2::resp_body_json(resp_plandetail)

}

