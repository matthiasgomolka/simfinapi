# simfinapi 0.2.3
* This is a mainly a maintenance release due to the SimFin API update. The API 
  V2 is now in legacy mode.

# simfinapi 0.2.1

## Bug Fixes
* Loading data without specifying a `cache_dir` returned a generic error instead
  of a helpful warning with information on how to set the `cache_dir`.
* `sfa_get_statements()` no longer errors when the returned data does not have 
  the same amount of columns. See 
  [issue #35](https://github.com/matthiasgomolka/simfinapi/issues/35) and thanks
  to Mislav Sagovac for reporting.

# simfinapi 0.2.0

## Possibly Breaking Changes
* All column names in returned `data.table`s now comply to basic naming
  conventions. The original column names are stored in the `label` attribute of
  each column.

## Features
* Added a `NEWS.md` file to track changes to the package.
* Clean support for SimFin+. Most functions throw early errors if a normal user
  requests data which is reserved for SimFin+ users. If SimFin+ offers only more
  convenience, this is matched internally for normal users so that the user 
  experience is very similar. Normal users only need more requests and therefore
  have to wait a little longer. However, this requires for most functions the 
  new argument `sfplus`.
* `sfa_get_*()` functions now feature a progress bar powered by {progressr} for 
  normal users since simfinapi sends possibly many requests.

## Bug Fixes
* `set_sfa_cache_dir()` is now exported.
* Corrections in `sfa_get_shares()` help.
* The `ratios` argument in `sfa_get_prices()` is no longer ignored.
* It's now possible to download statement data for several years at once (if you
  are a 'SimFin+' user).
* It's now possible to download "all" statements at once (if you are a 'SimFin+'
  user). Some column names occur in several statements and duplicates are 
  numbered with `_2`.
* Argument `fyear` from `sfa_get_statement()` no longer has a default value.
  This prevents errors for SimFin+ users, who set `start` or `end`. (#13, 
  reported by MislavSag)
* Too strict input checks on `Ticker` and `SimfinId` removed. (#15, reported by 
  MislavSag)
