#' @importFrom httr content
#' @importFrom RcppSimdJson fparse
#' @importFrom utils hasName
#' @importFrom memoise memoise cache_filesystem
#' @importFrom httr GET
call_api <- function(..., cache_dir) {
  # check for cache setup

  if (is.null(cache_dir)) {
    warning(
      "'cache_dir' not set. Defaulting to 'tempdir()'. Thus, API results will ",
      "only be cached during this session. To learn why and how to cache ",
      "results over the end of this session, see `?sfa_set_cache_dir`.\n\n",
      "[This warning appears only once per session.]",
      call. = FALSE
    )
    sfa_set_cache_dir(tempdir(), create = TRUE)
    cache_dir <- getOption("sfa_cache_dir")
  }

  checkmate::assert_directory(cache_dir, access = "rw")

  mem_GET <- memoise::memoise(
    httr::GET,
    cache = memoise::cache_filesystem(cache_dir)
  )

  # call API and transform result to list
  response <- mem_GET(
    url = "https://simfin.com",
    ...
  )
  request <- response[["request"]][["url"]]
  content <- RcppSimdJson::fparse(
    response[["content"]],
    max_simplify_lvl = "vector"
  )

  if (utils::hasName(content, "error")) {
    warning("From 'SimFin' API: '", content[["error"]], "'", call. = FALSE)
    return(NULL)
  }


  return(list(request = request, content = content))
}
