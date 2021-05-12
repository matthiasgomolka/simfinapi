library(data.table)

ref <- data.table(
  simfin_id = c(18L, 59265L),
  ticker = c("GOOG", "MSFT"),
  company_name = c("Alphabet (Google)", "MICROSOFT CORP"),
  industry_id = c(101002L, 101003L),
  month_fy_end = c(12L, 6L),
  number_employees = c(98771L, 166475L),
  key = "ticker"
)
labels <- c(
  "SimFinId", "Ticker", "Company Name", "IndustryId", "Month FY End",
  "Number Employees"
)
for (i in seq_along(ref)) {
  setattr(ref[[i]], "label", labels[i])
}

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
