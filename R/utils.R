gather_ticker <- function(ticker, simfin_id, api_key, cache_dir) {
  # get entities in order to verify the existence of ticker / simfin_id
  entities <- sfa_get_entities(api_key = api_key, cache_dir = cache_dir)

  # find valid tickers
  valid_tickers <- find_and_warn(entities, ticker, "ticker")

  # find valid simfin_ids and translate them to tickers
  valid_simfin_ids <- find_and_warn(entities, simfin_id, "simfin_id")
  simfin_id_as_ticker <- entities[simfin_id %in% valid_simfin_ids, ticker]

  valid_ids <- unique(c(valid_tickers, simfin_id_as_ticker))
  if (length(valid_ids) == 0L) {
    stop(
      "Please provide at least one one valid 'ticker' or 'simfin_id'.",
      call. = FALSE
    )
  }
  return(valid_ids)
}

find_and_warn <- function(entities, ids, id_name) {
  ids_ <- ids # necessary for filtering
  found_DT <- subset(entities, get(id_name) %in% ids_)

  if (nrow(found_DT) < length(ids)) {
    not_found <- setdiff(ids, found_DT[[id_name]])
    for (id in not_found) {
      warning('No company found for ', id_name, ' `', id, '`.', call. = FALSE)
    }
    return(setdiff(ids, not_found))
  }
  return(ids)

}

#' @importFrom data.table set
set_as <- function(DT, vars, as) {
  for (var in vars) {
    data.table::set(DT, j = var, value = as(DT[[var]]))
  }
}

#' @importFrom data.table is.data.table rbindlist setkeyv
gather_result <- function(results) {
  if (all(vapply(results, is.null, FUN.VALUE = logical(1L)))) {
    return(invisible(NULL))
  }
  if (data.table::is.data.table(results)) {
    result_DT <- results
  } else {
    result_DT <- data.table::rbindlist(results, fill = TRUE)
  }
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

warn_not_found <- function(request) {
  warning(
    "Please double-check your inputs. The SimFin API returned no data for request '",
    request, "'.",
    call. = FALSE
  )
}
