sfa_get_price_ <- function(
  Ticker,
  ratios,
  start,
  end,
  api_key,
  cache_dir
) {
  content <- call_api(
    path = "api/v2/companies/prices",
    query = list(
      "ticker" = Ticker,
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
    DT <-  as.data.table(matrix(unlist(x[["data"]]), ncol = length(x[["columns"]]), byrow = TRUE))

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
    which(names(DT) == "Date")
  )
  data.table::setcolorder(DT, col_order)

  char_vars <- c("Ticker", "Currency")
  date_vars <- c("Date")
  int_vars <- c("SimFinId")
  num_vars <- setdiff(names(DT), c(char_vars, date_vars, int_vars))

  setmany(DT, date_vars, as.Date)
  setmany(DT, int_vars, as.integer)
  setmany(DT, num_vars, as.numeric)

  return(DT)
}


#' @importFrom checkmate assert_int assert_string
#' @importFrom future.apply future_lapply
sfa_get_price <- function(
  Ticker = NULL,
  SimFinId = NULL,
  ratios = NULL,
  start = NULL,
  end = NULL,
  api_key = getOption("sfa_api_key"),
  cache_dir = getOption("sfa_cache_dir")
) {
  check_inputs(
    Ticker = Ticker,
    SimFinId = SimFinId,
    ratios = ratios,
    start = start,
    end = end,
    api_key = api_key,
    cache_dir = cache_dir
  )

  ticker <- gather_ticker(Ticker, SimFinId, api_key, cache_dir)

  result_list <- future.apply::future_lapply(
    ticker, sfa_get_price_, ratios, start, end, api_key, cache_dir
  )

  gather_result(result_list)
}
