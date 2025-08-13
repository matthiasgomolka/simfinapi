#' Load share prices
#'
#' @description Retrieve share price data and ratios.
#'
#' @inheritParams param_doc
#'
#' @param ratios [logical] If `TRUE`, additional ratios and derived metrics are included.
#'
#' @return [data.table::data.table] with share price data.
#'
#' @export
sfa_load_shareprices <- function(
    ticker = NULL,
    id = NULL,
    start = NULL,
    end = NULL,
    ratios = FALSE,
    asreported = FALSE,
    api_key = getOption("sfa_api_key"),
    cache_dir = getOption("sfa_cache_dir")) {
    # check_sfplus(sfplus)
    check_id(id)
    check_ticker(ticker)
    checkmate::assert_logical(ratios, len = 1L)
    # check_ratios(ratios, sfplus)
    # check_start(start, sfplus)
    checkmate::assert_date(as.Date(start), max.len = 1L)
    # check_end(end, sfplus)
    checkmate::assert_date(as.Date(end), max.len = 1L)
    check_api_key(api_key)
    check_cache_dir(cache_dir)

    ticker <- gather_ticker(ticker, id, api_key, cache_dir)
    ticker_cat <- paste(ticker, collapse = ",")

    response <- call_api(
        url = "/companies/prices/compact",
        api_key = api_key,
        cache_dir = cache_dir,
        ticker = ticker_cat,
        ratios = tolower(ratios),
        asreported = tolower(asreported),
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

    base_vars <- c("name", "id", "ticker", "currency")
    col_order <- c(base_vars, setdiff(names(results_dt), base_vars))
    data.table::setcolorder(results_dt, col_order)

    char_vars <- c("ticker", "name", "currency")
    date_vars <- c("Date")
    lgl_vars <- c("Restated")
    int_vars <- c("id")
    num_vars <- setdiff(names(results_dt), c(char_vars, date_vars, lgl_vars, int_vars))

    set_as(results_dt, date_vars, as.Date)
    set_as(results_dt, lgl_vars, as.logical)
    set_as(results_dt, int_vars, as.integer)
    set_as(results_dt, num_vars, as.numeric)

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
