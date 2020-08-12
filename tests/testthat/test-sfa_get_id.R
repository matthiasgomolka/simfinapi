# library(data.table)
#
# context("sfa_get_id")
# ref_msft <- data.table(
#   simId = 59265L,
#   ticker = "MSFT",
#   name = "MICROSOFT CORP",
#   key = "simId"
# )
# test_that("search for single id works", {
#   expect_identical(sfa_get_id("MSFT"), ref_msft)
#   expect_identical(sfa_get_id("Microsoft", by = "name"), ref_msft)
# })
#
# ref_msft_gs <- rbind(
#   data.table(
#     simId = 60439L,
#     ticker = "GS",
#     name = "GOLDMAN SACHS GROUP INC"
#   ),
#   ref_msft
# )
# setkeyv(ref_msft_gs, "simId")
#
# test_that("search for two id's works", {
#   expect_identical(sfa_get_id(c("MSFT", "GS")), ref_msft_gs)
#   expect_identical(
#     sfa_get_id(c("Microsoft", "Goldman"), by = "name"),
#     ref_msft_gs
#   )
# })
#
# ref_0 <- data.table::data.table(
#   simId = integer(),
#   ticker = character(),
#   name = character(),
#   key = "simId"
# )
# test_that("search for incorrect terms yields no result", {
#   expect_warning(
#     expect_identical(
#       sfa_get_id("thisIdDoesNotExist"),
#       ref_0
#     ),
#     "No match for 'thisIdDoesNotExist'.",
#     fixed = TRUE
#   )
#   expect_warning(
#     expect_identical(
#       sfa_get_id(c("MSFT", "thisIdDoesNotExist")),
#       ref_msft
#     ),
#     "No match for 'thisIdDoesNotExist'.",
#     fixed = TRUE
#   )
# })
#
# test_that("sfa_get_id returns error if api key is incorrect", {
#   expect_error(
#     sfa_get_id("MSFT", api_key = "invalid_api_key"),
#     "Assertion on 'api_key' failed: Must comply to pattern '[[:alnum:]]{32}'.",
#     fixed = TRUE
#   )
#   expect_warning(
#     sfa_get_id("MSFT", api_key = "invalidApiKkeyOfCorrectLength123"),
#     "Error, API key not found. Check your key at simfin.com/data/access/api or contact info@simfin.com",
#     fixed = TRUE
#   )
# })
