#' Download, extract, and tidy energy plan data
#' #'
#' @param retailer character. A retailer cdr brand name. See `readeprd::base_uris` for valid names.
#' @param planid (optional) character; default is "all". Supply an EME or VEFS offer
#' identifier (such as `TAN617921MR@VEC`) to get only that plan.
#' @param fuel_type character; default is "all". Other values are "electricity" and "gas".
#' @param source character; default is "vec". Choose plans from Victorian Energy Compare or Energy Made Easy.
#' Other values are "eme" and "all".
#'
#' @return data
#' @export
#'



# nest contract details into the plan id
read_eprd <- function(retailer = NULL,
                      planid = "all",
                      fuel_type = "all",
                      source = "vec"
){

  if (is.null(retailer)) {
    stop("The `retailer` argument to `read_eprd()` must be provided.")
  }

  if ((retailer == "all" && planid == "all")) {

    baseuris <- base_uris$cdr_brand

    if (source == "all") {

      message(paste0("Extracting plans from ",length(baseuris), " retailers"))

      meta <- read_eprd_metadata(retailer = retailer, fuel_type = fuel_type)

    }else{

      meta <- read_eprd_metadata(retailer = retailer, fuel_type = fuel_type) %>%
        dplyr::filter(
          stringr::str_detect(planId, toupper(source))
        )
    }

    ids <- meta$planId
    ret <- meta$brand

    message(paste0("Extracting ",length(ids)," plans from ",unique(length(ret)), " retailers"))

    plans <- purrr::map2(ids,
                    ret,
                    \(x, y) read_eprd_plan(base_uri =  y, planid =  x)
                   ) %>%
        dplyr::bind_rows()

    return(plans)

  }else{

    meta <- read_eprd_metadata(retailer = retailer, fuel_type = fuel_type) %>%
      dplyr::filter(
        stringr::str_detect(planId, toupper(source))
      )

    if (any(planid == "all")) {
      ids <- meta$planId
    }else{
      ids <- planid
    }

    ret <- retailer
    lplans <- dplyr::if_else(unique(length(ids)<=1), "plan","plans")
    lretailers <- dplyr::if_else(unique(length(ret)<=1), "retailer","retailers")

    message(
      paste("Extracting",length(ids),lplans,"from",unique(length(ret)),lretailers,
            sep = " ")
      )

    plans <- purrr::map2(ids,
                         ret,
                         \(x, y) read_eprd_plan(base_uri =  y, planid =  x)
    ) %>%
      dplyr::bind_rows()

    return(plans)

  }

}

