#' #' Get a table of all available 'SimFin' ID's with ticker.
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' This function was deprecated because of the new 'SimFin' Web API V3.
#' @keywords internal
#' @inheritParams param_doc
#' @importFrom lifecycle deprecate_soft
#' @importFrom data.table setkeyv
#' @examples
#' sfa_get_entities()
#' # ->
#' sfa_list_companies()
#'
#' @export
sfa_get_entities <- function(
    api_key = getOption("sfa_api_key"),
    cache_dir = getOption("sfa_cache_dir")
) {
    lifecycle::deprecate_soft("1.0.0", "sfa_get_entities()", "sfa_list_companies()")

    companies <- sfa_load_companies()[, .(simfin_id = id, ticker)]
    data.table::setkeyv(companies, "ticker")

    return(companies)
}
