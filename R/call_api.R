#' @importFrom httr content
#' @importFrom RcppSimdJson fparse
#' @importFrom utils hasName
#' @importFrom memoise memoise cache_filesystem
#' @importFrom httr GET
call_api <- function(..., cache_dir) {
  # check for cache setup
  # if (is.null(getOption("sfa_cache_dir")))

  if (is.null(cache_dir)) {
    warning(
      "Option 'sfa_cache_dir' not set. Defaulting to 'tempdir()'.\n",
      "Thus, API results will only be cached during this session. To ",
      "cache results over the end of this session, set\n\n",
      "    options(sfa_cache_dir = \"existing/dir/of/your/choice\")\n\n",
      "to specify a non-temporary directory. See ",
      "'?memoise::cache_filesystem()' for additional information. This ",
      "warning is shown only once per session.",
      call. = FALSE
    )
    options(sfa_cache_dir = tempdir())
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
  content <- RcppSimdJson::fparse(
    response[["content"]],
    max_simplify_lvl = "vector"
  )

  if (utils::hasName(content, "error")) {
    warning("From SimFin API: '", content[["error"]], "'", call. = FALSE)
    return(NULL)
  }

  return(content)
}
