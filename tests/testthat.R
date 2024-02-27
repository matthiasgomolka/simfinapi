library(testthat)
library(checkmate)
library(simfinapi)
library(data.table)

on_cran <- function() {
    !identical(Sys.getenv("NOT_CRAN"), "true")
}

if (!on_cran()) {
    test_check("simfinapi")
}
