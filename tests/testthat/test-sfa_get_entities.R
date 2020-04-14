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
