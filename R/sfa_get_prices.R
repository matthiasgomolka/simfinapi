sfa_get_price_ <- function(simId,
                           start,
                           end,
                           api_key = options("sfa_api_key")) {

    api_call <- paste0(options("sfa_api"),
                       "companies/id/", simId, "/",
                       "shares/prices",
                       "?api-key=", api_key,
                       "&start=", start,
                       "&end=", end)

    raw <- sfa_memoise_fromJSON(api_call)
    dt <- data.table::data.table(simId = simId,
                                 raw$priceData,
                                 key = "simId")
    set(dt, j = "date", value = as.Date(dt[["date"]]))
    for (var in c("closeAdj", "splitCoef")) {
        set(dt, j = var, value = as.numeric(dt[[var]]))
    }
    return(dt)
}


sfa_get_price <- function(simIds,
                          start,
                          end,
                          api_key = options("sfa_api_key")) {

    result_list <- lapply(simIds, sfa_get_price_,
                          start, end, api_key)

    dt <- data.table::rbindlist(result_list)
}