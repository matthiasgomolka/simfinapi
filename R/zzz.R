.onAttach <- function(libname, pkgname) {
  if (interactive()) {
    packageStartupMessage(
      "In order to use simfinapi, register at 'https://simfin.com/login' and ",
      "obtain an API key. Then, see '?sfa_set_api_key' to learn how to make ",
      "the API key globally available to all simfinapi functions."
    )
  }
}
