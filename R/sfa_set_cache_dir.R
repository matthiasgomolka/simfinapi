#' Set cache directory globally
#' @description It is highly recommended to set the cache directory globally.
#'   This has two advantages:
#'
#'   1. Results from the 'SimFin' API calls are cached over the end of the
#'   session. This is especially interesting if you don't have a SimFin+ account
#'   and the number of API calls is limited to 2,000 per day.
#'   2. It makes specifying the `cache_dir` argument of other `sfa_*` functions
#'   obsolete.
#'
#' @param path [character] The directory where you want to cache the responses
#'   from the 'SimFin' API calls.
#' @param create [logical] Set `TRUE` if you want to create `path` automatically
#'   if it does not yet exist.
#' @export
sfa_set_cache_dir <- function(path, create = FALSE) {
    checkmate::assert_string(path)
    checkmate::assert_logical(create, any.missing = FALSE, len = 1L)

    if (!dir.exists(path)) {
        if (isFALSE(create)) {
            stop("'", path, "' does not exist. Use 'create = TRUE' to create it on the fly.")
        } else {
            dir.create(path, recursive = TRUE)
        }
    }

    options(sfa_cache_dir = path)
    return(invisible(getOption("sfa_cache_dir")))
}
