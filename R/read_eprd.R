



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

    ids <- meta$planId
    ret <- retailer

    message(paste0("Extracting ",length(ids)," plans from ",unique(length(ret)), " retailers"))

    plans <- purrr::map2(ids,
                         ret,
                         \(x, y) read_eprd_plan(base_uri =  y, planid =  x)
    ) %>%
      dplyr::bind_rows()

    return(plans)

  }

}

