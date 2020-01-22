.onLoad <- function(libname, pkgname) {
    options(sfa_cache_dir = tempdir())
    Sys.setenv(sfa_api = "https://simfin.com/api/v1/")
    # Sys.setenv(sfa_key_var = "simId")
}
.onAttach <- function(libname, pkgname) {
    packageStartupMessage("In order to use the package, register at https://simfin.com/login and obtain an API key. Then, use\n",
    'Sys.setenv(sfa_api_key = "yourapikey")\n',
    "to make the API key available to all simfinapi functions.")
}
