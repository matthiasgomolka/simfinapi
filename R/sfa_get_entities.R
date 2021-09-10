#' Get a table of all available 'SimFin' ID's with ticker and name.
#' @inheritParams param_doc
#' @importFrom data.table as.data.table rbindlist setnames set setkeyv
#' @export
sfa_get_entities <- function(
  api_key = getOption("sfa_api_key"),
  cache_dir = getOption("sfa_cache_dir")
) {
  check_api_key(api_key)
  check_cache_dir(cache_dir)

  response_light <- call_api(
    path = list("api/v2/companies/list/"),
    query = list("api-key" = api_key),
    cache_dir = cache_dir
  )
  content <- response_light[["content"]]

  # return early of no content
  if (is.null(content)) {
    return(invisible(NULL))
  }

  DT_list <- lapply(content[["data"]], function(x) {
    data.table::as.data.table(t(x))
  })

  DT <- data.table::rbindlist(DT_list)
  data.table::setnames(DT, clean_names(content[["columns"]]))
  data.table::set(DT, j = "simfin_id", value = as.integer(DT[["simfin_id"]]))
  data.table::set(DT, j = "ticker", value = trimws(DT[["ticker"]], "both"))
  data.table::setkeyv(DT, "ticker")

  return(DT[])
}
