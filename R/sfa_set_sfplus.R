#' Specify the type of you SimFin account
#' @description If you have a SimFin+ account, it is highly recommended to
#'   specify this globally as it makes specifying the `sfplus` argument of other
#'   `sfa_*` functions obsolete.
#'
#'   You don't need this function if you don't have a SimFin+ account.
#' @param sfplus [logical] Defaults to `TRUE` to specify that you have a SimFin+
#'   account.
#' @examples
#' \dontrun{
#' # Tell simfinapi that you have a SimFin+ account
#' sfa_set_sfplus()
#' }
#' @details There is no good reason to use `sfa_set_sfplus(FALSE)` as all
#'   functions assume this by default.
#' @importFrom checkmate assert_logical
#' @export
sfa_set_sfplus <- function(sfplus = TRUE) {
  checkmate::assert_logical(sfplus, len = 1L)
  options(sfa_sfplus = sfplus)
}
