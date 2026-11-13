context("checking functions in marc-field-deconstruction.R")


data("books_serials_etc_sample")

# marc_leader_get_info
test_that("marc_leader_get_info() works", {
  expect_equal(books_serials_etc_sample[, marc_leader_get_info(marc_leader)][,record_type],
               books_serials_etc_sample[,record_type])
  expect_equal(books_serials_etc_sample[, marc_leader_get_info(marc_leader)][,bib_level],
               books_serials_etc_sample[,bib_level])
  expect_equal(marc_leader_get_info("00000ctm a2200000Ma 4500")[,record_type],
               "Manuscript language material")
  expect_error(marc_leader_get_info(8675309), "x must be a string or NA")
  expect_equal(marc_leader_get_info(NA_character_),
               data.table(record_type=NA_character_, bib_level=NA_character_))
  expect_equal(marc_leader_get_info(NA),
               data.table(record_type=NA_character_, bib_level=NA_character_))
})

test_that("marc_leader_get_info() takes a vector of only NAs", {
  expect_equal(marc_leader_get_info(c(NA, NA)),
               data.table(record_type=rep(NA_character_, 2),
                          bib_level=rep(NA_character_, 2)))
})

# marc_008_get_info
test_that("marc_008_get_info() works", {
  expect_equal(books_serials_etc_sample[, marc_008_get_info(marc_008, original.pub.date=TRUE)][,pub_date],
               books_serials_etc_sample[,pubyear2])
  expect_equal(books_serials_etc_sample[, marc_008_get_info(marc_008)][,lang_code],
               books_serials_etc_sample[,language])
  expect_error(marc_008_get_info(8675309), "x must be a string or NA")
  expect_equal(as.list(marc_008_get_info(NA_character_)),
               list(pub_date=NA_integer_, pub_place_code=NA_character_,
                    lang_code=NA_character_))
  expect_equal(as.list(marc_008_get_info(NA)),
               list(pub_date=NA_integer_, pub_place_code=NA_character_,
                    lang_code=NA_character_))

  # complete place and language codes
  tmp <- marc_008_get_info(c("950622s1970    nyu           000 0 eng d",
                             "950622s1970    ru            000 0 rus d",
                             "950622s1970    |||           000 0 ||| d"))
  expect_equal(tmp[, pub_place_code], c("nyu", "ru", "|||"))
  expect_equal(tmp[, lang_code], c("eng", "rus", "|||"))

  # blank or incomplete place and language codes
  full <- "950622s1970    nyu           000 0 eng d"
  tmp <- marc_008_get_info(c("950622s1970                  000 0     d",
                             substr(full, 1, 37), substr(full, 1, 17),
                             "950622s1970", ""))
  expect_equal(tmp[, pub_date], c(1970, 1970, 1970, 1970, NA))
  expect_equal(tmp[, pub_place_code], c(NA, "nyu", NA, NA, NA))
  expect_equal(tmp[, lang_code], rep(NA_character_, 5))
})

test_that("marc_008_get_info() takes a vector of only NAs", {
  expect_equal(as.list(marc_008_get_info(c(NA, NA))),
               list(pub_date=rep(NA_integer_, 2),
                    pub_place_code=rep(NA_character_, 2),
                    lang_code=rep(NA_character_, 2)))
})

