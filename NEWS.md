# simfinapi 0.2.0

## Possibly Breaking Changes
* All column names in returned `data.table`s now comply to basic naming
  conventions. The original column names are stored in the `label` attribute of
  each column.

# simfinapi 0.1.1 (not on CRAN)

## Features
* Added a `NEWS.md` file to track changes to the package.
* `sfa_get_*()` functions now feature a progress bar powered by {progressr}.

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
