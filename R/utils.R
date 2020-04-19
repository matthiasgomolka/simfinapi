#' @importFrom memoise memoise cache_filesystem
#' @importFrom httr GET
mem_GET <- memoise::memoise(
    httr::GET,
    cache = memoise::cache_filesystem(getOption("sfa_cache_dir", tempdir()))
)

#' @importFrom httr content
#' @importFrom jsonlite fromJSON
#' @importFrom utils hasName
call_api <- function(...) {
    # call API and transform result to list
    response <- mem_GET(
        url = "https://simfin.com",
        ...
    )
    content <- httr::content(response, as = "text")
    content <- jsonlite::fromJSON(content)

    # stop if there was an error
    if (utils::hasName(content, "error")) {
        warning(content[["error"]], call. = FALSE)
        return(NULL)
    }

    content
}

#' @importFrom data.table rbindlist setkeyv
gather_result <- function(result_list) {
    result_DT <- data.table::rbindlist(result_list)
    data.table::setkeyv(result_DT, "simId")
    result_DT
}

# not yet working properly; use tidyr::unnest()
# sfa_unnest_statement <- function(dt) {
#     list_col <- names(dt)[vapply(dt, is.list, FUN.VALUE = logical(1))]
#     other_cols <- setdiff(names(dt), list_col)
#     dt[, unlist(dt[[list_col]], recursive = FALSE), by = other_cols]
# }
