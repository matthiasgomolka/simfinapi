#' Download reference data
#' @param ref_data [character] Either "industries" or "markets".
# @param cache_dir [character] Your cache directory. It's recommended to set
#   the cache directory globally using [sfa_set_cache_dir].
#' @param api_key `[character(1)]` Your 'SimFin' API key. For simplicity use
#'   `options(sfa_api_key = "yourapikey")`.
#' @importFrom utils download.file unzip
#' @importFrom data.table fread
#' @export
sfa_get_ref <- function(
  ref_data,
  api_key = getOption("sfa_api_key")
  # cache_dir = getOption("sfa_cache_dir") # NOT USED YET
) {
  check_inputs(ref_data = ref_data) #, cache_dir = cache_dir)

  temp_zip <- tempfile(fileext = ".zip")
  utils::download.file(
    paste0(
      "https://simfin.com/api/bulk/bulk.php?dataset=", ref_data,
      "&variant=null", "&api-key=", api_key
    ),
    temp_zip,
    quiet = TRUE
  )

  utils::unzip(temp_zip, exdir = tempdir())
  temp_csv <- file.path(
    tempdir(),
    utils::unzip(temp_zip, list = TRUE)[, "Name"]
  )

  data.table::fread(temp_csv, encoding = "UTF-8")
}
