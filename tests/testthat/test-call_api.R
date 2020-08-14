test_that("warning is issued if cache is not set yet", {
  expect_warning(
    sfa_get_entities(cache_dir = NULL),
    "'cache_dir' not set.",
    fixed = TRUE
  )
})
