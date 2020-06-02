sfa_api_key <- Sys.getenv("SIMFIN_API_KEY")
# sfa_api_key <- Sys.getenv("FAKE_SECRET")


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
} else {
  options(sfa_api_key = sfa_api_key)
}

options(sfa_cache_dir = tempdir())
