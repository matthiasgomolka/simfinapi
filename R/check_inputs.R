msg_sfplus_required <- function(var, verb = "Omitting") {
  stop(verb, " '", var, "' is reserved for SimFin+ users.", call. = FALSE)
}

#' @importFrom checkmate assert_string
check_api_key <- function(api_key) {
  checkmate::assert_string(api_key, pattern = "^[[:alnum:]]{32}$")
}

#' @importFrom checkmate assert_directory
check_cache_dir <- function(cache_dir) {
  checkmate::assert_directory(cache_dir, access = "rw")
}

#' @importFrom checkmate assert_logical
check_sfplus <- function(sfplus) {
  checkmate::assert_logical(sfplus, any.missing = FALSE, len = 1L)
}

#' @importFrom checkmate assert_character
check_ticker <- function(ticker) {
  checkmate::assert_character(
    ticker,
    pattern = "^[A-Za-z0-9_\\.\\-]+$",
    any.missing = FALSE,
    null.ok = TRUE
  )
}

#' @importFrom checkmate assert_integerish
check_simfin_id <- function(simfin_id) {
  checkmate::assert_integerish(
    simfin_id,
    lower = 1L,
    any.missing = FALSE,
    null.ok = TRUE
  )
}

#' @importFrom checkmate assert_choice
check_statement <- function(statement) {
  checkmate::assert_choice(
    statement,
    c("pl", "bs", "cf", "derived", "all"),
    fmatch = TRUE
  )
}

#' @importFrom checkmate assert_choice
check_period <- function(period, sfplus) {
  if (is.null(period) & isFALSE(sfplus)) {
    msg_sfplus_required("period")
  }
  checkmate::assert_choice(
    period,
    c("q1", "q2", "q3", "q4", "fy", "h1", "h2", "9m", "6m", "quarters"),
    null.ok = TRUE,
    fmatch = TRUE
  )
  if (period == "quarters" & isFALSE(sfplus)) {
    stop('period = "quarters" is reserved for SimFin+ users.', call. = FALSE)
  }
}

#' @importFrom checkmate assert_integerish
check_fyear <- function(fyear, sfplus) {
  if (is.null(fyear) & isFALSE(sfplus)) {
    msg_sfplus_required("fyear")
  }
  checkmate::assert_integerish(
    fyear,
    lower = 1900L,
    upper = data.table::year(Sys.Date()),
    null.ok = TRUE
  )
}

#' @importFrom checkmate assert_date
check_start <- function(start, sfplus) {
  if (!is.null(start) & isFALSE(sfplus)) {
    msg_sfplus_required("start", "Specifying")
  }
  checkmate::assert_date(
    start,
    lower = as.Date("1900-01-01"),
    upper = Sys.Date(),
    null.ok = TRUE
  )
}

#' @importFrom checkmate assert_date
check_end <- function(end, sfplus) {
  if (!is.null(end) & isFALSE(sfplus)) {
    msg_sfplus_required("end", "Specifying")
  }
  checkmate::assert_date(
    end,
    lower = as.Date("1900-01-01"),
    upper = Sys.Date(),
    null.ok = TRUE
  )
}

#' @importFrom checkmate assert_logical
check_ttm <- function(ttm) {
  checkmate::assert_logical(ttm, any.missing = FALSE, len = 1L)
}

#' @importFrom checkmate assert_logical
check_shares <- function(shares, sfplus) {
  checkmate::assert_logical(shares, any.missing = FALSE, len = 1L)

  if (isTRUE(shares) & isFALSE(sfplus)) {
    stop(
      "'shares = TRUE' is reserved to SimFin+ users. As a normal user, please ",
      "use 'sfa_get_shares()' with 'type = \"wa-basic\"' or 'type = ",
      "\"wa-diluted\".",
      call. = FALSE
    )
  }
}

#' @importFrom checkmate assert_logical
check_ratios <- function(ratios, sfplus) {
  if (!is.null(ratios) & isFALSE(sfplus)) {
    msg_sfplus_required("ratios", "Specifying")
  }
  checkmate::assert_logical(
    ratios,
    any.missing = FALSE,
    len = 1L,
    null.ok = TRUE
  )
}

#' @importFrom checkmate assert_choice
check_type <- function(type) {
  checkmate::assert_choice(
    type,
    choices = c("common", "wa-basic", "wa-diluted"),
    fmatch = TRUE
  )
}

#' @importFrom checkmate assert_choice
check_ref_data <- function(ref_data) {
  checkmate::assert_choice(
    ref_data,
    choices = c("industries", "markets"),
    fmatch = TRUE
  )
}
