sfa_get_prices_ <- function(
  ticker,
  ratios,
  start,
  end,
  api_key,
  cache_dir
) {
  query_list <- list(
    "ticker" = ticker,
    "start" = start,
    "end" = end,
    "api-key" = api_key
  )

  if (isTRUE(ratios)) {
    query_list[["ratios"]] <- ""
  }

  content <- call_api(
    path = "api/v2/companies/prices",
    query = query_list,
    cache_dir = cache_dir
  )

  # lapply necessary for SimFin+, where larger queries are possible
  DT_list <- lapply(content, function(x) {
    if (isFALSE(x[["found"]])) {
      warning('No company found for ticker "', ticker, '".', call. = FALSE)
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
  # if ("Currency" %in% names(DT)) { # Currency may be missing
  col_order <- append(
    setdiff(names(DT), "Currency"),
    values = "Currency",
    after = which(names(DT) == "Date")
  )
  data.table::setcolorder(DT, col_order)
  # } else {
  #   browser()
  #   char_vars <- "ticker"
  # }

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
#' @param ratios [logical] With `TRUE`, you can display some price related ratios along with the share price data (reserved for SimFin+ users). The ratios that will be displayed are:
#'
#'   - Market-Cap
#'   - Price to Earnings Ratio (quarterly)
#'   - Price to Earnings Ratio (ttm)
#'   - Price to Sales Ratio (quarterly)
#'   - Price to Sales Ratio (ttm)
#'   - Price to Book Value (ttm)
#'   - Price to Free Cash Flow (quarterly)
#'   - Price to Free Cash Flow (ttm)
#'   - Enterprise Value (ttm)
#'   - EV/EBITDA (ttm)
#'   - EV/Sales (ttm)
#'   - EV/FCF (ttm)
#'   - Book to Market Value (ttm)
#'   - Operating Income/EV (ttm).
#' @inheritParams sfa_get_statement
#' @importFrom future.apply future_lapply
#' @importFrom progressr with_progress progressor
#' @export
sfa_get_prices <- function(
  ticker = NULL,
  simfin_id = NULL,
  ratios = NULL,
  start = NULL,
  end = NULL,
  api_key = getOption("sfa_api_key"),
  cache_dir = getOption("sfa_cache_dir")
) {
  check_inputs(
    ticker = ticker,
    simfin_id = simfin_id,
    ratios = ratios,
    start = start,
    end = end,
    api_key = api_key,
    cache_dir = cache_dir
  )

  ticker <- gather_ticker(ticker, simfin_id, api_key, cache_dir)

  if (length(ticker) == 0L) return(invisible(NULL))

  progressr::with_progress({
    prg <- progressr::progressor(along = ticker)
    result_list <- future.apply::future_lapply(ticker, function(x) {
      prg(x)
      sfa_get_prices_(ticker = x, ratios, start, end, api_key, cache_dir)
    },
    future.seed = TRUE)
  })

  gather_result(result_list)
}
