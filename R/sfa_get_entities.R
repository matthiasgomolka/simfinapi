#' #' Get a table of all available 'SimFin' ID's with ticker.
#' #' @inheritParams param_doc
#' #' @importFrom data.table as.data.table rbindlist setnames set setkeyv
#' #' @export
#' sfa_get_entities <- function(
#'     ...,
#'     api_key = getOption("sfa_api_key"),
#'     cache_dir = getOption("sfa_cache_dir")
#' ) {
#'   check_api_key(api_key)
#'   check_cache_dir(cache_dir)
#'   # checkmate::assert_subset(order, choices = c("id", "name", "ticker", "sector"))
#'
#'   response <- call_api(
#'     url = "/companies/list",
#'     api_key = api_key,
#'     cache_dir = cache_dir
#'   )
#'   companies <- response[["body"]]
#'
#'   # return early of no content
#'   if (is.null(companies)) {
#'     return(invisible(NULL))
#'   } else {
#'       companies <- dplyr::arrange(companies, ...)
#'   }
#'
#'   return(companies)
#' }
#'
