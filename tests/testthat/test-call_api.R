test_that("setting temporary cache dir works", {
  expect_warning(
    call_api(
      path = list("api/v2/companies/list/"),
      query = list("api-key" = Sys.getenv("SFPLUS_API_KEY")),
      cache_dir = NULL
    ),
    "'cache_dir' not set. Defaulting to 'tempdir()'. Thus, API results will only be cached during this session. To learn why and how to cache results over the end of this session, see `?sfa_set_cache_dir`.\n\n[This warning appears only once per session.]",
    fixed = TRUE
  )
})
