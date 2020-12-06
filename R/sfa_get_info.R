#' Get basic company information
#' @description Internal function.
#' @param ticker [integer] Ticker of the companies of interest.
#' @param api_key `[character(1)]` Your 'SimFin' API key. For simplicity use
#'   `options(sfa_api_key = "yourapikey")`.
#' @param cache_dir [character] Your cache directory. It's recommended to set
#'   the cache directory globally using [sfa_set_cache_dir].
#' @importFrom data.table as.data.table
sfa_get_info_ <- function(ticker, api_key, cache_dir) {
  content <- call_api(
    path = list("api/v2/companies/general"),
    query = list(
      "ticker" = ticker,
      "api-key" = api_key
    ),
    cache_dir = cache_dir
  )

  DT_list <- lapply(content, function(x) {
    if (isFALSE(x[["found"]])) {
      warning('No company found for Ticker "', ticker, '".', call. = FALSE)
      return(NULL)
    }
    DT <- data.table::as.data.table(lapply(x[["data"]], t))
    data.table::setnames(DT, x[["columns"]])
  })

  DT <- data.table::rbindlist(DT_list, use.names = TRUE)
  if (nrow(DT) == 0L) {
    return(NULL)
  }

  for (var in c("SimFinId", "IndustryId", "Month FY End", "Number Employees")) {
    data.table::set(DT, j = var, value = as.integer(DT[[var]]))
  }

  return(DT)
}

#' Get basic company information
#' @param Ticker [integer] Ticker of the companies of interest.
#' @param SimFinId [integer] 'SimFin' IDs of the companies of interest. Any
#'   SimFinId will be internally translated to the respective `Ticker`. This
#'   reduces the number of queries if you would query the same company via
#'   `Ticker` *and* `SimFinId`.
#' @param api_key [character] Your 'SimFin' API key. It's recommended to set
#'   the API key globally using [sfa_set_api_key].
#' @param cache_dir [character] Your cache directory. It's recommended to set
#'   the cache directory globally using [sfa_set_cache_dir].
#' @importFrom checkmate assert_character assert_integerish assert_string
#'   assert_directory
#' @importFrom future.apply future_lapply
#' @importFrom progressr with_progress progressor
#' @export
sfa_get_info <- function(
  Ticker = NULL,
  SimFinId = NULL,
  api_key = getOption("sfa_api_key"),
  cache_dir = getOption("sfa_cache_dir")
) {
  check_inputs(
    Ticker = Ticker,
    SimFinId = SimFinId,
    api_key = api_key,
    cache_dir = cache_dir
  )
  if (all(is.null(Ticker), is.null(SimFinId))) {
    stop("You need to specify at least one 'Ticker' or 'SimFinId")
  }

  # translate SimFinId to Ticker to simplify API call
  ticker <- gather_ticker(Ticker, SimFinId, api_key, cache_dir)

  progressr::with_progress({
    prg <- progressr::progressor(along = ticker)
    result_list <- future.apply::future_lapply(ticker, function(x) {
      prg(x)
      sfa_get_info_(ticker = x, api_key, cache_dir)
    },
    future.seed = TRUE)
  })
  gather_result(result_list)
}
