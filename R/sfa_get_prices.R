sfa_get_price_ <- function(
  simId,
  start,
  end,
  api_key = getOption("sfa_api_key")
) {
  content <- call_api(
    path = sprintf("api/v1/companies/id/%s/shares/prices", simId),
    query = list(
      "start" = start,
      "end" = end,
      "api-key" = api_key
    )
  )

  if (!is.null(content)) {
    res <- data.table::data.table(
      simId = simId,
      content[["priceData"]],
      currency = content[["currency"]]
    )
    set(res, j = "date", value = as.Date(res[["date"]]))
    for (var in c("closeAdj", "splitCoef")) {
      set(res, j = var, value = as.numeric(res[[var]]))
    }
  } else {
    res <- data.table::data.table(
      simId = integer(),
      date = as.Date(character()),
      closeAdj = numeric(),
      splitCoef = numeric(),
      currency = character()
    )
  }

  res
}


#' @importFrom checkmate assert_int assert_string
#' @importFrom future.apply future_lapply
sfa_get_price <- function(
  simId,
  start = NULL,
  end = NULL,
  api_key = getOption("sfa_api_key")
) {
  simId <- checkmate::assert_integerish(
    simId,
    lower = 1L,
    upper = 999999L,
    coerce = TRUE
  )
  date_regex <- "^[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}$"
  checkmate::assert_string(start, pattern = date_regex, null.ok = TRUE)
  checkmate::assert_string(end,   pattern = date_regex, null.ok = TRUE)
  checkmate::assert_string(api_key, pattern = "[[:alnum:]]{32}")

  result_list <- future.apply::future_lapply(
    simId, sfa_get_price_, start, end, api_key
  )
  gather_result(result_list)
}
