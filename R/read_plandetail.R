#
#' nest contract details into the plan id
#'
#' @param base_uri character. A retailer cdr brand name. See `readeprd::base_uris` for valid names.
#' @param planid character; Supply an EME or VEFS offer identifier
#'
#' @export

read_eprd_plan <- function(base_uri,
                           planid
){

  contract <- NULL

  plan <- plan_to_df(base_uri, planid) %>%
    data.table::as.data.table() %>%
    .[, ':=' (contract = list(tidy_details_to_df(contract)))
    ] %>%
    dplyr::as_tibble()
  #dplyr::mutate(contract = list(tidy_details_to_df(contract)))

  return(plan)

}



#' @keywords internal
#' function that clean retailer plans and adds plan details into a list

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
    data.table::as.data.table() %>%
    .[, ':=' (distributor = distributor,
                  included_postcodes = postcodes,
                  contract = list(contract_details)
              )
      ] %>%
    dplyr::as_tibble()

  return(plan_df)
}


#' @keywords internal
#' function that cleans retailer plans details
tidy_details_to_df <- function(result) {
  result |>
    purrr::map(unlist) |>
    dplyr::bind_rows() |>

    # suppress message of new names
    suppressMessages() %>%
    janitor::clean_names() %>%
    dtplyr::lazy_dt() %>%
    tidyr::pivot_longer(cols = dplyr::everything(),
                         names_to = "variable",
                         values_to = "value") %>%
    dplyr::as_tibble()


  }



