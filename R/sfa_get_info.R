#' Get basic company information
#' @param simId `[integer(1)]` SimFin ID of the company of interest.
#' @param api_key `[character(1)]` Your SimFin API key. For simplicity use `Sys.setenv(sfa_api_key = "yourapikey")`.
#' @importFrom data.table as.data.table
sfa_get_info_ <- function(simId,
                          api_key = Sys.getenv("sfa_api_key")) {
  api_call <- paste0(
    Sys.getenv("sfa_api"),
    "companies/id/", simId,
    "?api-key=", api_key
  )

  data.table::setDT(sfa_memoise_fromJSON(api_call))
}

#' Get basic company information
#' @param simIds `[integer]` SimFin IDs of the companies of interest.
#' @param api_key `[character(1)]` Your SimFin API key. For simplicity use `sys.setenv(sfa_api_key = "yourapikey")`.
#' @importFrom future.apply future_lapply
#' @importFrom data.table rbindlist
sfa_get_info <- function(simIds,
                         api_key = options("sfa_api_key")) {
  result_list <- future.apply::future_lapply(simIds, sfa_get_info_, api_key)
  dt <- data.table::rbindlist(result_list)
  data.table::setkeyv(dt, Sys.getenv("sfa_key_var"))
  return(dt)
}
