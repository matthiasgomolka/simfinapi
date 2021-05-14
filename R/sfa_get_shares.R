#' Shares Outstanding
#' @inheritParams sfa_get_shares
#' @importFrom data.table as.data.table setnames set setcolorder rbindlist
sfa_get_shares_ <- function(
  ticker,
  type,
  period,
  fyear,
  start,
  end,
  api_key,
  cache_dir
) {

  content <- call_api(
    path = "api/v2/companies/shares",
    query = list(
      "ticker" = ticker,
      "type" = type,
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
      warning('No company found for ticker "', ticker, '".', call. = FALSE)
      return(NULL)
    }
    DT <- as.data.table(
      matrix(unlist(x[["data"]]), ncol = length(x[["columns"]]), byrow = TRUE)
    )
    data.table::setnames(DT, x[["columns"]])
  })

  DT <- data.table::rbindlist(DT_list, use.names = TRUE)
  if (nrow(DT) == 0L) {
    return(NULL)
  }

  # prettify DT
  set_as(DT, "SimFinId", as.integer)
  set_as(DT, "Date", as.Date)
  set_as(DT, "Value", as.numeric)

  return(DT)
}

#' Shares Outstanding
#' @param type [character] Type of shares outstanding to be retrieved.
#'
#'   - `"common"`: Common shares outstanding.
#'   - `"wa-basic"`: Weighted average basic shares outstanding for a period.
#'   - `"wa-diluted"`: Weighted average diluted shares outstanding for a period.
#' @param period [character] Filter for periods. Only works with `type =
#'   "wa-basic"` and `type = "wa-diluted"`. This filter can be omitted to
#'   retrieve all shares outstanding available for the company. You can also
#'   chain this filter with a comma (e.g. `period = "quarters,fy"` to retrieve
#'   all quarters and the full financial year figures).
#'
#'   - `"q1"`: First fiscal quarter.
#'   - `"q2"`: Second fiscal quarter.
#'   - `"q3"`: Third fiscal quarter.
#'   - `"q4"`: Fourth fiscal quarter.
#'   - `"fy"`: Full fiscal year.
#'   - `"h1"`: First 6 months of fiscal year.
#'   - `"h2"`: Last 6 months of fiscal year.
#'   - `"9m"`: First nine months of fiscal year.
#'   - `"6m"`: Any fiscal 6 month period (first + second half years).
#'   - `"quarters"`: All quarters (q1 + q2 + q3 + q4).
#' @param fyear [character] Filter for fiscal year. Only works with `type =
#'   "wa-basic"` and `type = "wa-diluted"`. As SimFin+ user, this filter can be
#'   omitted to retrieve all shares outstanding available for the company. You
#'   can also chain this filter with a comma, to retrieve multiple years at once
#'   (e.g. `fyear = "2015,2016,2017"` to retrieve the data for 3 years at once).
#' @inheritParams sfa_get_statement
#' @importFrom checkmate assert_choice
#' @importFrom future.apply future_lapply
#' @importFrom progressr with_progress progressor
#' @export
sfa_get_shares <- function(
  ticker = NULL,
  simfin_id = NULL,
  type,
  period = "fy",
  fyear = data.table::year(Sys.Date()) - 1L,
  start = NULL,
  end = NULL,
  api_key = getOption("sfa_api_key"),
  cache_dir = getOption("sfa_cache_dir")
) {
  check_inputs(
    ticker = ticker,
    simfin_id = simfin_id,
    type = type,
    period = period,
    fyear = fyear,
    start = start,
    end = end,
    api_key = api_key,
    cache_dir = cache_dir
  )

  ticker <- gather_ticker(ticker, simfin_id, api_key, cache_dir)

  progressr::with_progress({
    prg <- progressr::progressor(along = ticker)
    result_list <- future.apply::future_lapply(ticker, function(x) {
      prg(x)
      sfa_get_shares_(
        ticker = x, type, period, fyear, start, end, api_key, cache_dir
      )
    },
    future.seed = TRUE)
  })

  gather_result(result_list)
}
