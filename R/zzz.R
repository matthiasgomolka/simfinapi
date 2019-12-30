.onLoad <- function(libname, pkgname) {
    sfa_memoise_fromJSON <- sfa_memoise_fromJSON()
    Sys.setenv(sfa_api = "https://simfin.com/api/v1/")
    Sys.setenv(sfa_key_var = "simId")
}
