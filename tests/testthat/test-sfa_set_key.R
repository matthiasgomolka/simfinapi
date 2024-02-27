test_key <- "InvalidApiKeyOfCorrectLength1234"
Sys.setenv(SIMFIN_TEST_KEY = test_key)
on.exit(Sys.unsetenv("SIMFIN_TEST_KEY"))

test_that("setting the API key directly works", {
    expect_identical(sfa_set_api_key(api_key = test_key), test_key)
    expect_identical(getOption("sfa_api_key"), test_key)

    # expect_error(sfa_set_api_key(api_key = "invalid_key"))
})

test_that("setting the API via environment variable works", {
    expect_identical(sfa_set_api_key(env_var = "SIMFIN_TEST_KEY"), test_key)
    expect_identical(getOption("sfa_api_key"), test_key)

    # expect_error(sfa_set_api_key(env_var = "invalid_env_var"))
})

test_that("api_key is ignored if env_var is specified", {
    options(sfa_api_key = NULL)
    warning <- capture_warnings(expect_identical(sfa_set_api_key(api_key = "InvalidApiKeyOfCorrectLength5678", env_var = "SIMFIN_TEST_KEY"),
        test_key))

    expect_identical(warning, "Both 'api_key' and 'env_var' provided. Ignoring 'api_key'.")
    expect_identical(getOption("sfa_api_key"), test_key)
})

test_that("error is thrown if no argument is specified", {
    expect_error(sfa_set_api_key(), "No arguments specified.", fixed = TRUE)
})
