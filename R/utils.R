#' memoise jsonlite::fromJSON for SimFin API calls
#' @param api_call `[character(1)` URL of the API call.
#' @param cache_dir `[character(1)]` Path of the cache directory.
#' @importFrom memoise memoise cache_filesystem
#' @importFrom jsonlite fromJSON

sfa_memoise_fromJSON <- function(
    api_call,
    cache_dir = options("sfa_cache_dir")[[1]]
) {
    memoised_fromJSON <- memoise::memoise(
        jsonlite::fromJSON,
        cache = memoise::cache_filesystem(cache_dir))
    # R.cache::addMemoization(jsonlite::fromJSON)

    # safe_result <- safe_memoised_fromJSON(api_call)
    #
    # if (is.null(safe_result[["error"]])) {
    #     return(safe_result[["result"]])
    # } else {
    #     warning(paste0("The API call ", api_call, " produced the following error:\n", safe_result[["error"]],
    #                    "Most likely, the requested data is not available at simfin.com."),
    #             call. = FALSE)
    #     return(NULL)
    # }

    tryCatch(memoised_fromJSON(api_call),
             error = function(error) {
                 warning(paste0("The API call ", api_call, " returned the following error:\n", error,
                                "Most likely, the requested data is not available at simfin.com."),
                         call. = FALSE)
                 return(NULL)
             })

}


# not yet working properly; use tidyr::unnest()
# sfa_unnest_statement <- function(dt) {
#     list_col <- names(dt)[vapply(dt, is.list, FUN.VALUE = logical(1))]
#     other_cols <- setdiff(names(dt), list_col)
#     dt[, unlist(dt[[list_col]], recursive = FALSE), by = other_cols]
# }
