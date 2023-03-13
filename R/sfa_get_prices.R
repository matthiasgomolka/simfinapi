#' @importFrom data.table as.data.table setnames set rbindlist setcolorder
sfa_get_prices_ <- function(
  ticker,
  ratios = NULL,
  start = NULL,
  end = NULL,
  api_key,
  cache_dir,
  sfplus
) {
  query_list <- list(
    "ticker" = paste(ticker, collapse = ","),
    "start" = start,
    "end" = end,
    "api-key" = api_key
  )

  if (isTRUE(ratios)) {
    query_list[["ratios"]] <- ""
  }

  response_light <- call_api(
    path = "api/v2/companies/prices",
    query = query_list,
    cache_dir = cache_dir
  )
  content <- response_light[["content"]]

  warn_not_found(content, ticker)

  # lapply necessary for SimFin+, where larger queries are possible
  DT_list <- lapply(content, function(x) {
    if (isFALSE(x[["found"]])) {
      return(NULL)
    }
    DT <- data.table::as.data.table(
      matrix(unlist(x[["data"]]), ncol = length(x[["columns"]]), byrow = TRUE)
    )

    data.table::setnames(DT, x[["columns"]])

    data.table::set(
      DT,
      j = "Currency",
      # ifelse handles the case where c[["currency"]] is NULL
      value = ifelse(is.null(x[["currency"]]), NA_character_, x[["currency"]])
    )
    return(DT)
  })

  DT <- data.table::rbindlist(DT_list, use.names = TRUE)
  if (nrow(DT) == 0L) {
    return(NULL)
  }

  # prettify DT
  col_order <- append(
    setdiff(names(DT), "Currency"),
    values = "Currency",
    after = which(names(DT) == "Date")
  )
  data.table::setcolorder(DT, col_order)

  char_vars <- c("Ticker", "Currency")
  date_vars <- c("Date")
  int_vars <- c("SimFinId")
  num_vars <- setdiff(names(DT), c(char_vars, date_vars, int_vars))

  set_as(DT, date_vars, as.Date)
  set_as(DT, int_vars, as.integer)
  set_as(DT, num_vars, as.numeric)

  return(DT)
}


#' Get price data
#'
#' @description Share price data and ratios can be retrieved here. All share
#'   prices are adjusted for stock splits. If you are interested in more
#'   details, take a look at this page:
#'   https://www.simfin.com/data/help/main?topic=apiv2-prices
#'
#' @inheritParams param_doc
#'
#' @inheritSection param_doc Parallel processing
#'
#' @importFrom future.apply future_lapply
#' @importFrom progressr with_progress progressor
#'
#' @export
#'
sfa_get_prices <- function(
  ticker = NULL,
  simfin_id = NULL,
  ratios = NULL,
  start = NULL,
  end = NULL,
  api_key = getOption("sfa_api_key"),
  cache_dir = getOption("sfa_cache_dir"),
  sfplus = getOption("sfa_sfplus", default = FALSE)
) {

  check_sfplus(sfplus)
  check_ticker(ticker)
  check_simfin_id(simfin_id)
  check_ratios(ratios, sfplus)
  check_start(start, sfplus)
  check_end(end, sfplus)
  #check_api_key(api_key)
  check_cache_dir(cache_dir)

  ticker <- gather_ticker(ticker, simfin_id, api_key, cache_dir)

  if (length(ticker) == 0L) return(invisible(NULL)) # can I delete this since gather_ticker throws an error if there is no valid ticker / simfin_id?

  if (isTRUE(sfplus)) {
    # split list of tickers into chunks of 200. This is a workaround for very
    # large requests. See https://github.com/matthiasgomolka/simfinapi/issues/34
    # for details.
    ticker_list <- split(ticker, ceiling(seq_along(ticker) / 10L))

    progressr::with_progress({
      prg <- progressr::progressor(steps = length(ticker_list))

      results <- future.apply::future_lapply(
        ticker_list,
        function(ticker) {
          # browser()
          res <- sfa_get_prices_(
            ticker, ratios, start, end, api_key, cache_dir, sfplus
          )
          prg(ticker)
          return(res)
        }
      )
    })
  } else {
    progressr::with_progress({
      prg <- progressr::progressor(along = ticker)
      results <- future.apply::future_lapply(ticker, function(x) {
        prg(x)
        sfa_get_prices_(ticker = x, ratios, start, end, api_key, cache_dir)
      },
      future.seed = TRUE)
    })
  }
  gather_result(results)
}
