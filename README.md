
<!-- README.md is generated from README.Rmd. Please edit that file -->
simfinapi <img src='man/figures/logo.png' align="right" height="139" />
=======================================================================

[![](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental) [![](https://www.r-pkg.org/badges/version/simfinapi?color=orange)](https://cran.r-project.org/package=simfinapi) [![R build status](https://github.com/Plebejer/simfinapi/workflows/R-CMD-check/badge.svg)](https://github.com/Plebejer/simfinapi/actions) [![](https://codecov.io/gh/Plebejer/simfinapi/branch/master/graph/badge.svg)](https://codecov.io/gh/Plebejer/simfinapi) [![Dependencies](https://tinyverse.netlify.com/badge/simfinapi)](https://cran.r-project.org/package=simfinapi)

What does simfinapi do?
-----------------------

simfinapi wraps the <https://simfin.com/> Web-API to make 'SimFin' data easily available in R.

*To use the package, you need to register at <https://simfin.com/login> and obtain a 'SimFin' API key.*

Example
-------

In this example, we download some stock price data and turn these into a simple plot.

``` r
# load package
library(simfinapi)
#> In order to use simfinapi, register at 'https://simfin.com/login' and obtain an API key. Then, see '?sfa_set_api_key' to learn how to make the API key globally available to all simfinapi functions.

# download stock price data
tickers <- c("AMZN", "GOOG") # Amazon, Google
prices <- sfa_get_prices(tickers)
```

Please note that all functions in simfinapi start with the prefix `sfa_`. This makes it easy to find all available functionality.

The downloaded data looks like this:

<table>
<colgroup>
<col width="7%" />
<col width="6%" />
<col width="9%" />
<col width="7%" />
<col width="5%" />
<col width="5%" />
<col width="5%" />
<col width="5%" />
<col width="9%" />
<col width="7%" />
<col width="7%" />
<col width="21%" />
</colgroup>
<thead>
<tr class="header">
<th align="right">SimFinId</th>
<th align="left">Ticker</th>
<th align="left">Date</th>
<th align="left">Currency</th>
<th align="right">Open</th>
<th align="right">High</th>
<th align="right">Low</th>
<th align="right">Close</th>
<th align="right">Adj. Close</th>
<th align="right">Volume</th>
<th align="right">Dividend</th>
<th align="right">Common Shares Outstanding</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="right">62747</td>
<td align="left">AMZN</td>
<td align="left">2007-01-03</td>
<td align="left">USD</td>
<td align="right">38.68</td>
<td align="right">39.06</td>
<td align="right">38.05</td>
<td align="right">38.70</td>
<td align="right">38.70</td>
<td align="right">12405100</td>
<td align="right">NA</td>
<td align="right">NA</td>
</tr>
<tr class="even">
<td align="right">62747</td>
<td align="left">AMZN</td>
<td align="left">2007-01-04</td>
<td align="left">USD</td>
<td align="right">38.59</td>
<td align="right">39.14</td>
<td align="right">38.26</td>
<td align="right">38.90</td>
<td align="right">38.90</td>
<td align="right">6318400</td>
<td align="right">NA</td>
<td align="right">NA</td>
</tr>
<tr class="odd">
<td align="right">62747</td>
<td align="left">AMZN</td>
<td align="left">2007-01-05</td>
<td align="left">USD</td>
<td align="right">38.72</td>
<td align="right">38.79</td>
<td align="right">37.60</td>
<td align="right">38.37</td>
<td align="right">38.37</td>
<td align="right">6619700</td>
<td align="right">NA</td>
<td align="right">NA</td>
</tr>
<tr class="even">
<td align="right">62747</td>
<td align="left">AMZN</td>
<td align="left">2007-01-08</td>
<td align="left">USD</td>
<td align="right">38.22</td>
<td align="right">38.31</td>
<td align="right">37.17</td>
<td align="right">37.50</td>
<td align="right">37.50</td>
<td align="right">6783000</td>
<td align="right">NA</td>
<td align="right">NA</td>
</tr>
<tr class="odd">
<td align="right">62747</td>
<td align="left">AMZN</td>
<td align="left">2007-01-09</td>
<td align="left">USD</td>
<td align="right">37.60</td>
<td align="right">38.06</td>
<td align="right">37.34</td>
<td align="right">37.78</td>
<td align="right">37.78</td>
<td align="right">5703000</td>
<td align="right">NA</td>
<td align="right">NA</td>
</tr>
<tr class="even">
<td align="right">62747</td>
<td align="left">AMZN</td>
<td align="left">2007-01-10</td>
<td align="left">USD</td>
<td align="right">37.49</td>
<td align="right">37.70</td>
<td align="right">37.07</td>
<td align="right">37.15</td>
<td align="right">37.15</td>
<td align="right">6527500</td>
<td align="right">NA</td>
<td align="right">NA</td>
</tr>
</tbody>
</table>

Let's turn that into a simple plot.

``` r
# load ggplot2
library(ggplot2)

# create plot
ggplot(prices) +
  aes(x = Date, y = Close, color = Ticker) +
  geom_line()
```

<img src="man/figures/README-plot_data-1.png" width="100%" />

Suppose we would like to display the actual company name instead of the ticker. To do so, we download additional company information and merge it to the `prices` data:

``` r
company_info <- sfa_get_info(tickers)
```

`company_info` contains these information:

|  SimFinId| Ticker | Company Name      |  IndustryId|  Month FY End|  Number Employees|
|---------:|:-------|:------------------|-----------:|-------------:|-----------------:|
|     62747| AMZN   | AMAZON COM INC    |      103002|            12|            798000|
|        18| GOOG   | Alphabet (Google) |      101002|            12|             98771|

Now we merge both datasets and recreate the plot with the actual company names.

``` r
# merge data
merged <- merge(prices, company_info, by = "Ticker")

# recreate plot
ggplot(merged) +
  aes(x = Date, y = Close, color = `Company Name`) +
  geom_line()
```

<img src="man/figures/README-recreate_plot-1.png" width="100%" />

Installation
------------

simfinapi is not yet available on [CRAN](https://cran.r-project.org/), but you can install it from [GitHub](https://github.com/Plebejer/simfinapi):

``` r
remotes::install_github("https://github.com/Plebejer/simfinapi")
```

Setup
-----

Using simfinapi is much more convenient if you set your API key and cache directory[1] globally before you start downloading data. See `?sfa_set_api_key` and `?sfa_set_cache_dir` for details.

Code of Conduct
---------------

Please note that the 'simfinapi' project is released with a [Contributor Code of Conduct](https://github.com/Plebejer/simfinapi/blob/master/.github/CODE_OF_CONDUCT.md). By contributing to this project, you agree to abide by its terms.

[1] simfinapi always caches the results from your API calls to obtain results quicker and to reduce the number of API calls. If you set the cache directory to a permanent directory (the default is `tempdir()`), simfinapi will be able to reuse this cache in subsequent R sessions.
