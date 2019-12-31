#' memoise jsonlite::fromJSON for SimFin API calls
#' @param cache_dir `[character(1)]` Path of the cache directory.
#' @importFrom memoise memoise cache_filesystem
#' @importFrom jsonlite fromJSON

sfa_memoise_fromJSON <- function(
    api_call,
    cache_dir = options("sfa_cache_dir")[[1]]
) {
    memoised_fromJSON <- memoise::memoise(
        jsonlite::fromJSON,
        cache = memoise::cache_filesystem(cache_dir)
    )
    # R.cache::addMemoization(jsonlite::fromJSON)

    memoised_fromJSON(api_call)
}


# not yet working properly; use tidyr::unnest()
# sfa_unnest_statement <- function(dt) {
#     list_col <- names(dt)[vapply(dt, is.list, FUN.VALUE = logical(1))]
#     other_cols <- setdiff(names(dt), list_col)
#     dt[, unlist(dt[[list_col]], recursive = FALSE), by = other_cols]
# }
