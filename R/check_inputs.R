#' @noRd
msg_sfplus_required <- function(var, verb = "Omitting") {
  stop(verb, " '", var, "' is reserved for SimFin+ users.", call. = FALSE)
}

#' @importFrom checkmate assert_string
#' @noRd
check_api_key <- function(api_key) {
  checkmate::assert_string(api_key)#, pattern = "^[a-zA-Z0-9]+(-[a-zA-Z0-9]+)*$")
}

#' @importFrom checkmate assert_directory
#' @noRd
check_cache_dir <- function(cache_dir) {
  if (!is.null(cache_dir)) {
    checkmate::assert_directory(cache_dir, access = "rw")
  }
}

#' @importFrom checkmate assert_logical
#' @noRd
check_sfplus <- function(sfplus) {
  checkmate::assert_logical(sfplus, any.missing = FALSE, len = 1L)
}

#' @importFrom checkmate assert_character
#' @noRd
check_ticker <- function(ticker) {
  checkmate::assert_character(
    ticker,
    pattern = "^[A-Za-z0-9_\\.\\:\\-]+$",
    any.missing = FALSE,
    null.ok = TRUE
  )
}

#' @importFrom checkmate assert_integerish
#' @noRd
check_id <- function(id) {
  checkmate::assert_integerish(
    id,
    lower = 1L,
    any.missing = FALSE,
    null.ok = TRUE
  )
}

#' @importFrom checkmate assert_choice
#' @noRd
check_statement <- function(statement, sfplus) {
  checkmate::assert_subset(
    statement,
    c("pl", "bs", "cf", "derived"),
    empty.ok = FALSE,
    fmatch = TRUE
  )
  # if (statement == "all" & isFALSE(sfplus)) {
  #   stop('statement = "all" is reserved for SimFin+ users.', call. = FALSE)
  # }
}

#' @importFrom checkmate assert_choice
#' @noRd
check_period <- function(period, sfplus, called_from_get_shares = FALSE) {
  checkmate::assert_choice(
    period,
    c("q1", "q2", "q3", "q4", "fy", "h1", "h2", "9m", "6m", "quarters"),
    null.ok = TRUE,
    fmatch = TRUE
  )
  if (isFALSE(called_from_get_shares)) {
    if (isFALSE(sfplus)) {
      if (period %in% c("6m", "quarters")) {
        stop(
          'period = "', period, '" is reserved for SimFin+ users.',
          call. = FALSE
        )
      }
    }
  }
}

#' @noRd
check_period_get_shares <- function(...) {
  check_period(...)
}


#' @importFrom checkmate assert_integerish
#' @noRd
check_fyear <- function(fyear, sfplus) {
  if (is.null(fyear) && isFALSE(sfplus)) {
    msg_sfplus_required("fyear")
  }
  checkmate::assert_integerish(
    fyear,
    lower = 1900L,
    upper = data.table::year(Sys.Date()),
    null.ok = TRUE
  )
}

#' @noRd
check_fyear_get_shares <- function(..., type) {
  if (type %in% c("wa-basic", "wa-diluted")) {
    check_fyear(...)
  }
}

#' @importFrom checkmate assert_date
#' @noRd
check_start <- function(start, sfplus) {
  if (!is.null(start) && isFALSE(sfplus)) {
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
#' @noRd
check_end <- function(end, sfplus) {
  if (!is.null(end) && isFALSE(sfplus)) {
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
#' @noRd
check_ttm <- function(ttm) {
  checkmate::assert_logical(ttm, any.missing = FALSE, len = 1L)
}

#' @importFrom checkmate assert_logical
#' @noRd
check_shares <- function(shares, sfplus) {
  checkmate::assert_logical(shares, any.missing = FALSE, len = 1L)

  if (isTRUE(shares) && isFALSE(sfplus)) {
    stop(
      "'shares = TRUE' is reserved to SimFin+ users. As a normal user, please ",
      "use 'sfa_get_shares()' with 'type = \"wa-basic\"' or 'type = ",
      "\"wa-diluted\".",
      call. = FALSE
    )
  }
}

#' @importFrom checkmate assert_logical
#' @noRd
check_ratios <- function(ratios, sfplus) {
  if (!is.null(ratios) && isFALSE(sfplus)) {
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
#' @noRd
check_type <- function(type) {
  checkmate::assert_choice(
    type,
    choices = c("common", "wa-basic", "wa-diluted"),
    fmatch = TRUE
  )
}

#' @importFrom checkmate assert_choice
#' @noRd
check_ref_data <- function(ref_data) {
  checkmate::assert_choice(
    ref_data,
    choices = c("industries", "markets"),
    fmatch = TRUE
  )
}
