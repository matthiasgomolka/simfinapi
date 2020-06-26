#' Get basic company information
#' @param simId `[integer(1)]` SimFin ID of the company of interest.
#' @param api_key `[character(1)]` Your SimFin API key. For simplicity use
#'   `options(sfa_api_key = "yourapikey")`.
#' @importFrom data.table as.data.table
sfa_get_info_ <- function(
  simId,
  api_key = Sys.getenv("sfa_api_key")
) {
  content <- call_api(
    path = list("api/v1/companies/id", simId),
    query = list("api-key" = api_key)
  )

  # return early if no content returnded
  if (is.null(content)) {
    return(NULL)
  }

  # set NULL values to NA to avoid errors in setDT
  # (as.data.table is no options since it omits NULL elements)
  content[which(vapply(content, is.null, FUN.VALUE = logical(1L)))] <- NA

  dt <- data.table::setDT(content)
  data.table::set(dt, j = "simId", value = as.integer(dt[["simId"]]))
  data.table::set(dt, j = "ticker", value = as.character(dt[["ticker"]]))
  data.table::set(dt, j = "name", value = as.character(dt[["name"]]))
  data.table::set(dt, j = "fyearEnd", value = as.integer(dt[["fyearEnd"]]))
  data.table::set(dt, j = "employees", value = as.integer(dt[["employees"]]))
  data.table::set(dt, j = "sectorName", value = as.character(dt[["sectorName"]]))
  data.table::set(dt, j = "sectorCode", value = as.integer(dt[["sectorCode"]]))
  dt
}

#' Get basic company information
#' @param simId `[integer]` SimFin IDs of the companies of interest.
#' @param api_key `[character(1)]` Your SimFin API key. For simplicity use
#'   `options(sfa_api_key = "yourapikey")`.
#' @importFrom checkmate assert_integerish assert_string
#' @importFrom future.apply future_lapply
#' @importFrom data.table rbindlist
#' @export
sfa_get_info <- function(
  simId,
  api_key = getOption("sfa_api_key")
) {
  simId <- checkmate::assert_integerish(
    simId,
    lower = 1L,
    upper = 999999L,
    coerce = TRUE
  )
  checkmate::assert_string(api_key, pattern = "[[:alnum:]]{32}")

  result_list <- future.apply::future_lapply(simId, sfa_get_info_, api_key)
  gather_result(result_list)
}
