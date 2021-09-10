ref_names <- c("SimFinId", "Ticker", "Date", "Currency", "Open", "High", "Low", "Close", "Adj. Close", "Volume", "Dividend", "Common Shares Outstanding")
ref_names <- clean_names(ref_names)
ref_classes <- c(
  "integer", "character", "Date", "character", "numeric", "numeric", "numeric",
  "numeric", "numeric", "numeric", "numeric", "numeric"
)
names(ref_classes) <- ref_names


for (sfplus in c(TRUE, FALSE)) {
  sfa_set_sfplus(sfplus)
  if (isTRUE(sfplus)) {
    options(sfa_api_key = Sys.getenv("SFPLUS_API_KEY"))
  } else {
    options(sfa_api_key = Sys.getenv("SF_API_KEY"))
  }

  res_1 <- sfa_get_prices("GOOG")

  test_that("search for single Ticker works", {
    checkmate::expect_data_table(
      res_1,
      key = "ticker",
      types = ref_classes,
      ncols = length(ref_names)
    )
    expect_named(res_1, ref_names)
    expect_identical(unique(res_1[["ticker"]]), "GOOG")
    expect_identical(
      res_1[["date"]],
      `attr<-`(sort(res_1[["date"]]), "label", "Date")
    )
  })

  res_2 <- sfa_get_prices(c("GOOG", "AAPL"))

  test_that("search for two Tickers works including correct order", {
    checkmate::expect_data_table(
      res_2,
      key = "ticker",
      types = ref_classes,
      ncols = length(ref_names)
    )
    expect_named(res_2, ref_names)
    expect_gt(nrow(res_2), nrow(res_1))
    expect_identical(unique(res_2[["ticker"]]), c("AAPL", "GOOG"))
    expect_identical(
      res_2[["date"]],
      `attr<-`(
        Reduce(c, tapply(res_2[["date"]], res_2[["ticker"]], sort)),
        "label",
        "Date"
      )
    )
  })

  dates <- as.Date(c("2021-01-04", "2021-01-8"))

  if (isTRUE(sfplus)) {
    res_3 <- sfa_get_prices(
      c("GOOG", "AAPL"),
      start = dates[1],
      end = dates[2]
    )

    test_that("search for two Tickers and start date works", {
      checkmate::expect_data_table(
        res_3,
        key = "ticker",
        types = ref_classes,
        nrows = 10L,
        ncols = length(ref_names)
      )
      expect_named(res_3, ref_names)
      expect_identical(unique(res_3[["ticker"]]), c("AAPL", "GOOG"))
      expect_identical(range(res_3[["date"]]), dates)
      expect_identical(
        res_3[["date"]],
        `attr<-`(
          Reduce(c, tapply(res_3[["date"]], res_3[["ticker"]], sort)),
          "label",
          "Date"
        )
      )
    })
  } else {

    expect_error(
      sfa_get_prices(c("GOOG", "AAPL"), start = dates[1], end = dates[2]),
      "Specifying 'start' is reserved for SimFin+ users.",
      fixed = TRUE
    )
  }


  test_that("sfa_get_price returns null and warnings if ticker not found", {
    expect_error(
      expect_warning(
        sfa_get_prices("ZZZZZ"),
        "No company found for ticker `ZZZZZ`.",
        fixed = TRUE
      ),
      "Please provide at least one one valid 'ticker' or 'simfin_id'.",
      fixed = TRUE
    )
    warnings <- capture_warnings(
      expect_error(
        sfa_get_prices(c("ZZZZZ", "ZZZZZZ")),
        "Please provide at least one one valid 'ticker' or 'simfin_id'.",
        fixed = TRUE
      ))
    expect_identical(
      warnings,
      paste0("No company found for ticker `", c("ZZZZZ", "ZZZZZZ"), "`.")
    )
  })

  test_that("sfa_get_price returns null and warnings if simfin_id not found", {
    expect_error(
      expect_warning(
        expect_null(sfa_get_prices(simfin_id = 1)),
        'No company found for simfin_id `1`.',
        fixed = TRUE
      ),
      "Please provide at least one one valid 'ticker' or 'simfin_id'.",
      fixed = TRUE
    )

    warnings <- capture_warnings(
      expect_error(
        sfa_get_prices(simfin_id = 1:2),
        "Please provide at least one one valid 'ticker' or 'simfin_id'.",
        fixed = TRUE
      )
    )
    expect_identical(
      warnings,
      paste0('No company found for simfin_id `', 1:2, '`.')
    )
  })

}
