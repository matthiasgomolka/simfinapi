sfa_load_shareprices <- function(
        simfin_id = NULL,
        ticker = NULL,
        start = NULL,
        end = NULL,
        ratios = FALSE,
        as_reported = FALSE,
        api_key = getOption("sfa_api_key"),
        cache_dir = getOption("sfa_cache_dir"),
        subscription = getOption("sfa_subscription", default = "free")
) {
    # check_sfplus(sfplus)
    check_simfin_id(simfin_id)
    check_ticker(ticker)
    checkmate::assert_logical(ratios, len = 1L)
    # check_ratios(ratios, sfplus)
    # check_start(start, sfplus)
    checkmate::assert_date(as.Date(start), max.len = 1L)
    # check_end(end, sfplus)
    checkmate::assert_date(as.Date(end), max.len = 1L)
    check_api_key(api_key)
    check_cache_dir(cache_dir)

    ticker <- gather_ticker(ticker, simfin_id, api_key, cache_dir)
    ticker_cat <- paste(ticker, collapse = ",")

    response <- call_api(
        url = "/companies/prices/compact",
        api_key = api_key,
        cache_dir = cache_dir,
        ticker = ticker_cat,
        ratios = tolower(ratios),
        start = start,
        end = end
    )

    response_body <- httr2::resp_body_string(response) |>
        RcppSimdJson::fparse(
            single_null = NA,
            # int64_policy = "integer64",
            max_simplify_lvl = "list"
        )

    results_dt <- lapply(response_body, \(item) {
        cols <- item[["columns"]] |> as.character()
        dt <- item[["data"]] |>
            unlist(recursive = FALSE) |>
            matrix(ncol = length(cols), byrow = TRUE) |>
            data.table::data.table() |>
            data.table::setnames(cols)
        for (var in colnames(dt)) {
            data.table::set(dt, j = var, value = sapply(dt[[var]], `[[`, 1))
        }

        for (var in c("name", "id", "ticker", "currency")) {
            data.table::set(dt, j = var, value = item[[var]])
        }
        return(dt)
    }) |> data.table::rbindlist()

    date_vars <- grep("Date", colnames(results_dt), fixed = TRUE, value = TRUE)
    for (var in date_vars) {
        data.table::set(results_dt, j = var, value = as.Date(results_dt[[var]], format = "%Y-%m-%d"))
    }

    return(results_dt[])
}

#' Get price data
#'
#' @description Share price data and ratios can be retrieved here. All share
#'   prices are adjusted for stock splits. If you are interested in more
#'   details, take a look at this page:
#'   https://www.simfin.com/data/help/main?topic=apiv2-prices
#'
#' @inheritParams param_doc
#'
#' @inheritSection param_doc Parallel processing
#'
#' @importFrom future.apply future_lapply
#' @importFrom progressr with_progress progressor
#'
#' @export
#'
