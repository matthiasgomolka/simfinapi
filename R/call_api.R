#' @importFrom RcppSimdJson fparse
#' @importFrom memoise memoise cache_filesystem
#' @importFrom httr2 request req_url_path_append req_headers req_user_agent req_url_query
#'    req_perform last_response resp_is_error resp_body_string
call_api <- function(url, api_key, cache_dir, ...) {
    # check for cache setup

    if (is.null(cache_dir)) {
        warning("'cache_dir' not set. Defaulting to 'tempdir()'. Thus, API results will ", "only be cached during this session. To learn why and how to cache ",
            "results over the end of this session, see `?sfa_set_cache_dir`.\n\n", "[This warning appears only once per session.]",
            call. = FALSE)
        sfa_set_cache_dir(tempdir(), create = TRUE)
        cache_dir <- getOption("sfa_cache_dir")
    }

    checkmate::assert_directory(cache_dir, access = "rw")

    req <- httr2::request("https://prod.simfin.com/api/v3") |>
        httr2::req_url_path_append(url) |>
        httr2::req_headers(Authorization = api_key, accept = "application/json") |>
        httr2::req_user_agent("simfinapi (https://github.com/matthiasgomolka/simfinapi)") |>
        httr2::req_url_query(...)

    mem_req_perform <- memoise::memoise(httr2::req_perform, cache = memoise::cache_filesystem(cache_dir))

    resp <- tryCatch(mem_req_perform(req), error = \(error) httr2::last_response())

    if (httr2::resp_is_error(resp)) {
        handle_api_error(resp)
    }

    return(resp)
}
