#' List Companies
#'
#' Get a list of all companies in the SimFin database. See \url{https://simfin.readme.io/reference/list-1} and \url{https://simfin.readme.io/reference/general-1} for more information.
#'
#' @inheritParams param_doc
#' @param details \code{logical(1)}: If \code{TRUE}, return a more detailed data.table with additional columns. Default: \code{FALSE}.
#'
#' @importFrom data.table data.table setnames setcolorder setkeyv
#'
#' @return `data.table::data.table()` containing basic company information.
#' @export
#'
sfa_load_companies <- function(api_key = getOption("sfa_api_key"), cache_dir = getOption("sfa_cache_dir"), details = FALSE) {
    check_api_key(api_key)
    check_cache_dir(cache_dir)

    if (isTRUE(details)) {
        response <- call_api(url = "/companies/general/compact", api_key = api_key, cache_dir = cache_dir)
        response_body <- httr2::resp_body_string(response) |>
            RcppSimdJson::fparse()

        companies <- response_body[["data"]] |>
            data.table::data.table() |>
            data.table::setnames(response_body[["columns"]]) |>
            utils::type.convert(as.is = TRUE)

    } else {
        response <- call_api(url = "/companies/list", api_key = api_key, cache_dir = cache_dir)
        response_body <- httr2::resp_body_string(response) |>
            RcppSimdJson::fparse()
        companies <- data.table::data.table(response_body)
    }
    col_order <- c("id", "name", "ticker", "isin", "sectorCode", "sectorName", "industryName", "market", "endFy", "numEmployees",
        "companyDescription")
    col_order <- intersect(col_order, names(companies))
    data.table::setcolorder(companies, col_order)
    data.table::setkeyv(companies, "id")

    return(companies)
}
