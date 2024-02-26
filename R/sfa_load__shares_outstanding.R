#' Common Shares Outstanding
#'
#' @export
sfa_load_common_shares_outstanding <- function(
    id = NULL,
    ticker = NULL,
    start = NULL,
    end = NULL,
    api_key = getOption("sfa_api_key"),
    cache_dir = getOption("sfa_cache_dir")
    ) {
    ticker <- gather_ticker(ticker, id, api_key, cache_dir)

    response <- call_api(
        url = "/companies/common-shares-outstanding",
        api_key = api_key,
        cache_dir = cache_dir,
        ticker = paste(ticker, collapse = ","),
        start = start,
        end = end
    )

    response_body <- httr2::resp_body_string(response) |>
        RcppSimdJson::fparse(single_null = NA)

    results_dt <- data.table::as.data.table(response_body)

    colnames <- c("id", "Date", "Common Shares Outstanding")
    if (ncol(results_dt) == 0L) {
        return(data.table::data.table(
            id = integer(),
            Date = as.Date(character()),
            `Common Shares Outstanding` = numeric()
        ))
    }

    setnames(results_dt, c("id", "Date", "Common Shares Outstanding"))

    date_vars <- c("Date")
    int_vars <- c("id")
    num_vars <- setdiff(names(results_dt), c(date_vars, int_vars))

    set_as(results_dt, date_vars, as.Date)
    set_as(results_dt, int_vars, as.integer)
    set_as(results_dt, num_vars, as.numeric)

    return(results_dt)
}


#' Weighted Shares Outstanding
#'
#' @export
sfa_load_weighted_shares_outstanding <- function(
    id = NULL,
    ticker = NULL,
    fyear = NULL,
    period = NULL,
    start = NULL,
    end = NULL,
    ttm = NULL,
    api_key = getOption("sfa_api_key"),
    cache_dir = getOption("sfa_cache_dir")
) {
    ticker <- gather_ticker(ticker, id, api_key, cache_dir)

    response <- call_api(
        url = "/companies/weighted-shares-outstanding",
        api_key = api_key,
        cache_dir = cache_dir,
        ticker = paste(ticker, collapse = ","),
        fyear = fyear,
        period = period,
        start = start,
        end = end,
        ttm = tolower(ttm)
    )

    response_body <- httr2::resp_body_string(response) |>
        RcppSimdJson::fparse(single_null = NA)

    results_dt <- data.table::as.data.table(response_body)
    if (ncol(results_dt) == 0L) {
        return(data.table::data.table(
            id = integer(),
            Date = as.Date(character()),
            `Fiscal Year` = integer(),
            Period = character(),
            `Basic Shares Outstanding` = numeric(),
            `Diluted Shares Outstanding` = numeric()
        ))
    }
    setnames(
        results_dt,
        c("id", "Date", "Fiscal Year", "Period", "Basic Shares Outstanding", "Diluted Shares Outstanding"))

    char_vars <- c("Period")
    date_vars <- c("Date")
    int_vars <- c("id", "Fiscal Year")
    num_vars <- setdiff(names(results_dt), c(char_vars, date_vars, int_vars))

    set_as(results_dt, date_vars, as.Date)
    set_as(results_dt, int_vars, as.integer)
    set_as(results_dt, num_vars, as.numeric)

    return(results_dt)
}
