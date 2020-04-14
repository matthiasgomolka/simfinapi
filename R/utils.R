#' @importFrom memoise memoise cache_filesystem
#' @importFrom httr GET
mem_GET <- memoise::memoise(
    httr::GET,
    cache = memoise::cache_filesystem(getOption("sfa_cache_dir", tempdir()))
)


# not yet working properly; use tidyr::unnest()
# sfa_unnest_statement <- function(dt) {
#     list_col <- names(dt)[vapply(dt, is.list, FUN.VALUE = logical(1))]
#     other_cols <- setdiff(names(dt), list_col)
#     dt[, unlist(dt[[list_col]], recursive = FALSE), by = other_cols]
# }
