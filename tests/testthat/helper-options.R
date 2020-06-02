sfa_api_key <- Sys.getenv("simfin_api_key")

if (sfa_api_key == "") {
  tryCatch(
    options(
      sfa_api_key = secret::get_secret(
        "sfa_api_key",
        vault = "../../inst/vault"
      )
    ),
    error = function(error) {
      options(
        sfa_api_key = secret::get_secret(
          "sfa_api_key",
          vault = "../../simfinapi/vault"
        )
      )
    }
  )
}

options(sfa_cache_dir = tempdir(check = TRUE))
