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
#'
#' @description Common shares outstanding (point-in-time) and weighted average
#'   basic/diluted shares outstanding for all periods can be retrieved here.
#'   These shares are the aggregate figures for the entire company. If you are
#'   interested in more details, take a look at this page:
#'   https://simfin.com/data/help/main?topic=apiv2-shares
#'
#' @inheritParams param_doc
#'
#' @param type [character] Type of shares outstanding to be retrieved.
#'
#'   - `"common"`: Common shares outstanding.
#'   - `"wa-basic"`: Weighted average basic shares outstanding for a period.
#'   - `"wa-diluted"`: Weighted average diluted shares outstanding for a period.
#'
#' @section Fiscal year:
#' Only works with `type = "wa-basic"` and `type = "wa-diluted"`.
#'
#' @inheritSection param_doc Parallel processing
#'
#' @importFrom checkmate assert_choice
#' @importFrom future.apply future_lapply
#' @importFrom progressr with_progress progressor
#'
#' @export
#'
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
