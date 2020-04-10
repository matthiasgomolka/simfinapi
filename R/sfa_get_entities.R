#' Get a table of all available SimFin ID's with ticker and name.
#' @param api_key `[character(1)]` Your SimFin API key. For simplicity use
#'   `options(sfa_api_key = "yourapikey")`.
#' @importFrom checkmate assert_string
#' @importFrom data.table setDT
#' @export
sfa_get_entities <- function(api_key = getOption("sfa_api_key")) {
    checkmate::assert_string(api_key, pattern = "[[:alnum:]]{32}")

    api_call <- glue::glue(
        "https://simfin.com/api/v1/info/all-entities/?api-key={api_key}"
    )

    (data.table::setDT(sfa_memoise_fromJSON(api_call)))
}

