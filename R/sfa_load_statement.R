#' Get financial statements
#'
#' @description Fundamentals and derived figures can be retrieved here.
#'
#' @inheritParams param_doc
#'
#' @param statements [character] vector of statements, available values: pl (Profit & Loss), bs
#'   (Balance Sheet), cf (Cash Flow), derived (Derived Ratios and Indicators).
#'
#' @return [data.table::data.table] containing the statement(s) data.
#'
#' @inheritSection param_doc Parallel processing
#'
#' @importFrom checkmate assert_choice
#' @importFrom data.table year CJ
#'
#' @export
sfa_load_statements <- function(
    ticker = NULL,
    id = NULL,
    statements,
    period = "fy",
    fyear = NULL,
    start = NULL,
    end = NULL,
    ttm = FALSE,
    asreported = FALSE,
    # details = FALSE,
    api_key = getOption("sfa_api_key"),
    cache_dir = getOption("sfa_cache_dir")) {
    check_ticker(ticker)
    check_id(id)
    # check_period(period, sfplus)
    # check_fyear(fyear, sfplus)
    # check_start(start, sfplus)
    # check_end(end, sfplus)
    check_ttm(ttm)
    check_api_key(api_key)
    check_cache_dir(cache_dir)

    ticker <- gather_ticker(ticker, id, api_key, cache_dir)
    if (isTRUE(ttm)) {
        period <- NULL
    }


    response <- call_api(
        url = "/companies/statements/compact",
        api_key = api_key,
        cache_dir = cache_dir,
        ticker = paste(ticker, collapse = ","),
        statements = paste(statements, collapse = ","),
        period = paste(period, collapse = ","),
        fyear = paste(fyear, collapse = ","),
        start = start,
        end = end,
        ttm = ttm,
        asreported = asreported
        # details = details
    )

    response_body <- httr2::resp_body_string(response) |>
        RcppSimdJson::fparse(
            single_null = NA,
            max_simplify_lvl = "list"
        )

    base_vars <- c("template", "name", "id", "ticker", "currency", "isin")
    DT <- lapply(response_body, \(item) {
        if (is.null(item[["statements"]])) {
            return(NULL)
        }
        stmts <- item[["statements"]]
        stmt_types <- vapply(stmts, \(stmt) stmt[["statement"]], FUN.VALUE = character(1L))
        names(stmts) <- stmt_types
        stmts_dfs <- lapply(stmts, \(stmt) {
            cols <- stmt[["columns"]] |> as.character()
            dt <- lapply(stmt[["data"]], \(data_array) {
                data_array |>
                    data.table::as.data.table() |>
                    data.table::setnames(cols)
            }) |>
                data.table::rbindlist(use.names = TRUE, fill = TRUE)

            for (var in base_vars) {
                data.table::set(dt, j = var, value = item[[var]])
            }

            return(dt)
        }) |>
            data.table::rbindlist(use.names = TRUE, fill = TRUE)
    }) |>
        data.table::rbindlist(use.names = TRUE, fill = TRUE)

    col_order <- c(base_vars, setdiff(names(DT), base_vars))
    data.table::setcolorder(DT, col_order)

    char_vars <- c("ticker", "name", "isin", "Source", "template", "Fiscal Period", "currency")
    date_vars <- c("Report Date", "Publish Date")
    lgl_vars <- c("TTM", "Value Check", "Restated")
    int_vars <- c("SimFinId", "Fiscal Year")
    num_vars <- setdiff(names(DT), c(char_vars, date_vars, lgl_vars, int_vars))

    set_as(DT, date_vars, as.Date)
    set_as(DT, lgl_vars, as.logical)
    set_as(DT, int_vars, as.integer)
    set_as(DT, num_vars, as.numeric)

    gather_result(DT)
}
