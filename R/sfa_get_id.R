#' Find single SimFin ID's
#' @param find `[character(1)]` The string to search for.
#' @param by `[character(1)]` Either search by "ticker" (default) or by "name".
#' @param api_key `[character(1)]` Your SimFin API key. I recommend setting the
#'   API key globally via `options(sfa_api_key = "yourapikey")` and omit the
#'   `api_key` argument in all simfinapi functions.
sfa_get_id_ <- function(find, type, api_key = getOption("sfa_api_key")) {
  api_call <- glue::glue(
    "https://simfin.com/api/v1/info/find-id/{type}/{find}?api-key={api_key}"
  )

  result <- sfa_memoise_fromJSON(api_call)

  # warn if there was no match
  if (length(result) == 0) {
    warning(call. = FALSE, glue::glue("No match for '{find}'."))
    return(NULL)
  }

  result
}

#' Find one or more SimFin ID's by ticker or name
#' @param find `[character]` The string(s) to search for.
#' @param by `[character(1)]` Either search by "ticker" (default) or by "name".
#' @param api_key `[character(1)]` Your SimFin API key. I recommend setting the
#'   API key globally via `options(sfa_api_key = "yourapikey")` and omit the
#'   `api_key` argument in all simfinapi functions.
#' @importFrom checkmate check_string assert_choice
#' @importFrom future.apply future_lapply
#' @importFrom data.table rbindlist
#' @export
sfa_get_id <- function(find, by = "ticker", api_key = getOption("sfa_api_key")) {
  # input checks
  checkmate::assert_character(find)
  checkmate::assert_choice(by, c("ticker", "name"))
  checkmate::assert_string(api_key, pattern = "[[:alnum:]]{32}")

  type <- switch(by,
    ticker = "ticker",
    name = "name-search"
  )

  # make API calls
  result_list <- future.apply::future_lapply(find, sfa_get_id_, type, api_key)
  result_DT <- data.table::rbindlist(result_list)
  data.table::setorderv(result_DT, by)
  result_DT
}
