#' Find single SimFin ID's
#' @param find [character] The string to search for.
#' @param type [character] Either search by "ticker" (default) or by
#'   "name-search".
#' @param api_key [character] Your SimFin API key. I recommend setting the
#'   API key globally via `options(sfa_api_key = "yourapikey")` and omit the
#'   `api_key` argument in all simfinapi functions.
#' @importFrom httr content
#' @importFrom jsonlite fromJSON
#' @importFrom data.table data.table
#' @importFrom glue glue
sfa_get_id_ <- function(find, type, api_key = getOption("sfa_api_key")) {
  response <- mem_GET(
    "https://simfin.com",
    path =  list("api/v1/info/find-id", type, find),
    query = list("api-key" = api_key)
  )

  content <- httr::content(response, as = "text")
  content <- jsonlite::fromJSON(content)

  # stop if there was an error
  error <- names(content)[[1L]] == "error"
  if (length(error) == 0L) error <- FALSE
  if (error) {
    stop(content, call. = FALSE)
  }

  # warn if there was no match
  if (length(content) == 0) {
    warning(call. = FALSE, sprintf("No match for '%s'.", find))
    return(
      data.table::data.table(
        simId = integer(),
        ticker = character(),
        name = character()
      )
    )
  }

  content
}

#' Find one or more SimFin ID's by ticker or name
#' @param find [character] The string(s) to search for.
#' @param by [character] Either search by "ticker" (default) or by "name".
#' @param api_key [character] Your SimFin API key. I recommend setting the
#'   API key globally via `options(sfa_api_key = "yourapikey")` and omit the
#'   `api_key` argument in all simfinapi functions.
#' @importFrom checkmate assert_character assert_choice assert_string
#' @importFrom future.apply future_lapply
#' @importFrom data.table rbindlist setorderv
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
