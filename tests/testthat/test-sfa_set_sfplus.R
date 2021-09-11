test_that("specifying sfplus works", {
  options(sfa_sfplus = NULL)
  expect_null(getOption("sfa_sfplus"))
  sfa_set_sfplus()
  expect_true(getOption("sfa_sfplus"))
  sfa_set_sfplus(FALSE)
  expect_false(getOption("sfa_sfplus"))
})
