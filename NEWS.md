# simfinapi 0.1.1

## Features
* Added a `NEWS.md` file to track changes to the package.

## Bug Fixes
* `set_sfa_cache_dir()` is now exported.
* Corrections in `sfa_get_shares()` help.
* The `ratios` argument in `sfa_get_prices()` is no longer ignored.
* It's now possible to download statement data for several years at once (if you
are a 'SimFin+' user).
* It's now possible to download "all" statements at once (if you are a 'SimFin+'
user). Some column names occur in several statements and duplicates are numbered
with `_2`.
