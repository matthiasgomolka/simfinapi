ref <- data.table::data.table(
  simfin_id = c(18L, 59265L),
  ticker = c("GOOG", "MSFT"),
  company_name = c("Alphabet (Google)", "MICROSOFT CORP"),
  industry_id = c(101002L, 101003L),
  month_fy_end = c(12L, 6L),
  number_employees = c(135301L, 166475L),
  key = "ticker"
)
labels <- c(
  "SimFinId", "Ticker", "Company Name", "IndustryId", "Month FY End",
  "Number Employees"
)
for (i in seq_along(ref)) {
  setattr(ref[[i]], "label", labels[i])
}

for (sfplus in c(TRUE, FALSE)) {
  sfa_set_sfplus(sfplus)
  if (isTRUE(sfplus)) {
    options(sfa_api_key = Sys.getenv("SFPLUS_API_KEY"))
  } else {
    options(sfa_api_key = Sys.getenv("SF_API_KEY"))
  }

  test_that("search via tickers works", {
    # Restrict columns to those which are in 'ref'. This way, I don't need to
    # update the test so often.
    expect_identical(
      sfa_get_info(ticker = c("GOOG", "MSFT"))[, names(ref), with = FALSE],
      ref
    )
    expect_identical(
      sfa_get_info(ticker = c("MSFT", "GOOG"))[, names(ref), with = FALSE],
      ref
    )
  })

  test_that("search via simfin_ids works", {
    expect_identical(
      sfa_get_info(simfin_id = c(18L, 59265L))[, names(ref), with = FALSE],
      ref
    )
    expect_identical(
      sfa_get_info(simfin_id = c(18, 59265))[, names(ref), with = FALSE],
      ref
    )
    expect_identical(
      sfa_get_info(simfin_id = c(59265L, 18L))[, names(ref), with = FALSE],
      ref
    )
  })

  test_that("search via ticker and simfin_id works", {
    expect_identical(
      sfa_get_info(ticker = "GOOG", simfin_id = 59265L)[, names(ref), with = FALSE],
      ref
    )
    expect_identical(
      sfa_get_info(ticker = "MSFT", simfin_id = 18)[, names(ref), with = FALSE],
      ref
    )
  })


  test_that("search for non-existent ticker / simfin_id yields warning", {
    expect_error(
      expect_warning(
        sfa_get_info("does_not_exist"),
        'No company found for ticker `does_not_exist`.',
        fixed = TRUE
      ),
      "Please provide at least one one valid 'ticker' or 'simfin_id'.",
      fixed = TRUE
    )
    expect_warning(
      expect_identical(
        sfa_get_info(simfin_id = c(1L, 18L, 59265L))[, names(ref), with = FALSE],
        ref
      ),
      "No company found for simfin_id `1`",
      fixed = TRUE
    )
  })

  test_that("supplying neiterh ticker / simfin_id yields error", {
    expect_error(sfa_get_info())
  })
}
