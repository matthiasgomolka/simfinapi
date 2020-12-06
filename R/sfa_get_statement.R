#' Get basic company information
#' @inheritParams sfa_get_statement
#' @importFrom data.table transpose as.data.table setnames set setcolorder
#'   rbindlist
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

  query_list <- list(
    "ticker" = Ticker,
    "statement" = statement,
    "period" = period,
    "fyear" = fyear,
    "start" = start,
    "end" = end,
    "api-key" = api_key
  )
  if (isTRUE(ttm)) {
    query_list[["ttm"]] <- ""
  }
  if (isTRUE(shares)) {
    query_list[["shares"]] <- ""
  }

  content <- call_api(
    path = "api/v2/companies/statements",
    query = query_list,
    cache_dir = cache_dir
  )

  # lapply necessary for SimFin+, where larger queries are possible
  DT_list <- lapply(content, function(x) {
    if (isFALSE(x[["found"]])) {
      warning('No company found for Ticker "', Ticker, '".', call. = FALSE)
      return(NULL)
    }
    DT <- data.table::transpose(data.table::as.data.table(x[["data"]]))

    # remove duplicate column names and set those
    duplicates <- which(duplicated(x[["columns"]]))
    x[["columns"]][duplicates] <- paste0(x[["columns"]][duplicates], "_2")
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
    values = "Currency",
    after = which(names(DT) == "Value Check")
  )
  data.table::setcolorder(DT, col_order)

  char_vars <- c("Ticker", "Fiscal Period", "Source", "Currency")
  date_vars <- c("Report Date", "Publish Date", "Restated Date")
  lgl_vars <- c("TTM", "Value Check")
  int_vars <- c("SimFinId", "Fiscal Year")
  num_vars <- setdiff(names(DT), c(char_vars, date_vars, lgl_vars, int_vars))

  set_as(DT, date_vars, as.Date)
  set_as(DT, lgl_vars, as.logical)
  set_as(DT, int_vars, as.integer)
  set_as(DT, num_vars, as.numeric)

  return(DT)

}

#' Get basic company information
#' @param Ticker [integer] Ticker of the companies of interest.
#' @param SimFinId [integer] 'SimFin' IDs of the companies of interest. Any
#'   SimFinId will be internally translated to the respective `Ticker`. This
#'   reduces the number of queries if you would query the same company via
#'   `Ticker` *and* `SimFinId`.
#' @param statement [character] Statement to be retrieved. One of
#'
#'   - `"pl"`: Profit & Loss statement
#'   - `"bs"`: Balance Sheet
#'   - `"cf"`: Cash Flow statement
#'   - `"derived"`: Derived figures & fundamental ratios
#'   - `"all"`: Retrieves all 3 statements + ratios. Please note that this
#'   option is reserved for SimFin+ users.
#' @param period [character] Filter for periods. As a non-SimFin+ user, you have
#'   to provide exactly one period. As SimFin+ user, this filter can be omitted
#'   to retrieve all statements available for the company.
#'
#'   - `"q1"`: First fiscal quarter.
#'   - `"q2"`: Second fiscal quarter.
#'   - `"q3"`: Third fiscal quarter.
#'   - `"q4"`: Fourth fiscal quarter.
#'   - `"fy"`: Full fiscal year.
#'   - `"h1"`: First 6 months of fiscal year.
#'   - `"h2"`: Last 6 months of fiscal year.
#'   - `"9m"`: First nine months of fiscal year.
#'   - `"6m"`: Any fiscal 6 month period (first + second half years; reserved
#'   for SimFin+ users).
#'   - `"quarters"`: All quarters (q1 + q2 + q3 + q4; reserved for SimFin+
#'   users).
#'
#' @param fyear [integer] Filter for fiscal year. As a non-SimFin+ user, you
#'   have to provide exactly one fiscal year. As SimFin+ user, this filter can
#'   be omitted to retrieve all statements available for the company.
#' @param start [Date] Filter for the report dates (reserved for SimFin+ users).
#'   With this filter you can filter the statements by the date on which the
#'   reported period ended ('Report Date'). By specifying a value here, only
#'   statements will be retrieved with report dates ending AFTER the specified
#'   date.
#' @param end [Date] Filter for the report dates (reserved for SimFin+ users).
#'   With this filter you can filter the statements by the date on which the
#'   reported period ended ('Report Date'). By specifying a value here, only
#'   statements will be retrieved with report dates ending BEFORE the specified
#'   date.
#' @param ttm [logical] If `TRUE`, you can return the trailing twelve months
#'   statements for all periods, meaning at every available point in time the
#'   sum of the last 4 available quarterly figures.
#' @param shares [logical] If `TRUE`, you can display the weighted average basic
#'   & diluted shares outstanding for each period along with the fundamentals.
#'   Reserved for SimFin+ users (as non-SimFin+ user, you can still use the
#'   shares outstanding endpoints).
#' @param api_key [character] Your 'SimFin' API key. It's recommended to set
#'   the API key globally using [sfa_set_api_key].
#' @param cache_dir [character] Your cache directory. It's recommended to set
#'   the cache directory globally using [sfa_set_cache_dir].
#' @importFrom checkmate assert_choice
#' @importFrom future.apply future_lapply
#' @importFrom progressr with_progress progressor
#' @export
sfa_get_statement <- function(
  Ticker = NULL,
  SimFinId = NULL,
  statement,
  period = "fy",
  fyear = NULL,
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
  if (!is.null(fyear)) fyear <- paste(fyear, collapse = ",")

  progressr::with_progress({
    prg <- progressr::progressor(along = ticker)
    result_list <- future.apply::future_lapply(ticker, function(x) {
      prg(x)
      sfa_get_statement_(
        Ticker = x, statement, period, fyear, start, end, ttm, shares, api_key,
        cache_dir
      )
    },
    future.seed = TRUE)
  })

  gather_result(result_list)
}
