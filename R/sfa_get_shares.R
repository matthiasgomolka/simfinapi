#' @importFrom data.table as.data.table setnames set setcolorder rbindlist
#' @importFrom bit64 as.integer64
sfa_get_shares_ <- function(
  ticker,
  type,
  period,
  fyear,
  start,
  end,
  api_key,
  cache_dir,
  sfplus
) {

  response_light <- call_api(
    path = "api/v2/companies/shares",
    query = list(
      "ticker" = paste(ticker, collapse = ","),
      "type" = type,
      "period" = period,
      "fyear" = fyear,
      "start" = start,
      "end" = end,
      "api-key" = api_key
    ),
    cache_dir = cache_dir
  )
  content <- response_light[["content"]]

  warn_not_found(content, ticker)

  type_name <- paste0("Shares Outstanding (", type, ")")

  # lapply necessary for SimFin+, where larger queries are possible
  DT_list <- lapply(content, function(x) {
    if (isFALSE(x[["found"]])) {
      return(NULL)
    }
    DT <- as.data.table(
      matrix(unlist(x[["data"]]), ncol = length(x[["columns"]]), byrow = TRUE)
    )
    val_col <-
      x[["columns"]][x[["columns"]] == "Value"] <- type_name
    data.table::setnames(DT, x[["columns"]])
  })

  DT <- data.table::rbindlist(DT_list, use.names = TRUE)
  if (nrow(DT) == 0L) {
    return(NULL)
  }

  # prettify DT
  set_as(DT, "SimFinId", as.integer)
  if ("Date" %in% names(DT)) set_as(DT, "Date", as.Date)
  if ("Fiscal Year" %in% names(DT)) set_as(DT, "Fiscal Year", as.integer)
  if ("Report Date" %in% names(DT)) set_as(DT, "Report Date", as.Date)
  if ("TTM" %in% names(DT)) set_as(DT, "TTM", as.logical)
  set_as(DT, type_name, bit64::as.integer64)

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
#' @param period [character] Filter for periods. Only works with `type =
#'   wa-basic` and `type = wa-diluted`. This filter can be omitted to retrieve
#'   all shares outstanding available for the company.
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
#'
#'   You can select several periods by passing several of the above items at
#'   once, e.g. `period = c("q1", "q2")`.
#'
#' @section Fiscal year: Only works with `type = "wa-basic"` and `type =
#'   "wa-diluted"`.
#'
#' @inheritSection param_doc Parallel processing
#'
#' @importFrom checkmate assert_choice
#' @importFrom future.apply future_mapply
#' @importFrom progressr with_progress progressor
#' @importFrom data.table year CJ
#'
#' @export
#'
sfa_get_shares <- function(
  ticker = NULL,
  simfin_id = NULL,
  type,
  period = NULL,
  fyear = NULL,
  start = NULL,
  end = NULL,
  api_key = getOption("sfa_api_key"),
  cache_dir = getOption("sfa_cache_dir"),
  sfplus = getOption("sfa_sfplus", default = FALSE)
) {

  check_sfplus(sfplus)
  check_ticker(ticker)
  check_simfin_id(simfin_id)
  check_type(type)
  check_period_get_shares(period, sfplus, called_from_get_shares = TRUE)
  check_fyear_get_shares(fyear, sfplus, type = type)
  check_start(start, sfplus)
  check_end(end, sfplus)
  check_api_key(api_key)
  check_cache_dir(cache_dir)

  ticker <- gather_ticker(ticker, simfin_id, api_key, cache_dir)

  if (isTRUE(sfplus)) {
    # split list of tickers into chunks of 200. This is a workaround for very
    # large requests. See https://github.com/matthiasgomolka/simfinapi/issues/34
    # for details.
    ticker_list <- split(ticker, ceiling(seq_along(ticker) / 200L))

    progressr::with_progress({
      prg <- progressr::progressor(steps = length(ticker_list))

      results <- future.apply::future_lapply(
        ticker_list,
        function(ticker) {
          res <- sfa_get_shares_(
            ticker = ticker,
            type = type,
            period = period,
            fyear = {if (is.null(fyear)) NULL else paste(fyear, collapse = ",")},
            start = start,
            end = end,
            api_key = api_key,
            cache_dir = cache_dir,
            sfplus = sfplus
          )
          prg(ticker)
          return(res)
        },
        future.seed = TRUE
      )
    })
  } else {
    progressr::with_progress({
      if (type == "common") {
        grid <- data.table::CJ(
          ticker = ticker,
          fyear = data.table::year(Sys.Date())
          # data.table::year(Sys.Date()) is a placeholder, because fyear is only
          # relevant for types "wa-basic" and "wa-diluted"
        )
      } else {
        grid <- data.table::CJ(ticker = ticker, fyear = fyear)
      }

      prg <- progressr::progressor(steps = nrow(grid))
      results <- future.apply::future_mapply(
        function(ticker, fyear) {
          prg(ticker)
          sfa_get_shares_(
            ticker, type, period, fyear, start, end, api_key, cache_dir, sfplus
          )
        },
        ticker = grid[["ticker"]],
        fyear = grid[["fyear"]],
        SIMPLIFY = FALSE,
        future.seed = TRUE
      )
    })
  }
  gather_result(results)
}
