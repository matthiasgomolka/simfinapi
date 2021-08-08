
# simfinapi <img src='man/figures/logo.png' align="right" height="139" />

[![](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental) [![CRAN release](https://www.r-pkg.org/badges/version/simfinapi)](https://CRAN.R-project.org/package=simfinapi) [![Status](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active) [![R build status](https://github.com/matthiasgomolka/simfinapi/workflows/R-CMD-check/badge.svg)](https://github.com/matthiasgomolka/simfinapi/actions) [![](https://codecov.io/gh/matthiasgomolka/simfinapi/branch/main/graph/badge.svg)](https://codecov.io/gh/matthiasgomolka/simfinapi) [![Dependencies](https://tinyverse.netlify.com/badge/simfinapi)](https://cran.r-project.org/package=simfinapi)

## What does simfinapi do?

simfinapi wraps the <https://simfin.com/> Web-API to make 'SimFin' data easily available in R.

*To use the package, you need to register at <https://simfin.com/login> and obtain a 'SimFin' API key.*

## Example

In this example, we download some stock price data and turn these into a simple plot.

``` r
# load package
library(simfinapi)

# download stock price data
tickers <- c("AMZN", "GOOG") # Amazon, Google
prices <- sfa_get_prices(tickers)
```

Please note that all functions in simfinapi start with the prefix `sfa_`. This makes it easy to find all available functionality.

The downloaded data looks like this:

<table>
<colgroup>
<col width="8%" />
<col width="6%" />
<col width="9%" />
<col width="7%" />
<col width="5%" />
<col width="5%" />
<col width="5%" />
<col width="5%" />
<col width="8%" />
<col width="7%" />
<col width="7%" />
<col width="21%" />
</colgroup>
<thead>
<tr class="header">
<th align="right">simfin_id</th>
<th align="left">ticker</th>
<th align="left">date</th>
<th align="left">currency</th>
<th align="right">open</th>
<th align="right">high</th>
<th align="right">low</th>
<th align="right">close</th>
<th align="right">adj_close</th>
<th align="right">volume</th>
<th align="right">dividend</th>
<th align="right">common_shares_outstanding</th>
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
  aes(x = date, y = close, color = ticker) +
  geom_line()
```

<img src="man/figures/README-plot_data-1.png" width="100%" />

Suppose we would like to display the actual company name instead of the ticker. To do so, we download additional company information and merge it to the `prices` data:

``` r
company_info <- sfa_get_info(tickers)
```

`company_info` contains these information:

<table>
<colgroup>
<col width="3%" />
<col width="2%" />
<col width="5%" />
<col width="3%" />
<col width="4%" />
<col width="5%" />
<col width="75%" />
</colgroup>
<thead>
<tr class="header">
<th align="right">simfin_id</th>
<th align="left">ticker</th>
<th align="left">company_name</th>
<th align="right">industry_id</th>
<th align="right">month_fy_end</th>
<th align="right">number_employees</th>
<th align="left">business_summary</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="right">62747</td>
<td align="left">AMZN</td>
<td align="left">AMAZON COM INC</td>
<td align="right">103002</td>
<td align="right">12</td>
<td align="right">575700</td>
<td align="left">Amazon.com Inc is an online retailer. The Company sells its products through the website which provides services, such as advertising services and co-branded credit card agreements. It also offers electronic devices like Kindle e-readers and Fire tablets.</td>
</tr>
<tr class="even">
<td align="right">18</td>
<td align="left">GOOG</td>
<td align="left">Alphabet (Google)</td>
<td align="right">101002</td>
<td align="right">12</td>
<td align="right">98771</td>
<td align="left">Alphabet (formerly known as Google) offers a variety of IT services to individuals and corporations alike. Their main revenues come from online advertising.</td>
</tr>
</tbody>
</table>

Now we merge both datasets and recreate the plot with the actual company names.

``` r
# merge data
merged <- merge(prices, company_info, by = "ticker")

# recreate plot
ggplot(merged) +
  aes(x = date, y = close, color = company_name) +
  geom_line()
```

<img src="man/figures/README-recreate_plot-1.png" width="100%" />

## Installation

From [CRAN](https://CRAN.R-project.org/package=simfinapi):

``` r
install.packages("simfinapi")
```

If you want to try out the newest features you may want to give the development version a try and install it from [GitHub](https://github.com/matthiasgomolka/simfinapi):

``` r
remotes::install_github("https://github.com/matthiasgomolka/simfinapi")
```

## Setup

Using simfinapi is much more convenient if you set your API key and cache directory[1] globally before you start downloading data. See `?sfa_set_api_key` and `?sfa_set_cache_dir` for details.

## Code of Conduct

Please note that the 'simfinapi' project is released with a [Contributor Code of Conduct](https://github.com/matthiasgomolka/simfinapi/blob/master/.github/CODE_OF_CONDUCT.md). By contributing to this project, you agree to abide by its terms.

## Relation to `simfinR`

In case you also found `simfinR` ([CRAN](https://CRAN.R-project.org/package=simfinR), [GitHub](https://github.com/msperlin/simfinR/)) you might want to know about the differences between the `simfinapi` and `simfinR`. I tried to compile a list in [this issue](https://github.com/matthiasgomolka/simfinapi/issues/22#issuecomment-847270864).

------------------------------------------------------------------------

[1] simfinapi always caches the results from your API calls to obtain results quicker and to reduce the number of API calls. If you set the cache directory to a permanent directory (the default is `tempdir()`), simfinapi will be able to reuse this cache in subsequent R sessions.
