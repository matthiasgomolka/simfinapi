test_that("setting the cache directory to existing directory works", {
    expect_identical(sfa_set_cache_dir(tempdir()), tempdir())
    expect_identical(getOption("sfa_cache_dir"), tempdir())
})

test_that("setting the cache directory to new directory works", {
    new_dir <- tempfile("dir")

    expect_error(sfa_set_cache_dir(new_dir), paste0(
        "'", new_dir, "' does not exist. Use 'create = TRUE' to create it on ",
        "the fly."
    ), fixed = TRUE)
    expect_identical(sfa_set_cache_dir(new_dir, create = TRUE), new_dir)
    expect_identical(getOption("sfa_cache_dir"), new_dir)
})
