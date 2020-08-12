library(checkmate)

test_that("sfa_get_entities returns correctly structured data.table", {
  entities <- sfa_get_entities()

  expect_data_table(
    entities,
    key = "Ticker",
    types = c("integer", "character"),
    any.missing = FALSE,
    min.rows = 2000L,
    ncols = 2L,
    col.names = "strict"
  )
  expect_named(entities, c("SimFinId", "Ticker"))
})

test_that("sfa_get_entities returns error if api key is incorrect", {
  expect_error(
    sfa_get_entities("invalid_api_key"),
    "Assertion on 'api_key' failed: Must comply to pattern '^[[:alnum:]]{32}$'.",
    fixed = TRUE
  )
  expect_warning(
    sfa_get_entities("invalidApiKkeyOfCorrectLength123"),
    "Error, API key not found. Check your key at simfin.com/data/access/api or contact info@simfin.com",
    fixed = TRUE
  )
})
