#' @importFrom httr content
#' @importFrom RcppSimdJson fparse
#' @importFrom utils hasName
#' @importFrom memoise memoise cache_filesystem
#' @importFrom httr GET
call_api <- function(...) {
    # check for cache setup
    if (is.null(getOption("sfa_cache_dir"))) {
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

    checkmate::assert_directory(getOption("sfa_cache_dir"), access = "rw")

    mem_GET <- memoise::memoise(
        httr::GET,
        cache = memoise::cache_filesystem(getOption("sfa_cache_dir"))
    )

    # call API and transform result to list
    response <- mem_GET(
        url = "https://simfin.com",
        ...
    )
    content <- httr::content(response, as = "text")
    content <- RcppSimdJson::fparse(content)

    # stop if there was an error
    if (utils::hasName(content, "error")) {
        warning(
            "SimFin API: ", content[["error"]], ".\nStatus ", response$status,
            " for '", response$url, "'.\n",
            "See 'https://simfin.com/api/v1/documentation/' for details.",
            call. = FALSE
        )
        return(NULL)
    }

    # catch empty results
    if (identical(content, list())) {
        warning(
            "SimFin API delivered empty response.\nStatus ", response$status,
            " for '", response$url, "'.\n",
            "See 'https://simfin.com/api/v1/documentation/' for details.",
            call. = FALSE
        )
        return(NULL)
    }

    content
}

#' @importFrom data.table rbindlist setkeyv
gather_result <- function(result_list) {
    if (all(vapply(result_list, is.null, FUN.VALUE = logical(1L)))) {
        return(invisible(NULL))
    }
    result_DT <- data.table::rbindlist(result_list, fill = TRUE)
    data.table::setkeyv(result_DT, "simId")
    result_DT
}
