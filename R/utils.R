#' Generic input checks
#' @description This function covers all kinds of (recurring) input checks in [simfinapi]. This keeps the other functions cleaner.
#' @param api_key See function using this argument.
#' @param cache_dir See function using this argument.
#' @param Ticker See function using this argument.
#' @param SimFinId See function using this argument.
#' @param statement See function using this argument.
#' @param period See function using this argument.
#' @param fyear See function using this argument.
#' @param start See function using this argument.
#' @param end See function using this argument.
#' @param ttm See function using this argument.
#' @param shares See function using this argument.
#' @param ratios See function using this argument.
#' @importFrom checkmate assert_string assert_directory assert_character
#'   assert_integerish assert_choice assert_date
#' @importFrom data.table year
check_inputs <- function(
  api_key = NULL, cache_dir = NULL, Ticker = NULL, SimFinId = NULL,
  statement = NULL, period = NULL, fyear = NULL, start = NULL, end = NULL,
  ttm = NULL, shares = NULL, ratios = NULL
) {
  if (!is.null(api_key)) {
    checkmate::assert_string(api_key, pattern = "^[[:alnum:]]{32}$")
  }
  if (!is.null(cache_dir)) {
    checkmate::assert_directory(cache_dir, access = "rw")
  }
  if (!is.null(Ticker)) {
    checkmate::assert_character(
      Ticker,
      pattern = "^[A-Za-z0-9_.]+$",
      any.missing = FALSE,
      null.ok = TRUE
    )
  }
  if (!is.null(SimFinId)) {
    checkmate::assert_integerish(
      SimFinId,
      lower = 1L,
      upper = 999999L,
      any.missing = FALSE,
      null.ok = TRUE
    )
  }
  if (!is.null(statement)) {
    checkmate::assert_choice(statement, c("pl", "bs", "cf", "derived", "all"))
  }
  if (!is.null(period)) {
    checkmate::assert_choice(
      period,
      c("q1", "q2", "q3", "q4", "fy", "h1", "h2", "9m", "6m", "quarters")
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
}


gather_ticker <- function(Ticker, SimFinId, api_key, cache_dir) {
  if (is.null(SimFinId)) {
    return(Ticker)
  }

  # translate SimFinId to Ticker
  entities <- sfa_get_entities(api_key = api_key, cache_dir = cache_dir)
  simfinid <- SimFinId # necessary for filtering
  translated_simfinid_DT <- entities[SimFinId %in% simfinid]

  if (nrow(translated_simfinid_DT) < length(SimFinId)) {
    not_found <- setdiff(SimFinId, translated_simfinid_DT[["SimFinId"]])
    for (id in not_found) {
      warning('No company found for SimFinId `', id, '`.', call. = FALSE)
    }
  }
  translated_simfinid <- translated_simfinid_DT[["Ticker"]]
  unique(c(Ticker, translated_simfinid))
}

#' @importFrom httr content
#' @importFrom RcppSimdJson fparse
#' @importFrom utils hasName
#' @importFrom memoise memoise cache_filesystem
#' @importFrom httr GET
call_api <- function(..., cache_dir) {
  # check for cache setup
  # if (is.null(getOption("sfa_cache_dir")))

  if (is.null(cache_dir)) {
    warning(
      "Option 'sfa_cache_dir' not set. Defaulting to 'tempdir()'.\n",
      "Thus, API results will only be cached during this session. To ",
      "cache results over the end of this session, set\n\n",
      "    options(sfa_cache_dir = \"existing/dir/of/your/choice\")\n\n",
      "to specify a non-temporary directory. See ",
      "'?memoise::cache_filesystem()' for additional information. This ",
      "warning is shown only once per session.",
      call. = FALSE
    )
    options(sfa_cache_dir = tempdir())
  }

  checkmate::assert_directory(cache_dir, access = "rw")

  mem_GET <- memoise::memoise(
    httr::GET,
    cache = memoise::cache_filesystem(cache_dir)
  )

  # call API and transform result to list
  response <- mem_GET(
    url = "https://simfin.com",
    ...
  )
  content <- httr::content(response, as = "text")
  content <- RcppSimdJson::fparse(content, max_simplify_lvl = "vector")

  if (utils::hasName(content, "error")) {
    warning("From SimFin API: '", content[["error"]], "'", call. = FALSE)
    return(NULL)
  }

  return(content)
}

setmany <- function(DT, vars, as) {
  for (var in vars) {
    data.table::set(DT, j = var, value = as(DT[[var]]))
  }
}

#' @importFrom data.table rbindlist setkeyv
gather_result <- function(result_list) {
  if (all(vapply(result_list, is.null, FUN.VALUE = logical(1L)))) {
    return(invisible(NULL))
  }
  result_DT <- data.table::rbindlist(result_list, fill = TRUE)
  data.table::setkeyv(result_DT, "Ticker")
  result_DT
}
