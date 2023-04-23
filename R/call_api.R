#' @importFrom RcppSimdJson fparse
#' @importFrom memoise memoise cache_filesystem
#' @importFrom httr2 request req_url_path_append req_headers req_user_agent req_url_query
#'    req_perform last_response resp_is_error resp_body_string
#' @importFrom tibble as_tibble
call_api <- function(url, api_key, cache_dir, ...) {
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

    req <- httr2::request("https://backend.simfin.com/api/v3") |>
        httr2::req_url_path_append(url) |>
        httr2::req_headers(
            Authorization = api_key,
            accept = "application/json"
        ) |>
        httr2::req_user_agent("simfinapi (https://github.com/matthiasgomolka/simfinapi)") |>
        httr2::req_url_query(...)

    mem_req_perform <- memoise::memoise(
        httr2::req_perform,
        cache = memoise::cache_filesystem(cache_dir)
    )

    resp <- tryCatch(mem_req_perform(req), error = \(error) httr2::last_response())

    if (httr2::resp_is_error(resp)) {
        body <- httr2::resp_body_string(resp) |> RcppSimdJson::fparse()
        warning(paste0("SimFin API Error ", body$status, ": ", body$error))
        return(list(request = req, reponse = NULL))
    }

    return(resp)
}
#     simplify_lvl <- ifelse(url == "/companies/list", "data_frame", "list")
#     resp_body <- httr2::resp_body_string(resp) |>
#         RcppSimdJson::fparse(
#             max_simplify_lvl = simplify_lvl,
#             int64_policy = "integer64"
#         )
#   browser()
#     if (is.data.frame(resp_body)) {
#         resp_tbl <- tibble::as_tibble(resp_body)
#     } else {
#         resp_tbl <- purrr::map_dfr(
#           resp_body,
#           ~ {
#             browser()
#
#             cols <- as.character(.x[["columns"]])
#
#             id_tbl <- tibble::as_tibble(.x[c("name", "id", "ticker")])
#             tibble::as_tibble(.x[["data"]])
#             resp_tbl <- tibble::as_tibble(.x[["data"]], .name_repair = "minimal")
#             colnames(resp_tbl) <- .x[["columns"]]
#             return(resp_tbl)
#           }
#         )
#
#     }
#
#     return(list(request = req, body = resp_tbl))
# }
