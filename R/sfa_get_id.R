#' Find single SimFin ID's
#' @param find `[character(1)]` The string to search for.
#' @param by `[character(1)]` Either search by "ticker" or by "name".
#' @param api_key `[character(1)]` Your SimFin API key. For simplicity use `options(sfa_api_key = "yourapikey")`.
sfa_get_id_ <- function(find,
                         by = "ticker",
                         api_key = Sys.getenv("sfa_api_key")) {

    stopifnot(length(find) == 1)
    stopifnot(by %in% c("ticker", "name"))
    type <- switch(by, ticker = "ticker/",
                       name   = "name-search/")

    api_call <- paste0(Sys.getenv("sfa_api"),
                       "info/find-id/", type, find,
                       "?api-key=", api_key)
    result <- sfa_memoise_fromJSON(api_call)

    if (length(result) == 0) {
        warning("No match for '", find, "' by '", by, "'. <- ")
        return(NULL)
    } else {
        return(result)
    }
}

#' Find one or more SimFin ID's by ticker or name
#' @param find `[character]` The string to search for.
#' @param by `[character(1)]` Either search by "ticker" or by "name".
#' @param api_key `[character(1)]` Your SimFin API key. For simplicity use `options(sfa_api_key = "yourapikey")`.
#' @importFrom future.apply future_lapply
#' @importFrom data.table rbindlist setorderv
#' @export
sfa_get_id <- function(find,
                        by = "ticker",
                        api_key = Sys.getenv("sfa_api_key")) {

    result_list <- future.apply::future_lapply(find, sfa_get_id_, by, api_key)
    dt <- data.table::rbindlist(result_list)
    if (nrow(dt) > 0) {
        data.table::setkeyv(dt, Sys.getenv("sfa_key_var"))
    }
    return(dt)
}

