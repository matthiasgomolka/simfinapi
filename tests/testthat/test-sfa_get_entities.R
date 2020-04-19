library(data.table)

context("sfa_get_entities")
entities <- sfa_get_entities()

test_that("sfa_get_entities returns correctly structures data.table", {
    expect_type(entities, "list")
    expect_true(inherits(entities, "data.table"))
    expect_identical(
        names(entities), c("simId", "ticker", "name")
    )
    expect_type(entities[["simId"]], "integer")
    expect_type(entities[["ticker"]], "character")
    expect_type(entities[["name"]], "character")
})

test_that("sfa_get_entities returns error if api key is incorrect", {
    expect_error(
        sfa_get_entities("invalid_api_key"),
        "Assertion on 'api_key' failed: Must comply to pattern '[[:alnum:]]{32}'.",
        fixed = TRUE
    )
    expect_warning(
        sfa_get_entities("invalidApiKkeyOfCorrectLength123"),
        "Error, API key not found. Check your key at simfin.com/data/access/api or contact info@simfin.com",
        fixed = TRUE
    )
})
