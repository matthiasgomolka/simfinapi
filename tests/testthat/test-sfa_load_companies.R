library(checkmate)

test_that("sfa_load_companies works with details = FALSE/TRUE", {
  col_order <- c(
    "id",
    "name",
    "ticker",
    "isin",
    "sectorCode",
    "sectorName",
    "industryName",
    "market",
    "endFy",
    "numEmployees",
    "companyDescription"
  )
  for (details in c(FALSE, TRUE)) {
    entities <- sfa_load_companies(details = details)
    expect_data_table(
      entities,
      key = "id",
      types = c("integer", "character"),
      min.rows = 4000L,
      min.cols = 7L,
      max.cols = 11L,
      col.names = "strict"
    )
    expect_named(entities, intersect(col_order, names(entities)))
  }
})

test_that("sfa_get_entities returns error if api key is incorrect", {
  expect_error(
    sfa_load_companies("invalid_api_key"),
    "SimFin API Error 401: Invalid API Key - check the key again and also if you confirmed your e-mail on registration",
    fixed = TRUE
  )
})
