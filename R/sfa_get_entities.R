#' Get a table of all available SimFin ID's with ticker and name.
#' @param api_key `[character(1)]` Your SimFin API key. For simplicity use `sys.setenv(sfa_api_key = "yourapikey")`.
#' @importFrom data.table setDT setkeyv
#' @export
sfa_get_entities <- function(api_key = Sys.getenv("sfa_api_key")) {
    api_call <- paste0(options("sfa_api"),
                       "info/all-entities/",
                       "?api-key=", api_key)

    dt <- data.table::setDT(sfa_memoise_fromJSON(api_call))
    data.table::setkeyv(dt, Sys.getenv("sfa_key_var"))
}

