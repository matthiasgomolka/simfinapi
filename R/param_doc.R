#' Parameter documentation
#' @name param_doc
#'
#' @param api_key [character] Your 'SimFin' API key. It's recommended to set
#'   the API key globally using [sfa_set_api_key].
#'
#' @param cache_dir [character] Your cache directory. It's recommended to set
#'   the cache directory globally using [sfa_set_cache_dir].
#'
#' @param sfplus [logical] Set`TRUE` if you have a SimFin+ account. It's
#'   recommended to set `sfplus` globally using [sfa_set_sfplus].
#'
#' @param ticker [integer] Ticker of the companies of interest.
#'
#' @param simfin_id [integer] 'SimFin' IDs of the companies of interest. Any
#'   `simfin_id` will be internally translated to the respective `ticker`. This
#'   reduces the number of queries in case you query the same company via
#'   `ticker` *and* `simfin_id`.
#'
#' @param start [Date] Filter for the report dates (reserved for SimFin+ users).
#'   With this filter you can filter the statements by the date on which the
#'   reported period ended ('Report Date'). By specifying a value here, only
#'   statements will be retrieved with report dates ending AFTER the specified
#'   date.
#'
#' @param end [Date] Filter for the report dates (reserved for SimFin+ users).
#'   With this filter you can filter the statements by the date on which the
#'   reported period ended ('Report Date'). By specifying a value here, only
#'   statements will be retrieved with report dates ending BEFORE the specified
#'   date.
#'
#' @param period [character] Filter for periods. As a non-SimFin+ user, you have
#'   to provide exactly one period. As SimFin+ user, this filter can be omitted
#'   to retrieve all statements available for the company.
#'
#'   - `"q1"`: First fiscal quarter.
#'   - `"q2"`: Second fiscal quarter.
#'   - `"q3"`: Third fiscal quarter.
#'   - `"q4"`: Fourth fiscal quarter.
#'   - `"fy"`: Full fiscal year.
#'   - `"h1"`: First 6 months of fiscal year.
#'   - `"h2"`: Last 6 months of fiscal year.
#'   - `"9m"`: First nine months of fiscal year.
#'   - `"6m"`: Any fiscal 6 month period (first + second half years; reserved
#'   for SimFin+ users).
#'   - `"quarters"`: All quarters (q1 + q2 + q3 + q4; reserved for SimFin+
#'   users).
#'
#' @param fyear [integer] Filter for fiscal year. As a non-SimFin+ user, you
#'   have to provide exactly one fiscal year. As SimFin+ user, this filter can
#'   be omitted to retrieve data available for the company. You can also chain
#'   this filter with a comma, to retrieve multiple years at once (e.g. `fyear =
#'   "2015,2016,2017"` to retrieve the data for 3 years at once).
#'
#' @param ratios [logical] With `TRUE`, you can display some price related
#'   ratios along with the share price data (reserved for SimFin+ users). The
#'   ratios that will be displayed are:
#'
#'   - Market-Cap
#'   - Price to Earnings Ratio (quarterly)
#'   - Price to Earnings Ratio (ttm)
#'   - Price to Sales Ratio (quarterly)
#'   - Price to Sales Ratio (ttm)
#'   - Price to Book Value (ttm)
#'   - Price to Free Cash Flow (quarterly)
#'   - Price to Free Cash Flow (ttm)
#'   - Enterprise Value (ttm)
#'   - EV/EBITDA (ttm)
#'   - EV/Sales (ttm)
#'   - EV/FCF (ttm)
#'   - Book to Market Value (ttm)
#'   - Operating Income/EV (ttm).
#'
#' @section Parallel processing:
#' This function supports parallel processing via `future.apply`. If your
#' machine has several cores (most have), you can make the API calls in
#' parallel. To do so, define a `future::plan()` before calling the function.
NULL
