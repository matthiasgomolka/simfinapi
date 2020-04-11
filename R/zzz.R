.onLoad <- function(libname, pkgname) {
  options(sfa_cache_dir = tempdir())
  # Sys.setenv(sfa_key_var = "simId")
}
.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "In order to use simfinapi, register at https://simfin.com/login and ",
    "obtain an API key. Then, use 'options(sfa_api_key = \"yourapikey\")' ",
    "to make the API key available to all simfinapi functions."
  )
}
