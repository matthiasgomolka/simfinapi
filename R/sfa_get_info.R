#' @importFrom data.table as.data.table
sfa_get_info_ <- function(ticker, api_key, cache_dir, sfplus) {

  response_light <- call_api(
    path = list("api/v2/companies/general"),
    query = list(
      "ticker" = ticker,
      "api-key" = api_key
    ),
    cache_dir = cache_dir
  )
  content <- response_light[["content"]]

  DT_list <- lapply(content, function(x) {
    if (isFALSE(x[["found"]])) {
      warning('No company found for ticker "', ticker, '".', call. = FALSE)
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
#' @inheritParams param_doc
#'
#' @importFrom checkmate assert_character assert_integerish assert_string
#'   assert_directory
#' @importFrom future.apply future_lapply
#' @importFrom progressr with_progress progressor
#'
#' @export
#'
sfa_get_info <- function(
  ticker = NULL,
  simfin_id = NULL,
  api_key = getOption("sfa_api_key"),
  cache_dir = getOption("sfa_cache_dir"),
  sfplus = getOption("sfa_sfplus", default = FALSE)
) {

  # input checks
  check_sfplus(sfplus)
  check_ticker(ticker)
  check_simfin_id(simfin_id)
  check_api_key(api_key)
  check_cache_dir(cache_dir)

  # if (all(is.null(ticker), is.null(simfin_id))) {
  #   stop("You need to specify at least one 'ticker' or 'simfin_id")
  # }

  # translate simfin_id to ticker to simplify API call
  ticker <- gather_ticker(
    ticker = ticker,
    simfin_id = simfin_id,
    api_key = api_key,
    cache_dir = cache_dir
  )

  if (isTRUE(sfplus)) { # SimFin+ users make a single API call
    results <- sfa_get_info_(
      ticker = paste(ticker, collapse = ","),
      api_key = api_key,
      cache_dir = cache_dir,
      sfplus = sfplus
    )

  } else { # normal users make several API calls
    progressr::with_progress({
      prg <- progressr::progressor(along = ticker)
      results <- future.apply::future_lapply(ticker, function(x) {
        prg(x)
        sfa_get_info_(
          ticker = x,
          api_key = api_key,
          cache_dir = cache_dir,
          sfplus = sfplus
        )
      },
      future.seed = TRUE
      )
    })
  }
  gather_result(results)
}
