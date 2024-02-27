test_that("setting temporary cache dir works", {
    # verify that cache_dir is not set
    options(sfa_cache_dir = NULL)
    expect_identical(getOption("sfa_cache_dir"), NULL)

    # download any data
    expect_warning(checkmate::expect_data_table(sfa_load_companies(cache_dir = NULL)), "'cache_dir' not set. Defaulting to 'tempdir()'. Thus, API results will only be cached during this session. To learn why and how to cache results over the end of this session, see `?sfa_set_cache_dir`.\n\n[This warning appears only once per session.]",
        fixed = TRUE)

    # verify that cache_dir is set
    expect_identical(getOption("sfa_cache_dir"), tempdir())
})
