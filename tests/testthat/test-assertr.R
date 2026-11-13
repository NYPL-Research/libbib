context("checking the assertr predicates inside assertr::assert()")


##############################################
###               SETUP                    ###
##############################################

# puts a vector in a one-column data.frame and runs it through
# assertr::assert() with the given predicate.
# returns TRUE if the assertion passes and FALSE if it is violated
passes_assert <- function(avector, predicate){
  assertr::assert(data.frame(code=avector, stringsAsFactors=FALSE),
                  predicate, code,
                  success_fun=assertr::success_logical,
                  error_fun=assertr::error_logical)
}

# before assertr 3.1.0, a predicate returning NA (and a data.frame
# with no rows) stopped assert() with an R error, so those cases
# are only tested with assertr >= 3.1.0


# --------------------------------------------------------------- #


# the mark that makes assert() call a predicate once per column
# (instead of once per element)
test_that("the predicates are marked as vectorized for assertr", {
  expect_true(attr(is_valid_isbn_10, "assertr_vectorized"))
  expect_true(attr(is_valid_isbn_13, "assertr_vectorized"))
  expect_true(attr(is_valid_issn, "assertr_vectorized"))
  expect_true(attr(is_valid_lc_call, "assertr_vectorized"))
})


# is_valid_isbn_10
test_that("is_valid_isbn_10() works in assert()", {
  skip_if_not_installed("assertr")
  expect_true(passes_assert(c("012491540X", "9004037810"), is_valid_isbn_10))
  expect_false(passes_assert(c("012491540X", "0124915401"), is_valid_isbn_10))
})

test_that("is_valid_isbn_10() handles NAs and no rows in assert()", {
  skip_if_not_installed("assertr", "3.1.0")
  expect_false(passes_assert(c("012491540X", NA), is_valid_isbn_10))
  expect_false(passes_assert(c(NA_character_, NA), is_valid_isbn_10))
  expect_true(passes_assert(character(0), is_valid_isbn_10))
})


# is_valid_isbn_13
test_that("is_valid_isbn_13() works in assert()", {
  skip_if_not_installed("assertr")
  expect_true(passes_assert(c("9780306406157", "9783161484100"), is_valid_isbn_13))
  expect_false(passes_assert(c("9780306406157", "9780306406151"), is_valid_isbn_13))
})

test_that("is_valid_isbn_13() handles NAs and no rows in assert()", {
  skip_if_not_installed("assertr", "3.1.0")
  expect_false(passes_assert(c("9780306406157", NA), is_valid_isbn_13))
  expect_false(passes_assert(c(NA_character_, NA), is_valid_isbn_13))
  expect_true(passes_assert(character(0), is_valid_isbn_13))
})


# is_valid_issn
test_that("is_valid_issn() works in assert()", {
  skip_if_not_installed("assertr")
  expect_true(passes_assert(c("2434561X", "03785955"), is_valid_issn))
  expect_false(passes_assert(c("2434561X", "24345611"), is_valid_issn))
})

test_that("is_valid_issn() handles NAs and no rows in assert()", {
  skip_if_not_installed("assertr", "3.1.0")
  expect_false(passes_assert(c("2434561X", NA), is_valid_issn))
  expect_false(passes_assert(c(NA_character_, NA), is_valid_issn))
  expect_true(passes_assert(character(0), is_valid_issn))
})


# is_valid_lc_call
test_that("is_valid_lc_call() works in assert()", {
  skip_if_not_installed("assertr")
  expect_true(passes_assert(c("Q172.5.E77", "PR6023.A93"), is_valid_lc_call))
  expect_false(passes_assert(c("Q172.5.E77", "AF172"), is_valid_lc_call))
})

test_that("is_valid_lc_call() handles NAs and no rows in assert()", {
  skip_if_not_installed("assertr", "3.1.0")
  expect_false(passes_assert(c("Q172.5.E77", NA), is_valid_lc_call))
  expect_false(passes_assert(c(NA_character_, NA), is_valid_lc_call))
  expect_true(passes_assert(character(0), is_valid_lc_call))
})

