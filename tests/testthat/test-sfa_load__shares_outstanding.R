# for (sfplus in c(TRUE, FALSE)) { sfa_set_sfplus(sfplus) if (isTRUE(sfplus)) { options(sfa_api_key =
# Sys.getenv('SFPLUS_API_KEY')) } else { options(sfa_api_key = Sys.getenv('SF_API_KEY')) } test_that('sfa_get_prices()
# works for type = common', { ref_names <- c('id', 'ticker', 'date', 'shares_outstanding_common') ref_classes <- c(
# 'integer', 'character', 'Date', 'integer64' ) names(ref_classes) <- ref_names res_1 <- sfa_get_shares('GOOG', type =
# 'common') checkmate::expect_data_table( res_1, key = 'ticker', types = ref_classes, ncols = length(ref_names) )
# expect_named(res_1, ref_names) expect_identical(unique(res_1[['ticker']]), 'GOOG') expect_identical( res_1[['date']],
# `attr<-`(res_1[['date']], 'label', 'Date') ) res_2 <- sfa_get_shares(c('GOOG', 'AMZN'), type = 'common')
# checkmate::expect_data_table( res_2, key = 'ticker', types = ref_classes, ncols = length(ref_names) )
# expect_named(res_2, ref_names) expect_identical(unique(res_2[['ticker']]), c('AMZN', 'GOOG')) expect_identical(
# res_2[['date']], `attr<-`(res_2[['date']], 'label', 'Date') ) res_3 <- sfa_get_shares(c('GOOG', 'AMZN'), type =
# 'common', period = 'q1') expect_identical(res_3, res_2) # since fyear is only relevant for types 'wa-basic' and
# 'wa-diluted' res_4 <- sfa_get_shares(c('GOOG', 'AMZN'), type = 'common', fyear = 2019:2020) expect_identical(res_4,
# res_2) # since fyear is only relevant for types 'wa-basic' and 'wa-diluted' if (isTRUE(sfplus)) { date <-
# as.Date('2020-01-01') res_5 <- sfa_get_shares(c('GOOG', 'AMZN'), type = 'common', start = date)
# checkmate::expect_data_table( res_5, key = 'ticker', types = ref_classes, ncols = length(ref_names) )
# expect_named(res_5, ref_names) expect_identical(unique(res_5[['ticker']]), c('AMZN', 'GOOG')) expect_identical(
# res_5[['date']], `attr<-`(res_5[['date']], 'label', 'Date') ) expect_gte(min(res_5[['date']]), date) res_6 <-
# sfa_get_shares(c('GOOG', 'AMZN'), type = 'common', end = date) checkmate::expect_data_table( res_6, key = 'ticker',
# types = ref_classes, ncols = length(ref_names) ) expect_named(res_6, ref_names)
# expect_identical(unique(res_6[['ticker']]), c('AMZN', 'GOOG')) expect_identical( res_6[['date']],
# `attr<-`(res_6[['date']], 'label', 'Date') ) expect_lte(max(res_6[['date']]), date) } else { date <-
# as.Date('2020-01-01') expect_error( sfa_get_shares(c('GOOG', 'AMZN'), type = 'common', start = date), 'Specifying
# 'start' is reserved for SimFin+ users.', fixed = TRUE ) expect_error( sfa_get_shares(c('GOOG', 'AMZN'), type =
# 'common', end = date), 'Specifying 'end' is reserved for SimFin+ users.', fixed = TRUE ) } })
# test_that('sfa_get_prices() works for type != common', { for (type in c('wa-basic', 'wa-diluted')) { # TODO: This
# needs more tests, but it makes more sense after implementing # https://github.com/matthiasgomolka/simfinapi/issues/33
# ref_names <- c( 'id', 'ticker', 'fiscal_period', 'fiscal_year', 'report_date', 'ttm', paste0('shares_outstanding_',
# sub('-', '_', fixed = TRUE, type)) ) ref_classes <- c( 'integer', 'character', 'character', 'integer', 'Date',
# 'logical', 'integer64' ) names(ref_classes) <- ref_names if (isTRUE(sfplus)) { res_7 <- sfa_get_shares('GOOG', type =
# type) } else { expect_error( sfa_get_shares('GOOG', type = type), 'Omitting 'fyear' is reserved for SimFin+ users.',
# fixed = TRUE ) res_7 <- sfa_get_shares('GOOG', type = type, fyear = 2015L) } checkmate::expect_data_table( res_7, key
# = 'ticker', types = ref_classes, min.rows = 8L, ncols = length(ref_names) ) expect_identical(
# sort(unique(res_7[['fiscal_period']])), c('9M', 'FY', 'H1', 'H2', 'Q1', 'Q2', 'Q3', 'Q4') ) expect_named(res_7,
# ref_names) expect_identical(unique(res_7[['ticker']]), 'GOOG') } }) }
