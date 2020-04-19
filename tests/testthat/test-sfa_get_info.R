library(data.table)

context("sfa_get_info")
ref <- data.table(
    simId = c(18L, 59265L),
    ticker = c("GOOG", "MSFT"),
    name = c("Alphabet", "MICROSOFT CORP"),
    fyearEnd = c(12L, 6L),
    employees = c(98771L, 144000L),
    sectorName = c("Online Media", "Application Software"),
    sectorCode = c(101002L, 101003L),
    key = "simId"
)

test_that("search for single id works", {
  expect_identical(sfa_get_info(59265L), ref[2])
  expect_identical(sfa_get_info(59265),  ref[2])
})

test_that("search for two id's works including correct order", {
    expect_identical(sfa_get_info(c(18L, 59265L)), ref)
    expect_identical(sfa_get_info(c(59265L, 18L)), ref)
    expect_identical(sfa_get_info(c(18, 59265L)), ref)
})

test_that("search for non-existent ID yields warning from API", {
    expect_warning(
        sfa_get_info(1L),
        "company not found, check SimFin ID",
        fixed = TRUE
    )
    expect_warning(
        expect_identical(
            sfa_get_info(c(1L, 18L)),
            ref[1L]
        ),
        "company not found, check SimFin ID",
        fixed = TRUE
    )
})
