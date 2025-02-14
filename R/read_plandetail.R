

# Call EPRD API --------------------------------------------------------

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


# Clean Plan detail -----------------------------------------------------------

# function that clean retailer plans and adds plan details into a list

# need retailer base_uri and plan_id
plan_to_df <- function(base_uri, planid){

  #extract the plan contract details
  plandetail_list <- call_eprd_api_plandetail(
    base_uri = base_uri,
    planid = planid)$data

  # collapse distributor and postcode into single string each
  distributor <- plandetail_list$geography$distributors %>%
    stringr::str_c(., collapse = ", ")
  postcodes <- plandetail_list$geography$includedPostcodes %>%
    stringr::str_c(., collapse = ", ")

  # adjust based on fuel type
  if (any(stringr::str_detect(names(plandetail_list), "gasContract"))) {

    # bind all non-list details
    contract <- plandetail_list$gasContract %>%
      purrr::discard(~ is.list(.x)) %>%
      dplyr::bind_rows()

    # get all the list details
    contract_details <- plandetail_list$gasContract %>%
      purrr::keep(~ is.list(.x))

  }else{
    contract <- plandetail_list$electricityContract %>%
      purrr::discard(~ is.list(.x)) %>%
      dplyr::bind_rows()

    contract_details <- plandetail_list$electricityContract %>%
      purrr::keep(~ is.list(.x))

  }


  plan_df <- plandetail_list %>%
    purrr::discard(~ is.list(.x)) %>%
    dplyr::bind_rows() %>%
    dplyr::bind_cols(contract) %>%
    dplyr::mutate(
      distributor = distributor,
      included_postcodes = postcodes,
      contract = list(contract_details)
    )

  return(plan_df)
}



tidy_details_to_df <- function(result) {
  result |>
    purrr::map(unlist) |>
    dplyr::bind_rows() |>

    # suppress message of new names
    suppressMessages() %>%
    janitor::clean_names() %>%
    tidyr::pivot_longer(cols = everything(),
                 names_to = "variable",
                 values_to = "value")


  }


# nest contract details into the plan id
read_eprd_plan <- function(base_uri, planid){

  plan <- plan_to_df(base_uri, planid) %>%
    dplyr::mutate(contract = list(tidy_details_to_df(contract))
    )

  return(plan)

}

