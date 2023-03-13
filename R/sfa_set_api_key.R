#' Set your 'SimFin' API key globally
#' @description It is highly recommended to set the API key globally as it makes
#'   specifying the `api_key` argument of other `sfa_*` functions obsolete.
#'
#'   There are two ways to set your API key globally:
#'
#'   1. Provide the API key directly as a string (`api_key = "YourApiKey"`).
#'   2. Create a system-wide environment variable containing you API key and
#'   refer to that (`env_var = "YourEnvVar"`). How to create a system-wide
#'   environment variable depends on your operating system.
#'
#'   The second option is recommended because your R scripts won't contain your
#'   API key and it is safe to keep your scripts in an open repository like
#'   GitHub.
#' @param api_key [character] You API key. Ignored if you specify `env_var` as
#'   well.
#' @param env_var [character] Name of an environment variable holding you API
#'   key, e.g. `SIMFIN_API_KEY`. Leave empty (`NULL`, default) if you want to
#'   set your API key directly.
#' @examples
#' \dontrun{
#' # set API key directly
#' sfa_set_api_key(api_key = "YourApiKey")
#'
#' # set API key via environment variable
#' # (this assumes you already created an environment variable called
#' # 'SIMFIN_API_KEY' which contains you API key)
#' sfa_set_api_key(env_var = "SIMFIN_API_KEY")
#' }
#' @importFrom checkmate assert_string
#' @export
sfa_set_api_key <- function(api_key, env_var) {
  api_key_specified <- !missing(api_key)
  env_var_specified <- !missing(env_var)

  # inform about inputs
  if (!any(api_key_specified, env_var_specified)) {
    stop("No arguments specified.")
  }
  if (all(api_key_specified, env_var_specified)) {
    warning("Both 'api_key' and 'env_var' provided. Ignoring 'api_key'.")
  }

  if (api_key_specified) {
    options(sfa_api_key = api_key)
  }
  if (env_var_specified) {
    options(sfa_api_key = Sys.getenv(env_var))
  }

  sfa_api_key <- getOption("sfa_api_key")
  return(invisible(sfa_api_key))
}
