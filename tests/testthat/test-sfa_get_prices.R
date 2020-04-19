library(data.table)

context("sfa_get_prices")
n <- 4L
ref <- data.table(
    simId = sort(rep_len(c(18L, 242L), n)),
    date = as.Date(paste0("2020-01-0", 3:2)),
    closeAdj = c(1360.66, 1367.37, 35.83, 36.19),
    splitCoef = NA_real_,
    currency = "USD",
    key = "simId"
)

test_that("search for single id works", {
    expect_identical(
        sfa_get_price(242, "2020-01-01", "2020-01-03"),
        ref[3:4]
    )
    expect_identical(
        sfa_get_price(242L, "2020-01-01", "2020-01-03"),
        ref[3:4]
    )
})

test_that("search for two id's works including correct order", {
    expect_identical(
        sfa_get_price(c(18L, 242L), "2020-01-01", "2020-01-03"),
        ref
    )
    expect_identical(
        sfa_get_price(c(242L, 18L), "2020-01-01", "2020-01-03"),
        ref
    )
    expect_identical(
        sfa_get_price(c(18, 242L), "2020-01-01", "2020-01-03"),
        ref
    )
})

test_that("search for non-existent ID yields warning from API", {
    expect_warning(
        sfa_get_price(1L),
        "no share classes found for company",
        fixed = TRUE
    )
    expect_warning(
        expect_identical(
            sfa_get_price(c(1L, 18L), "2020-01-01", "2020-01-03"),
            ref[1:2]
        ),
        "no share classes found for company",
        fixed = TRUE
    )
})

test_that("sfa_get_price returns error if inputs are incorrect", {
    expect_error(
        sfa_get_price("A"),
        "Assertion on 'simId' failed: Must be of type 'integerish', not 'character'.",
        fixed = TRUE
    )

    expect_error(
        sfa_get_price(18L, start = "20200101"),
        "Assertion on 'start' failed: Must comply to pattern '^[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}$'.",
        fixed = TRUE
    )

    expect_error(
        sfa_get_price(18L, end = "20200101"),
        "Assertion on 'end' failed: Must comply to pattern '^[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}$'.",
        fixed = TRUE
    )

    expect_error(
        sfa_get_price(18L, api_key = "invalid_api_key"),
        "Assertion on 'api_key' failed: Must comply to pattern '[[:alnum:]]{32}'.",
        fixed = TRUE
    )

    expect_warning(
        sfa_get_price(18L, api_key = "invalidApiKkeyOfCorrectLength123"),
        "Error, API key not found. Check your key at simfin.com/data/access/api or contact info@simfin.com",
        fixed = TRUE
    )
})
