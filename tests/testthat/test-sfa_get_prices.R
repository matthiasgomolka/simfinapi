ref_names <- c("SimFinId", "Ticker", "Date", "Currency", "Open", "High", "Low", "Close", "Adj. Close", "Volume", "Dividend", "Common Shares Outstanding")
ref_classes <- c(
  "integer", "character", "Date", "character", "numeric", "numeric", "numeric",
  "numeric", "numeric", "numeric", "numeric", "numeric"
)
names(ref_classes) <- ref_names

ref_1 <- sfa_get_prices("GOOG")
ref_2 <- sfa_get_prices(c("GOOG", "AAPL"))

test_that("search for single Ticker works", {
  checkmate::expect_data_table(
    ref_1,
    key = "Ticker",
    types = ref_classes,
    ncols = length(ref_names)
  )
  expect_named(ref_1, ref_names)
  expect_identical(unique(ref_1[["Ticker"]]), "GOOG")
  expect_identical(ref_1[["Date"]], sort(ref_1[["Date"]]))
})

test_that("search for two Tickers works including correct order", {
  checkmate::expect_data_table(
    ref_2,
    key = "Ticker",
    types = ref_classes,
    ncols = length(ref_names)
  )
  expect_named(ref_2, ref_names)
  expect_gt(nrow(ref_2), nrow(ref_1))
  expect_identical(unique(ref_2[["Ticker"]]), c("AAPL", "GOOG"))
  expect_identical(
    ref_2[["Date"]],
    Reduce(c, tapply(ref_2[["Date"]], ref_2[["Ticker"]], sort))
  )
})



test_that("sfa_get_price returns null and warnings if Ticker not found", {
  expect_warning(
    expect_null(sfa_get_prices("Z")),
    'No company found for Ticker "Z".',
    fixed = TRUE
  )
  warnings <- capture_warnings(expect_null(sfa_get_prices(c("Z", "ZZ"))))
  expect_identical(
    warnings,
    paste0('No company found for Ticker "', c("Z", "ZZ"), '".')
  )
})

test_that("sfa_get_price returns null and warnings if SimFinId not found", {
  expect_warning(
    expect_null(sfa_get_prices(SimFinId = 1)),
    'No company found for SimFinId `1`.',
    fixed = TRUE
  )
  warnings <- capture_warnings(expect_null(sfa_get_prices(SimFinId = 1:2)))
  expect_identical(
    warnings,
    paste0('No company found for SimFinId `', 1:2, '`.')
  )
})
