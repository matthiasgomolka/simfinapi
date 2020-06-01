tryCatch(
  options(
    sfa_api_key = secret::get_secret("sfa_api_key", vault = "../../inst/vault")
  ),
  error = function(error) {
    Sys.getenv("simfin_api_key")
  }
)
# options(sfa_cache_dir = tempdir(check = TRUE))
