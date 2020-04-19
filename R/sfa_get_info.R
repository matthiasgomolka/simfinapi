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

  if (!is.null(content)) {
    data.table::setDT(content)
  } else {
    content <- data.table::data.table(
      simId = integer(),
      ticker = character(),
      name = character(),
      fyearEnd = integer(),
      employees = integer(),
      sectorName = character(),
      sectorCode = integer()
    )
  }
  content
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
