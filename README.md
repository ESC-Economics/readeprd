
<!-- README.md is generated from README.Rmd. Please edit that file -->

# readeprd

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/readeprd)](https://CRAN.R-project.org/package=readeprd)

<!-- badges: end -->

The purpose of `readeprd` is to provide access to Consumer Data Rights
API so that retail energy plans from AER can be accessed directly from
R. For details about what data are provided by the CDR see
[here](https://consumerdatastandardsaustralia.github.io/standards/#cdr-energy-api_get-generic-plans).

## Installation

You can install the development version of readeprd with:

``` r
# install.packages("devtools")
devtools::install_github("ESC-Economics/readeprd")
```

## Example

You can access all the plan ids available in the market by using the
metadata function.

``` r
library(readeprd)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
```

``` r

plans <- read_eprd_metadata(retailer = "all")

glimpse(plans)
#> Rows: 13,402
#> Columns: 12
#> $ type               <chr> "MARKET", "MARKET", "MARKET", "MARKET", "STANDING",…
#> $ brand              <chr> "1st-energy", "1st-energy", "1st-energy", "1st-ener…
#> $ planId             <chr> "1ST875044MRE1@EME", "1ST875043MRE1@EME", "1ST87504…
#> $ fuelType           <chr> "ELECTRICITY", "ELECTRICITY", "ELECTRICITY", "ELECT…
#> $ brandName          <chr> "1st Energy", "1st Energy", "1st Energy", "1st Ener…
#> $ displayName        <chr> "RACT Saver - Tariff 31, 41 and 61, Residential", "…
#> $ lastUpdated        <chr> "2025-01-02T05:51:44.160Z", "2025-01-02T05:51:44.15…
#> $ customerType       <chr> "RESIDENTIAL", "RESIDENTIAL", "RESIDENTIAL", "RESID…
#> $ effectiveFrom      <chr> "2025-01-02T00:00:00.000Z", "2025-01-02T00:00:00.00…
#> $ distributor        <chr> "TasNetworks", "TasNetworks", "TasNetworks", "TasNe…
#> $ included_postcodes <chr> "7000, 7004, 7005, 7007, 7008, 7009, 7010, 7011, 70…
#> $ effectiveTo        <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
```

This example gets data on a specific retailer electricity plans from
Victoria. The contract details are nested in the list column `contract`

``` r

agl <- read_eprd(retailer = "agl",
                 planid = c("AGD623237MR@VEC", "AGD623231MR@VEC"), 
                 fuel_type = "electricity",
                 source = "vec")
#> Extracting 2 plans from 1 retailer
```

``` r


glimpse(agl)
#> Rows: 2
#> Columns: 19
#> $ type                <chr> "MARKET", "MARKET"
#> $ brand               <chr> "agl", "agl"
#> $ planId              <chr> "AGD623237MR@VEC", "AGD623231MR@VEC"
#> $ fuelType            <chr> "ELECTRICITY", "ELECTRICITY"
#> $ brandName           <chr> "AGL", "AGL"
#> $ displayName         <chr> "Residential Value Saver (Velocity) - New To AGL",…
#> $ lastUpdated         <chr> "2025-01-27T21:17:27Z", "2025-01-27T21:17:26Z"
#> $ customerType        <chr> "RESIDENTIAL", "RESIDENTIAL"
#> $ effectiveFrom       <chr> "2025-01-29T13:00:00Z", "2025-01-29T13:00:00Z"
#> $ terms               <chr> "Offer only available in areas where AGL operates.…
#> $ isFixed             <lgl> FALSE, FALSE
#> $ timeZone            <chr> "LOCAL", "LOCAL"
#> $ variation           <chr> "This plan also includes variable rates, retail fe…
#> $ pricingModel        <chr> "TIME_OF_USE_CONT_LOAD", "TIME_OF_USE"
#> $ coolingOffDays      <int> 10, 10
#> $ onExpiryDescription <chr> "Your market contract is ongoing. From time to tim…
#> $ distributor         <chr> "AusNet Services (electricity)", "United Energy"
#> $ included_postcodes  <chr> "3061, 3062, 3064, 3074, 3075, 3076, 3082, 3083, 3…
#> $ contract            <list> [<tbl_df[112 x 2]>], [<tbl_df[107 x 2]>]
```

You can also get all the plans from a specified retailer or all the
plans available in the market. However, the code will take a long time
to process the data in a clean format.

``` r

agl_all <- read_eprd(retailer = "agl",
                 planid = "all", 
                 fuel_type = "all",
                 source = "all")

all_plans <- read_eprd(retailer = "all",
                 planid = "all", 
                 fuel_type = "all",
                 source = "all")
```
