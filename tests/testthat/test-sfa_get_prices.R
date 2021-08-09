ref_names <- c("SimFinId", "Ticker", "Date", "Currency", "Open", "High", "Low", "Close", "Adj. Close", "Volume", "Dividend", "Common Shares Outstanding")
ref_names <- clean_names(ref_names)
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
    key = "ticker",
    types = ref_classes,
    ncols = length(ref_names)
  )
  expect_named(ref_1, ref_names)
  expect_identical(unique(ref_1[["ticker"]]), "GOOG")
  expect_identical(
    ref_1[["date"]],
    `attr<-`(sort(ref_1[["date"]]), "label", "Date")
  )
})

test_that("search for two Tickers works including correct order", {
  checkmate::expect_data_table(
    ref_2,
    key = "ticker",
    types = ref_classes,
    ncols = length(ref_names)
  )
  expect_named(ref_2, ref_names)
  expect_gt(nrow(ref_2), nrow(ref_1))
  expect_identical(unique(ref_2[["ticker"]]), c("AAPL", "GOOG"))
  expect_identical(
    ref_2[["date"]],
    `attr<-`(
      Reduce(c, tapply(ref_2[["date"]], ref_2[["ticker"]], sort)),
      "label",
      "Date"
    )
  )
})



test_that("sfa_get_price returns null and warnings if ticker not found", {
  expect_warning(
    expect_null(sfa_get_prices("ZZZZZ")),
    "No company found for ticker `ZZZZZ`.",
    fixed = TRUE
  )
  warnings <- capture_warnings(expect_null(sfa_get_prices(c("ZZZZZ", "ZZZZZZ"))))
  expect_identical(
    warnings,
    paste0("No company found for ticker `", c("ZZZZZ", "ZZZZZZ"), "`.")
  )
})

test_that("sfa_get_price returns null and warnings if simfin_id not found", {
  expect_warning(
    expect_null(sfa_get_prices(simfin_id = 1)),
    'No company found for simfin_id `1`.',
    fixed = TRUE
  )
  warnings <- capture_warnings(expect_null(sfa_get_prices(simfin_id = 1:2)))
  expect_identical(
    warnings,
    paste0('No company found for simfin_id `', 1:2, '`.')
  )
})
