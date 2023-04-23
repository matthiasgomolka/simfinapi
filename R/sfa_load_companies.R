#' Load all companies
#'
#' @inheritParams param_doc
#'
#' @return `tibble::tibble()` containing basic company information
#' @export
#'
sfa_load_companies <- function(
    add_info = TRUE,
    api_key = getOption("sfa_api_key"),
    cache_dir = getOption("sfa_cache_dir")
) {
    check_api_key(api_key)
    check_cache_dir(cache_dir)

    url_suffix <- ifelse(add_info, "general/compact", "list")

    response <- call_api(
        url = paste0("/companies/", url_suffix),
        api_key = api_key,
        cache_dir = cache_dir
    )

    response_body <- httr2::resp_body_string(response) |>
        RcppSimdJson::fparse(int64_policy = "integer64")

    if (isFALSE(add_info)) {
        companies <- tibble::as_tibble(response_body)
    } else {
        companies <- tibble::as_tibble(response_body[["data"]], .name_repair = "minimal")
        colnames(companies) <- response_body[["columns"]]
        col_order <- c(
            "id", "name", "ticker", "sector", "end_fy", "num_employees", "b_summary", "market"
        )
        companies <- dplyr::select(companies, dplyr::all_of(col_order))
    }

    return(companies)
}
