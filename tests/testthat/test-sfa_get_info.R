library(data.table)

ref <- data.table(
  SimFinId = c(18L, 59265L),
  Ticker = c("GOOG", "MSFT"),
  `Company Name` = c("Alphabet (Google)", "MICROSOFT CORP"),
  `IndustryId` = c(101002L, 101003L),
  `Month FY End` = c(12L, 6L),
  `Number Employees` = c(98771L, 163000L),
  key = "Ticker"
)

test_that("search via Tickers works", {
  # Restrict columns to those which are in 'ref'. This way, I don't need to
  # update the test so often.
  expect_identical(
    sfa_get_info(Ticker = c("GOOG", "MSFT"))[, names(ref), with = FALSE],
    ref
  )
  expect_identical(
    sfa_get_info(Ticker = c("MSFT", "GOOG"))[, names(ref), with = FALSE],
    ref
  )
})

test_that("search via SimFinIds works", {
  expect_identical(
    sfa_get_info(SimFinId = c(18L, 59265L))[, names(ref), with = FALSE],
    ref
  )
  expect_identical(
    sfa_get_info(SimFinId = c(18, 59265))[, names(ref), with = FALSE],
    ref
  )
  expect_identical(
    sfa_get_info(SimFinId = c(59265L, 18L))[, names(ref), with = FALSE],
    ref
  )
})

test_that("search via Ticker and SimFinId works", {
  expect_identical(
    sfa_get_info(Ticker = "GOOG", SimFinId = 59265L)[, names(ref), with = FALSE],
    ref
  )
  expect_identical(
    sfa_get_info(Ticker = "MSFT", SimFinId = 18)[, names(ref), with = FALSE],
    ref
  )
})


test_that("search for non-existent Ticker / SimFinId yields warning", {
  expect_warning(
    expect_null(sfa_get_info("does_not_exist")),
    'No company found for Ticker "does_not_exist".',
    fixed = TRUE
  )
  expect_warning(
    expect_identical(
      sfa_get_info(SimFinId = c(1L, 18L, 59265L))[, names(ref), with = FALSE],
      ref
    ),
    "No company found for SimFinId `1`",
    fixed = TRUE
  )
})

test_that("supplying neiterh Ticker / SimFinId yields error", {
  expect_error(sfa_get_info())
})
