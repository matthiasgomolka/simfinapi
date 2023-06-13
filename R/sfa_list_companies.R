#' List Companies
#'
#' Get a list of all companies in the SimFin database. See \url{https://simfin.readme.io/reference/list-1} for details.
#'
#' @inheritParams param_doc
#'
#' @importFrom data.table data.table setnames
#'
#' @return `data.table::data.table()` containing basic company information.
#' @export
#'
sfa_list_companies <- function(
        api_key = getOption("sfa_api_key"),
        cache_dir = getOption("sfa_cache_dir")
) {
    check_api_key(api_key)
    check_cache_dir(cache_dir)

    response <- call_api(
        url = "/companies/list",
        api_key = api_key,
        cache_dir = cache_dir
    )

    response_body <- httr2::resp_body_string(response) |>
        RcppSimdJson::fparse(int64_policy = "integer64")

    companies <- data.table::data.table(response_body)

    data.table::setkeyv(companies, "id")

    return(companies)
}
