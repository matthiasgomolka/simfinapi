#' #' Find single SimFin ID's
#' #' @param find [character] The string to search for.
#' #' @param type [character] Either search by "ticker" (default) or by
#' #'   "name-search".
#' #' @param api_key [character] Your SimFin API key. I recommend setting the
#' #'   API key globally via `options(sfa_api_key = "yourapikey")` and omit the
#' #'   `api_key` argument in all simfinapi functions.
#' #' @importFrom httr content
#' #' @importFrom data.table data.table
#' sfa_get_id_ <- function(
#'                         find,
#'                         type,
#'                         api_key = getOption("sfa_api_key"),
#'                         cache_dir = getOption("sfa_cache_dir", tempdir())) {
#'   find <- gsub(" ", "+", find, fixed = TRUE)
#'   content <- call_api(
#'     path = list("api/v1/info/find-id", type, find),
#'     query = list("api-key" = api_key),
#'     cache_dir = cache_dir
#'   )
#'
#'   # warn if there was no match
#'   if (is.null(content)) {
#'     warning(call. = FALSE, sprintf("No match for '%s'.", find))
#'     content <- data.table::data.table(
#'       simId = integer(),
#'       ticker = character(),
#'       name = character()
#'     )
#'   }
#'
#'   content
#' }
#'
#' #' Find one or more SimFin ID's by ticker or name
#' #' @param find [character] The string(s) to search for.
#' #' @param by [character] Either search by "ticker" (default) or by "name".
#' #' @param api_key [character] Your SimFin API key. I recommend setting the
#' #'   API key globally via `options(sfa_api_key = "yourapikey")` and omit the
#' #'   `api_key` argument in all simfinapi functions.
#' #' @importFrom checkmate assert_character assert_choice assert_string
#' #' @importFrom future.apply future_lapply
#' #' @importFrom data.table rbindlist setkeyv
#' #' @export
#' sfa_get_id <- function(
#'                        find,
#'                        by = "ticker",
#'                        api_key = getOption("sfa_api_key")) {
#'   # input checks
#'   checkmate::assert_character(find)
#'   checkmate::assert_choice(by, c("ticker", "name"))
#'   checkmate::assert_string(api_key, pattern = "[[:alnum:]]{32}")
#'
#'   type <- switch(by,
#'     ticker = "ticker",
#'     name = "name-search"
#'   )
#'
#'   # make API calls
#'   result_list <- future.apply::future_lapply(find, sfa_get_id_, type, api_key)
#'   gather_result(result_list)
#' }
