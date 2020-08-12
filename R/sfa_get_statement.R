#' Get basic company information
#' @param simId `[integer(1)]` SimFin ID of the company of interest.
#' @param statement `[character(1)]` One of "pl" (Profit and Loss), "bs"
#'   (Balance Sheet), "cf" (Cash Flow).
#' @param period `[character(1)]` One of "Q1" "Q2" "Q3" "Q4" "H1" "H2" "9M" "FY"
#'   "TTM". See `ptype` on
#'   https://simfin.com/api/v1/documentation/#operation/getCompStatementStandardised
#'   for details.
#' @param fyear `[integer(1)]` The financial year of interest.
#' @param api_key `[character(1)]` Your SimFin API key. For simplicity use
#'   `option(sfa_api_key = "yourapikey")`.
#' @importFrom data.table as.data.table setnames set setcolorder rbindlist
sfa_get_statement_ <- function(
  Ticker,
  statement,
  period,
  fyear,
  start,
  end,
  ttm,
  shares,
  api_key,
  cache_dir
) {
  # hack ttm and statement into the query since GET cannot handle such
  # parameters (at least I don't know how)
  if (isTRUE(ttm)) {
    statement <- paste0(statement, "&ttm")
  }
  if (isTRUE(shares)) {
    statement <- paste0(statement, "&shares")
  }

  content <- call_api(
    path = "api/v2/companies/statements",
    query = list(
      "ticker" = Ticker,
      "statement" = statement,
      "period" = period,
      "fyear" = fyear,
      "start" = start,
      "end" = end,
      "api-key" = api_key
    ),
    cache_dir = cache_dir
  )

  # lapply necessary for SimFin+, where larger queries are possible
  DT_list <- lapply(content, function(x) {
    if (isFALSE(x[["found"]])) {
      warning('No company found for Ticker "', ticker, '".', call. = FALSE)
      return(NULL)
    }
    DT <- data.table::as.data.table(lapply(x[["data"]], t))
    data.table::setnames(DT, x[["columns"]])

    data.table::set(DT, j = "Currency", value = x[["currency"]])
  })

  DT <- data.table::rbindlist(DT_list, use.names = TRUE)
  if (nrow(DT) == 0L) {
    return(NULL)
  }

  # prettify DT
  col_order <- append(
    setdiff(names(DT), "Currency"),
    "Currency",
    which(names(DT) == "Value Check")
  )
  data.table::setcolorder(DT, col_order)

  char_vars <- c("Ticker", "Fiscal Period", "Source", "Currency")
  date_vars <- c("Report Date", "Publish Date", "Restated Date")
  lgl_vars <- c("TTM", "Value Check")
  int_vars <- c("SimFinId", "Fiscal Year")
  num_vars <- setdiff(names(DT), c(char_vars, date_vars, lgl_vars, int_vars))

  setmany(DT, date_vars, as.Date)
  setmany(DT, lgl_vars, as.logical)
  setmany(DT, int_vars, as.integer)
  setmany(DT, num_vars, as.numeric)

  return(DT)

}

#' Get basic company information
#' @param simIds `[integer]` SimFin IDs of the companies of interest.
#' @param statement `[character(1)]` One of "pl" (Profit and Loss), "bs"
#'   (Balance Sheet), "cf" (Cash Flow).
#' @param period `[character(1)]` One of "Q1" "Q2" "Q3" "Q4" "H1" "H2" "9M" "FY"
#'   "TTM". See `ptype` on
#'   https://simfin.com/api/v1/documentation/#operation/getCompStatementStandardised
#'   for details.
#' @param fin_year `[integer(1)]` The financial year of interest.
#' @param api_key `[character(1)]` Your SimFin API key. For simplicity use
#'   `options(sfa_api_key = "yourapikey")`.
#' @importFrom checkmate assert_choice
#' @importFrom future.apply future_lapply
#' @importFrom data.table year rbindlist
#' @export
sfa_get_statement <- function(
  Ticker = NULL,
  SimFinId = NULL,
  statement,
  period = "fy",
  fyear = data.table::year(Sys.Date()) - 1L,
  start = NULL,
  end = NULL,
  ttm = FALSE,
  shares = FALSE,
  api_key = getOption("sfa_api_key"),
  cache_dir = getOption("sfa_cache_dir")
) {
  check_inputs(
    Ticker = Ticker,
    SimFinId = SimFinId,
    statement = statement,
    period = period,
    fyear = fyear,
    start = start,
    end = end,
    api_key = api_key,
    cache_dir = cache_dir
  )

  ticker <- gather_ticker(Ticker, SimFinId, api_key, cache_dir)

  result_list <- future.apply::future_lapply(
    Ticker, sfa_get_statement_, statement, period, fyear, start, end, ttm,
    shares, api_key, cache_dir
  )
  gather_result(result_list)
}
