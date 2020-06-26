#' Get basic company information
#' @param simId `[integer(1)]` SimFin ID of the company of interest.
#' @param api_key `[character(1)]` Your SimFin API key. For simplicity use
#'   `option(sfa_api_key = "yourapikey")`.
#' @importFrom data.table data.table set .SD
sfa_get_ratios_ <- function(
  simId,
  api_key = getOption("sfa_api_key")
) {
  content <- call_api(
    path = sprintf("api/v1/companies/id/%s/ratios", simId),
    query = list("api-key" = api_key)
  )

  # return early of no content returned
  if (is.null(content)) {
    return(NULL)
  }

  dt <- data.table::setDT(content)
  data.table::set(dt, j = "simId", value = simId)
  data.table::set(dt, j = "value", value = as.numeric(dt[["value"]]))
  data.table::set(
    dt, j = "period-end-date", value = as.Date(dt[["period-end-date"]])
  )
  data.table::setnames(dt, "period-end-date", "period_end_date") # for consistency
  data.table::setcolorder(dt, "simId")

  dt
}

#' Get basic company information
#' @param simIds `[integer]` SimFin IDs of the companies of interest.
#' @param api_key `[character(1)]` Your SimFin API key. For simplicity use
#'   `options(sfa_api_key = "yourapikey")`.
#' @importFrom checkmate assert_choice
#' @importFrom future.apply future_lapply
#' @importFrom data.table rbindlist
#' @export
sfa_get_ratios <- function(
  simIds,
  api_key = getOption("sfa_api_key")
) {
  result_list <- future.apply::future_lapply(simIds, sfa_get_ratios_, api_key)
  data.table::rbindlist(result_list)
}
