test_that("checks on Ticker and SimFinId are not too strict", {
  entities <- sfa_get_entities()

  checkmate::expect_data_table(
    sfa_get_info(SimFinId = entities[["SimFinId"]])
  )
  checkmate::expect_data_table(
    sfa_get_info(Ticker = entities[["Ticker"]])
  )
})
