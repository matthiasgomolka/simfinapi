#' Get a table of all available SimFin ID's with ticker and name.
#' @param api_key [character] Your SimFin API key. It's recommended to set
#'   the API key globally using [sfa_set_api_key].
#' @param cache_dir [character] Your cache directory. It's recommended to set
#'   the cache directory globally using [sfa_set_cache_dir].
#' @importFrom data.table as.data.table rbindlist setnames set setkeyv
#' @export
sfa_get_entities <- function(
  api_key = getOption("sfa_api_key"),
  cache_dir = getOption("sfa_cache_dir")
) {
  check_inputs(api_key = api_key, cache_dir = cache_dir)

  content <- call_api(
    path = list("api/v2/companies/list/"),
    query = list("api-key" = api_key),
    cache_dir = cache_dir
  )

  # return early of no content
  if (is.null(content)) {
    return(invisible(NULL))
  }

  DT_list <- lapply(content[["data"]], function(x) {
    data.table::as.data.table(t(x))
  })

  DT <- data.table::rbindlist(DT_list)
  data.table::setnames(DT, content[["columns"]])
  data.table::set(DT, j = "SimFinId", value = as.integer(DT[["SimFinId"]]))
  data.table::set(DT, j = "Ticker", value = trimws(DT[["Ticker"]], "both"))
  data.table::setkeyv(DT, "Ticker")
  return(DT[])
}
