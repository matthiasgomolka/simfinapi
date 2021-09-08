#' Generic input checks
#' @description This function covers all kinds of (recurring) input checks in
#'   {simfinapi}. This keeps the other functions cleaner.
#' @inheritParams sfa_get_info
#' @inheritParams sfa_get_statement
#' @inheritParams sfa_get_prices
#' @inheritParams sfa_get_shares
#' @inheritParams sfa_get_ref
#' @importFrom checkmate assert_string assert_directory assert_logical
#'   assert_character assert_integerish assert_choice assert_date
#' @importFrom data.table year
check_inputs <- function(
  api_key = NULL, cache_dir = NULL, sfplus = NULL, ticker = NULL,
  simfin_id = NULL, statement = NULL, period = NULL, fyear = NULL, start = NULL,
  end = NULL, ttm = NULL, shares = NULL, ratios = NULL, type = NULL,
  ref_data = NULL
) {
  if (!is.null(api_key)) {
    checkmate::assert_string(api_key, pattern = "^[[:alnum:]]{32}$")
  }
  if (!is.null(cache_dir)) {
    checkmate::assert_directory(cache_dir, access = "rw")
  }
  if (!is.null(sfplus)) {
    checkmate::assert_logical(sfplus, len = 1L)
  }
  if (!is.null(ticker)) {
    checkmate::assert_character(
      ticker,
      pattern = "^[A-Za-z0-9_\\.\\-]+$",
      any.missing = FALSE,
      null.ok = TRUE
    )
  }
  if (!is.null(simfin_id)) {
    checkmate::assert_integerish(
      simfin_id,
      lower = 1L,
      any.missing = FALSE,
      null.ok = TRUE
    )
  }
  if (!is.null(statement)) {
    checkmate::assert_choice(
      statement,
      c("pl", "bs", "cf", "derived", "all"),
      fmatch = TRUE
    )
  }
  if (!is.null(period)) {
    checkmate::assert_choice(
      period,
      c("q1", "q2", "q3", "q4", "fy", "h1", "h2", "9m", "6m", "quarters"),
      fmatch = TRUE
    )
  }
  if (!is.null(fyear)) {
    checkmate::assert_integerish(
      fyear,
      lower = 1900L,
      upper = data.table::year(Sys.Date())
    )
  }
  if (!is.null(start)) {
    checkmate::assert_date(
      start,
      lower = as.Date("1900-01-01"),
      upper = Sys.Date()
    )
  }
  if (!is.null(end)) {
    checkmate::assert_date(
      end,
      lower = as.Date("1900-01-01"),
      upper = Sys.Date()
    )
  }
  if (!is.null(ttm)) {
    checkmate::assert_logical(ttm, any.missing = FALSE, len = 1L)
  }
  if (!is.null(shares)) {
    checkmate::assert_logical(shares, any.missing = FALSE, len = 1L)
  }
  if (!is.null(ratios)) {
    checkmate::assert_logical(ratios, any.missing = FALSE, len = 1L)
  }
  if (!is.null(type)) {
    checkmate::assert_choice(
      type,
      choices = c("common", "wa-basic", "wa-diluted"),
      fmatch = TRUE
    )
  }
  if (!is.null(ref_data)) {
    checkmate::assert_choice(
      ref_data,
      choices = c("industries", "markets"),
      fmatch = TRUE
    )
  }
}


#' @param api_key See function using this argument.
#' @param cache_dir See function using this argument.
#' @param ticker See function using this argument.
#' @param simfin_id See function using this argument.
#' @param statement See function using this argument.
#' @param period See function using this argument.
#' @param fyear See function using this argument.
#' @param start See function using this argument.
#' @param end See function using this argument.
#' @param ttm See function using this argument.
#' @param shares See function using this argument.
#' @param ratios See function using this argument.
#' @param type See function using this argument.
