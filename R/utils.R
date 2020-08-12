gather_ticker <- function(Ticker, SimFinId, api_key, cache_dir) {
  if (is.null(SimFinId)) {
    return(Ticker)
  }

  # translate SimFinId to Ticker
  entities <- sfa_get_entities(api_key = api_key, cache_dir = cache_dir)
  simfinid <- SimFinId # necessary for filtering
  translated_simfinid_DT <- entities[SimFinId %in% simfinid]

  if (nrow(translated_simfinid_DT) < length(SimFinId)) {
    not_found <- setdiff(SimFinId, translated_simfinid_DT[["SimFinId"]])
    for (id in not_found) {
      warning('No company found for SimFinId `', id, '`.', call. = FALSE)
    }
  }
  translated_simfinid <- translated_simfinid_DT[["Ticker"]]
  unique(c(Ticker, translated_simfinid))
}

setmany <- function(DT, vars, as) {
  for (var in vars) {
    data.table::set(DT, j = var, value = as(DT[[var]]))
  }
}

#' @importFrom data.table rbindlist setkeyv
gather_result <- function(result_list) {
  if (all(vapply(result_list, is.null, FUN.VALUE = logical(1L)))) {
    return(invisible(NULL))
  }
  result_DT <- data.table::rbindlist(result_list, fill = TRUE)
  data.table::setkeyv(result_DT, "Ticker")
  result_DT
}
