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


# test_that("search for Tickers and  works including correct order", {
#   checkmate::expect_data_table(
#     ref_2,
#     key = "Ticker",
#     types = ref_classes,
#     ncols = length(ref_names)
#   )
#   expect_named(ref_2, ref_names)
#   expect_gt(nrow(ref_2), nrow(ref_1))
#   expect_identical(unique(ref_2[["Ticker"]]), c("AAPL", "GOOG"))
# })
# test_that("search for non-existent ID yields warning from API", {
#   expect_warning(
#     sfa_get_price(1L),
#     "no share classes found for company",
#     fixed = TRUE
#   )
#   expect_warning(
#     expect_identical(
#       sfa_get_price(c(1L, 18L), "2020-01-01", "2020-01-03"),
#       ref[1:2]
#     ),
#     "no share classes found for company",
#     fixed = TRUE
#   )
# })
#
# test_that("sfa_get_price returns error if inputs are incorrect", {
#   expect_error(
#     sfa_get_price("A"),
#     "Assertion on 'simId' failed: Must be of type 'integerish', not 'character'.",
#     fixed = TRUE
#   )
#
#   expect_error(
#     sfa_get_price(18L, start = "20200101"),
#     "Assertion on 'start' failed: Must comply to pattern '^[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}$'.",
#     fixed = TRUE
#   )
#
#   expect_error(
#     sfa_get_price(18L, end = "20200101"),
#     "Assertion on 'end' failed: Must comply to pattern '^[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}$'.",
#     fixed = TRUE
#   )
#
#   expect_error(
#     sfa_get_price(18L, api_key = "invalid_api_key"),
#     "Assertion on 'api_key' failed: Must comply to pattern '[[:alnum:]]{32}'.",
#     fixed = TRUE
#   )
#
#   expect_warning(
#     sfa_get_price(18L, api_key = "invalidApiKkeyOfCorrectLength123"),
#     "Error, API key not found. Check your key at simfin.com/data/access/api or contact info@simfin.com",
#     fixed = TRUE
#   )
# })
