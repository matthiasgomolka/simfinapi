#' @noRd
gather_ticker <- function(ticker, id, api_key, cache_dir) {
    id <- NULL
    # get entities in order to verify the existence of ticker / id
    companies <- sfa_load_companies(api_key = api_key, cache_dir = cache_dir)

    # find valid tickers
    valid_tickers <- find_and_warn(companies, ticker, "ticker")

    # find valid ids and translate them to tickers
    valid_ids <- find_and_warn(companies, id, "id")
    id_as_ticker <- subset(companies, id %in% valid_ids)[["ticker"]]

    valid_ids <- unique(c(valid_tickers, id_as_ticker))
    if (length(valid_ids) == 0L) {
        stop("Please provide at least one one valid 'ticker' or 'id'.", call. = FALSE)
    }
    return(valid_ids)
}

#' @noRd
find_and_warn <- function(entities, ids, id_name) {
    ids_ <- ids # necessary for filtering
    found_DT <- subset(entities, get(id_name) %in% ids_)

    if (nrow(found_DT) < length(ids)) {
        not_found <- setdiff(ids, found_DT[[id_name]])
        for (id in not_found) {
            warning("No company found for ", id_name, " `", id, "`.", call. = FALSE)
        }
        return(setdiff(ids, not_found))
    }
    return(ids)
}


#' @importFrom data.table set
#' @noRd
set_as <- function(DT, vars, as) {
    for (var in vars) {
        if (var %in% names(DT)) {
            data.table::set(DT, j = var, value = as(DT[[var]]))
        }
    }
}

#' @importFrom data.table is.data.table rbindlist setkeyv
#' @noRd
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
#' @noRd
set_clean_names <- function(DT) {
    for (var in names(DT)) {
        data.table::setattr(DT[[var]], "label", var)
    }
    data.table::setnames(DT, clean_names)
}

#' @noRd
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

#' @noRd
warn_not_found <- function(content, ticker) {
    not_found_idx <- which(!vapply(content, `[[`, "found", FUN.VALUE = logical(1L)))
    if (length(not_found_idx) > 0L) {
        for (tckr in ticker[not_found_idx]) {
            warning("No data retrieved for ticker '", tckr, "'.", call. = FALSE)
        }
    }
}

#' @noRd
handle_api_error <- function(resp) {
    msg <- paste0("SimFin API Error ", resp$status_code, ": ", httr2::resp_body_string(resp))
    if (resp$status_code >= 400L) {
        stop(msg, call. = FALSE)
    } else {
        warning(msg)
    }
}
