test_that("checks on ticker and simfin_id are not too strict", {
  skip("Very slow")

  entities <- sfa_get_entities()

  checkmate::expect_data_table(
    sfa_get_info(simfin_id = entities[["simfin_id"]])
  )
  checkmate::expect_data_table(
    sfa_get_info(ticker = entities[["ticker"]])
  )
})
