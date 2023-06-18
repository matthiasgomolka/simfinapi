#' Common Shares Outstanding
#'
#' @export
sfa_load_common_shares_outstanding <- function(
    id = NULL,
    ticker = NULL,
    start = NULL,
    end = NULL
    ) {
    ticker <- gather_ticker(ticker, id, api_key, cache_dir)

    response <- call_api(
        url = "/companies/common-shares-outstanding",
        api_key = api_key,
        cache_dir = cache_dir,
        ticker = paste(ticker, collapse = ",")
    )

    response_body <- httr2::resp_body_string(response) |>
        RcppSimdJson::fparse(single_null = NA)

    results_dt <- data.table::as.data.table(response_body) |>
        setnames(c("id", "Date", "Common Shares Outstanding"))

    date_vars <- grep("Date", colnames(results_dt), fixed = TRUE, value = TRUE)
    for (var in date_vars) {
        data.table::set(results_dt, j = var, value = as.Date(results_dt[[var]], format = "%Y-%m-%d"))
    }

    master_data <- sfa_list_companies(api_key = api_key, cache_dir = cache_dir)

    with_master_data <- merge(master_data, results_dt, by = "id", all.y = TRUE)
    return(with_master_data)
}


#' Weighted Shares Outstanding
#'
#' @export
sfa_load_weighted_shares_outstanding <- function(
        id = NULL,
        ticker = NULL,
        start = NULL,
        end = NULL
) {
    ticker <- gather_ticker(ticker, id, api_key, cache_dir)

    response <- call_api(
        url = "/companies/weighted-shares-outstanding",
        api_key = api_key,
        cache_dir = cache_dir,
        ticker = paste(ticker, collapse = ",")
    )

    response_body <- httr2::resp_body_string(response) |>
        RcppSimdJson::fparse(single_null = NA)

    results_dt <- data.table::as.data.table(response_body) |>
        setnames(c("id", "Date", "Fiscal Year", "Period", "Basic Shares Outstanding", "Diluted Shares Outstanding"))

    date_vars <- grep("Date", colnames(results_dt), fixed = TRUE, value = TRUE)
    for (var in date_vars) {
        data.table::set(results_dt, j = var, value = as.Date(results_dt[[var]], format = "%Y-%m-%d"))
    }

    master_data <- sfa_list_companies(api_key = api_key, cache_dir = cache_dir)

    with_master_data <- merge(master_data, results_dt, by = "id", all.y = TRUE)
    return(with_master_data)
}
