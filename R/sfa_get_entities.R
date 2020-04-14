#' Get a table of all available SimFin ID's with ticker and name.
#' @param api_key `[character(1)]` Your SimFin API key. For simplicity use
#'   `options(sfa_api_key = "yourapikey")`.
#' @importFrom checkmate assert_string
#' @importFrom data.table setDT
#' @importFrom httr content
#' @importFrom jsonlite fromJSON
#' @export
sfa_get_entities <- function(api_key = getOption("sfa_api_key")) {
  checkmate::assert_string(api_key, pattern = "[[:alnum:]]{32}")

  response <- mem_GET(
    "https://simfin.com",
    path = list("api/v1/info/all-entities"),
    query = list("api-key" = api_key)
  )

  content <- httr::content(response, as = "text")
  content <- jsonlite::fromJSON(content)

  if (names(content)[[1]] == "error") {
    stop(content, call. = FALSE)
  }

  data.table::setDT(content)
  content
}



