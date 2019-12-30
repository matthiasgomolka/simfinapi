#' Get basic company information
#' @param simId `[integer(1)]` SimFin ID of the company of interest.
#' @param statement `[character(1)]` One of "pl" (Profit and Loss), "bs" (Balance Sheet), "cf" (Cash Flow).
#' @param period `[character(1)]` One of "Q1" "Q2" "Q3" "Q4" "H1" "H2" "9M" "FY" "TTM". See `ptype` on https://simfin.com/api/v1/documentation/#operation/getCompStatementStandardised for details.
#' @param fin_year `[integer(1)]` The financial year of interest.
#' @param api_key `[character(1)]` Your SimFin API key. For simplicity use `Sys.setenv(sfa_api_key = "yourapikey")`.
#' @importFrom data.table data.table set .SD
sfa_get_statement_ <- function(simId,
                               statement,
                               period,
                               fin_year,
                               api_key = Sys.getenv("sfa_api_key")) {

    stopifnot(statement %in% c("pl", "bs", "cf"))
    stopifnot(period %in% c("Q1", "Q2", "Q3", "Q4", "H1", "H2", "9M", "FY", "TTM"))

    api_call <- paste0(Sys.getenv("sfa_api"),
                       "companies/id/", simId, "/",
                       "statements/standardised",
                       "?api-key=", api_key,
                       "&stype=", statement,
                       "&ptype=", period,
                       "&fyear=", fin_year)

    raw <- sfa_memoise_fromJSON(api_call)
    dt <- data.table::data.table(
        simId = simId,
        statement = statement,
        period = period,
        fin_year = fin_year,
        ref_date = raw$periodEndDate,
        raw$values,
        key = "simId")

    data.table::set(dt, j = "ref_date", value = as.Date(dt[["ref_date"]]))
    for (var in c("fin_year", "tid", "uid", "parent_tid", "displayLevel")) {
        data.table::set(dt, j = var, value = as.integer(dt[[var]]))
    }
    for (var in paste0("value", c("Assigned", "Calculated", "Chosen"))) {
        data.table::set(dt, j = var, value = as.numeric(dt[[var]]))
    }
    dt[, list(values = list(.SD)), by = c("simId", "statement", "period", "fin_year", "ref_date")]
}

#' Get basic company information
#' @param simIds `[integer]` SimFin IDs of the companies of interest.
#' @param statement `[character(1)]` One of "pl" (Profit and Loss), "bs" (Balance Sheet), "cf" (Cash Flow).
#' @param period `[character(1)]` One of "Q1" "Q2" "Q3" "Q4" "H1" "H2" "9M" "FY" "TTM". See `ptype` on https://simfin.com/api/v1/documentation/#operation/getCompStatementStandardised for details.
#' @param fin_year `[integer(1)]` The financial year of interest.
#' @param api_key `[character(1)]` Your SimFin API key. For simplicity use `Sys.setenv(sfa_api_key = "yourapikey")`.
#' @importFrom future.apply future_lapply
#' @importFrom data.table rbindlist setkeyv
#' @export
sfa_get_statement <- function(simIds,
                              statement,
                              period,
                              fin_year,
                              api_key = Sys.getenv("sfa_api_key")) {
    result_list <- future.apply::future_lapply(simIds, sfa_get_statement_,
                                               statement, period, fin_year, api_key)
    dt <- data.table::rbindlist(result_list)
    data.table::setkeyv(dt, Sys.getenv("sfa_key_var"))
    return(dt)
}
