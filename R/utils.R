gather_ticker <- function(ticker, simfin_id, api_key, cache_dir) {
  if (is.null(simfin_id)) {
    return(ticker)
  }

  # translate simfin_id to ticker
  entities <- sfa_get_entities(api_key = api_key, cache_dir = cache_dir)
  simfinid <- simfin_id # necessary for filtering
  translated_simfinid_DT <- entities[simfin_id %in% simfinid]

  if (nrow(translated_simfinid_DT) < length(simfin_id)) {
    not_found <- setdiff(simfin_id, translated_simfinid_DT[["simfin_id"]])
    for (id in not_found) {
      warning('No company found for simfin_id `', id, '`.', call. = FALSE)
    }
  }
  translated_simfinid <- translated_simfinid_DT[["ticker"]]
  unique(c(ticker, translated_simfinid))
}

#' @importFrom data.table set
set_as <- function(DT, vars, as) {
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
  set_clean_names(result_DT)
  data.table::setkeyv(result_DT, "ticker")
  result_DT[]
}

#' Clean names
#' @description Cleans column names so that they comply to R naming conventions.
#'   Keeps the original names in the `label` attribute.
#' @param DT A [data.table].
#' @return A [data.table] with cleaned names and labels.
#' @importFrom data.table setattr setnames
set_clean_names <- function(DT) {
  for (var in names(DT)) {
    data.table::setattr(DT[[var]], "label", var)
  }
  data.table::setnames(DT, clean_names)
}

clean_names <- function(x) {
  # clean camelCase -> snake_case
  x <- gsub("(?<=[a-z])([A-Z])", "_\\1", perl = TRUE, x)
  # clean spaces and special chars to _
  x <- gsub("\\.+", "_", tolower(make.names(x)))
  # remove trailing _
  x <- gsub("_$", "", x)
  # sim_fin_id -> simfim_id
  gsub("sim_fin", "simfin", fixed = TRUE, x)
}
