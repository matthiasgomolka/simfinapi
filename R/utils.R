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
    result_DT <- data.table::rbindlist(result_list)
    data.table::setkeyv(result_DT, "simId")
    result_DT
}
