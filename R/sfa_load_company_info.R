#' General Company Info
#'
#' @description
#' Get Information for one or several companies by SimFin ID or ticker.
#'
#' @inheritParams param_doc
#'
#' @importFrom data.table data.table setnames
#'
#' @return `data.table::data.table()` containing basic company information
#' @export
#'
sfa_load_company_info <- function(
    api_key = getOption("sfa_api_key"),
    cache_dir = getOption("sfa_cache_dir")
) {
    check_api_key(api_key)
    check_cache_dir(cache_dir)

    response <- call_api(
        url = "/companies/general/compact",
        api_key = api_key,
        cache_dir = cache_dir
    )

    response_body <- httr2::resp_body_string(response) |>
        RcppSimdJson::fparse(int64_policy = "integer64")

    companies <- response_body[["data"]] |>
        data.table::data.table() |>
        data.table::setnames(response_body[["columns"]])
    col_order <- c(
        "id", "name", "ticker", "sector", "end_fy", "num_employees", "b_summary", "market"
    )
    companies <- companies[, ..col_order]

    data.table::setkeyv(companies, "id")

    return(companies)
}
