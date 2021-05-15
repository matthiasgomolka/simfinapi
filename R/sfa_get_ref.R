#' Download reference data
#'
#' @description Download reference data on industries and markets.
#'
#' @inheritParams param_doc
#'
#' @param ref_data [character] Either "industries" or "markets".
#'
#' @return [data.table] containing reference data on "industries" or "markets",
#'   depending on `ref_data`.
#'
#' @importFrom utils download.file unzip
#' @importFrom data.table fread
#'
#' @export
#'
sfa_get_ref <- function(ref_data, api_key = getOption("sfa_api_key")) {

  check_inputs(ref_data = ref_data)

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

  DT <- data.table::fread(temp_csv, sep = ";", encoding = "UTF-8")
  set_clean_names(DT)
  return(DT)
}
